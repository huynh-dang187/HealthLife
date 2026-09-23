import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:healthlife/src/features/count_steep/data/models/step_chart_data.dart';
import 'package:healthlife/src/features/count_steep/data/models/step_streak_model.dart';
import 'package:healthlife/src/shared/models/user_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Truy cập cảm biến bước chân, cache baseline theo ngày và ghi lên Firestore.
class ActivityRepository {
  ActivityRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Hive box chứa baseline/today cache, key theo yyyy-MM-dd.
  static const cacheBoxName = 'activity_cache';

  /// Mục tiêu bước mặc định khi chưa có `users/{uid}.stepGoal`.
  static const defaultStepGoal = 6000;

  /// Mục tiêu mặc định theo độ tuổi/giới tính khi user chưa từng tự đặt.
  static const _adultMaleGoal = 8000;
  static const _adultFemaleGoal = 7000;
  static const _elderGoal = 4000;

  /// Chỉ ghi Firestore khi số bước nhảy >= 20 HOẶC đã trôi qua 3 phút.
  static const _minStepDeltaWrite = 20;
  static const _minWriteInterval = Duration(minutes: 3);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  tz.Location? _tzLocation;
  int? _lastWrittenSteps;
  DateTime? _lastWriteTime;

  tz.Location get _vnTz {
    final existing = _tzLocation;
    if (existing != null) return existing;
    tzdata.initializeTimeZones();
    return _tzLocation = tz.getLocation('Asia/Ho_Chi_Minh');
  }

  tz.TZDateTime _vnNow() => tz.TZDateTime.now(_vnTz);

  /// Giờ hiện tại theo múi giờ Việt Nam (cho cubit tính mốc tuần/tháng/năm).
  DateTime vnNow() => _vnNow();

  Future<Box> _cache() async {
    if (Hive.isBoxOpen(cacheBoxName)) return Hive.box(cacheBoxName);
    return Hive.openBox(cacheBoxName);
  }

  String _dateKey(tz.TZDateTime now) => _dateKeyOf(now);

  String _dateKeyOf(DateTime day) {
    final y = day.year;
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _baselineKey(tz.TZDateTime now) => '${_dateKey(now)}_baseline';

  /// Xin quyền nhận diện vận động để đọc cảm biến bước chân.
  Future<bool> requestActivityPermission() async {
    final status = await Permission.activityRecognition.request();
    final granted = status.isGranted;
    debugPrint('[ActivityRepo] permission activityRecognition = $status');
    return granted;
  }

  /// Stream số bước hôm nay. Tự xử lý baseline cho từng ngày:
  /// - Ngày mới → lưu currentSensorSteps làm baseline.
  /// - Sensor < baseline (vừa reboot) → cộng dồn số đã lưu thay vì tính âm.
  Stream<int> getSensorStepStream() async* {
    final box = await _cache();
    yield* Pedometer.stepCountStream.asyncMap((event) async {
      final today = await _resolveTodaySteps(box, event.steps);
      debugPrint('[ActivityRepo] sensor=${event.steps} -> todaySteps=$today');
      return today;
    });
  }

  Future<int> _resolveTodaySteps(Box box, int current) async {
    final now = _vnNow();
    final todayKey = _dateKey(now);
    final baselineKey = _baselineKey(now);

    final int? baseline = box.get(baselineKey);
    final int? cachedToday = box.get(todayKey);

    if (baseline == null) {
      await box.put(baselineKey, current);
      await box.put(todayKey, 0);
      debugPrint('[ActivityRepo] ngày mới: lưu baseline=$current');
      return 0;
    }

    var today = current - baseline;
    if (today < 0) {
      final previousToday = cachedToday ?? 0;
      today = previousToday + current;
      await box.put(baselineKey, current - previousToday);
      debugPrint(
        '[ActivityRepo] phát hiện reboot (current=$current < baseline=$baseline), '
        'today=$today (cộng dồn $previousToday + $current)',
      );
    }

    today = math.max(today, 0);
    await box.put(todayKey, today);
    return today;
  }

  /// Ghi số bước hôm nay vào `users/{uid}/daily_steps/{yyyy-MM-dd}`
  /// với field `steps` + `goalReached` (so với `users/{uid}.stepGoal`).
  ///
  /// Debounce nội bộ: chỉ ghi thật khi số bước thay đổi >= 20
  /// HOẶC đã đủ 3 phút kể từ lần ghi trước (tránh ghi theo từng sự kiện sensor).
  Future<void> saveTodayStepsToFirestore(int steps) async {
    final now = _vnNow();
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[ActivityRepo] bỏ qua ghi Firestore: chưa đăng nhập');
      return;
    }

    if (!_shouldWrite(steps, now)) {
      debugPrint(
        '[ActivityRepo] bỏ qua ghi Firestore (Δ < 20, chưa đủ 3 phút)',
      );
      return;
    }

    final dateKey = _dateKey(now);
    try {
      final goal = await fetchStepGoal();
      final goalReached = steps >= goal;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_steps')
          .doc(dateKey)
          .set({
            'steps': steps,
            'goalReached': goalReached,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      _lastWrittenSteps = steps;
      _lastWriteTime = now;
      debugPrint(
        '[ActivityRepo] ghi Firestore $dateKey: steps=$steps '
        'goalReached=$goalReached (goal=$goal)',
      );
    } catch (e) {
      debugPrint('[ActivityRepo] ghi Firestore $dateKey thất bại: $e');
    }
  }

  bool _shouldWrite(int steps, tz.TZDateTime now) {
    final lastSteps = _lastWrittenSteps;
    final lastTime = _lastWriteTime;
    if (lastSteps == null || lastTime == null) return true;
    final delta = (steps - lastSteps).abs();
    if (delta >= _minStepDeltaWrite) return true;
    return now.difference(lastTime) >= _minWriteInterval;
  }

  /// `users/{uid}.stepGoal` hiện có (`null` khi chưa từng đặt hoặc đọc lỗi).
  Future<int?> fetchStoredStepGoal() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final goal = doc.data()?['stepGoal'];
      return goal is num ? goal.toInt() : null;
    } catch (e) {
      debugPrint('[ActivityRepo] đọc stepGoal lỗi, trả về null: $e');
      return null;
    }
  }

  /// Mục tiêu bước hiện tại: giá trị đã lưu, nếu chưa có thì dùng mặc định.
  Future<int> fetchStepGoal() async {
    return (await fetchStoredStepGoal()) ?? defaultStepGoal;
  }

  /// Mục tiêu mặc định theo hồ sơ user:
  /// - Nam 18-59 tuổi: 8000
  /// - Nữ 18-59 tuổi: 7000
  /// - Trên 60 tuổi: 4000
  ///
  /// Chỉ dùng làm giá trị khởi tạo LẦN ĐẦU (khi `stepGoal` chưa tồn tại),
  /// không ghi đè nếu user đã tự chỉnh. Thiếu tuổi/giới tính → 6000.
  Future<int> calculateDefaultGoal(UserModel? user) async {
    final dob = user?.dateOfBirth;
    if (dob == null) return defaultStepGoal;

    final now = _vnNow();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    debugPrint('[ActivityRepo] calculateDefaultGoal: dob=$dob age=$age');

    if (age > 60) return _elderGoal;
    switch (user?.gender?.toLowerCase()) {
      case 'male':
        return _adultMaleGoal;
      case 'female':
        return _adultFemaleGoal;
      default:
        return defaultStepGoal;
    }
  }

  /// Lưu mục tiêu bước mới vào `users/{uid}.stepGoal` (merge, không xoá dữ liệu).
  Future<void> updateStepGoal(int goal) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[ActivityRepo] bỏ qua updateStepGoal: chưa đăng nhập');
      return;
    }
    await _firestore.collection('users').doc(user.uid).set(
      {
        'stepGoal': goal,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    debugPrint('[ActivityRepo] đã lưu stepGoal=$goal cho ${user.uid}');
  }

  /// Lịch sử 7 ngày của tuần bắt đầu từ [weekStart] (thường là thứ 2).
  /// Trả về đủ 7 điểm (ngày không có bản ghi → steps=0, goalReached=false),
  /// label là thứ trong tuần (T2..CN).
  Future<List<StepChartData>> getWeeklyData(DateTime weekStart) async {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final records = await _fetchDailyRecords(
      _dateKeyOf(start),
      _dateKeyOf(start.add(const Duration(days: 6))),
    );
    return [
      for (var i = 0; i < 7; i++)
        _chartPoint(
          records,
          start.add(Duration(days: i)),
          _weekdayLabel(start.add(Duration(days: i))),
        ),
    ];
  }

  /// Lịch sử cả tháng của [monthStart] (thường là mùng 1).
  /// Trả về đủ số ngày trong tháng, label là số ngày.
  Future<List<StepChartData>> getMonthlyData(DateTime monthStart) async {
    final start = DateTime(monthStart.year, monthStart.month, 1);
    final days = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final records = await _fetchDailyRecords(
      _dateKeyOf(start),
      _dateKeyOf(DateTime(monthStart.year, monthStart.month, days)),
    );
    return [
      for (var d = 1; d <= days; d++)
        _chartPoint(
          records,
          DateTime(monthStart.year, monthStart.month, d),
          '$d',
        ),
    ];
  }

  /// 12 điểm theo tháng của [year], mỗi điểm = trung bình bước/ngày có data.
  /// goalReached = trung bình trong tháng >= mục tiêu hiện tại.
  Future<List<StepChartData>> getYearlyData(int year) async {
    final records = await _fetchDailyRecords(
      _dateKeyOf(DateTime(year, 1, 1)),
      _dateKeyOf(DateTime(year, 12, 31)),
    );
    final goal = await fetchStepGoal();
    return [
      for (var m = 1; m <= 12; m++)
        _aggregateMonth(records, year, m, goal),
    ];
  }

  StepChartData _aggregateMonth(
    Map<String, _DailyStepRecord> records,
    int year,
    int month,
    int goal,
  ) {
    final days = DateTime(year, month + 1, 0).day;
    var total = 0;
    var recorded = 0;
    for (var d = 1; d <= days; d++) {
      final record = records[_dateKeyOf(DateTime(year, month, d))];
      if (record == null) continue;
      total += record.steps;
      recorded++;
    }
    final avg = recorded == 0 ? 0 : (total / recorded).round();
    return StepChartData(
      label: 'thg $month',
      steps: avg,
      goalReached: avg >= goal,
    );
  }

  /// Đọc các bản ghi `daily_steps` trong khoảng doc-id [startKey..endKey].
  /// Doc id là `yyyy-MM-dd` (zero-padded) nên so sánh chuỗi = so sánh ngày.
  Future<Map<String, _DailyStepRecord>> _fetchDailyRecords(
    String startKey,
    String endKey,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return const {};
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_steps')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endKey)
          .get();

      final records = <String, _DailyStepRecord>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final steps = data['steps'];
        records[doc.id] = _DailyStepRecord(
          steps: steps is num ? steps.toInt() : 0,
          goalReached: data['goalReached'] == true,
        );
      }
      return records;
    } catch (e) {
      debugPrint('[ActivityRepo] đọc daily_steps $startKey..$endKey lỗi: $e');
      return const {};
    }
  }

  StepChartData _chartPoint(
    Map<String, _DailyStepRecord> records,
    DateTime day,
    String label,
  ) {
    final record = records[_dateKeyOf(day)];
    return StepChartData(
      label: label,
      steps: record?.steps ?? 0,
      goalReached: record?.goalReached ?? false,
    );
  }

  String _weekdayLabel(DateTime day) => switch (day.weekday) {
    1 => 'T2',
    2 => 'T3',
    3 => 'T4',
    4 => 'T5',
    5 => 'T6',
    6 => 'T7',
    _ => 'CN',
  };

  /// Streak từ lịch sử daily_steps:
  /// current = ngày liên tiếp gần nhất đạt goal (tính từ hôm nay/hôm qua),
  /// best = chuỗi dài nhất từng đạt được.
  Future<StepStreakModel> fetchCurrentStreak() async {
    final user = _auth.currentUser;
    if (user == null) return const StepStreakModel();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_steps')
          .get();

      final reached = <DateTime>{};
      final now = _vnNow();
      for (final doc in snapshot.docs) {
        if (doc.data()['goalReached'] != true) continue;
        final parts = doc.id.split('-');
        if (parts.length != 3) continue;
        final day = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        if (day.isAfter(now)) continue;
        reached.add(day);
      }

      var current = 0;
      var cursor = DateTime(now.year, now.month, now.day);
      if (!reached.contains(cursor)) {
        cursor = cursor.subtract(const Duration(days: 1));
      }
      while (reached.contains(cursor)) {
        current++;
        cursor = cursor.subtract(const Duration(days: 1));
      }

      var best = 0;
      var run = 0;
      DateTime? prev;
      final sorted = reached.toList()..sort();
      for (final day in sorted) {
        run = (prev != null && day.difference(prev).inDays == 1) ? run + 1 : 1;
        if (run > best) best = run;
        prev = day;
      }

      return StepStreakModel(currentStreak: current, bestStreak: best);
    } catch (e) {
      debugPrint('[ActivityRepo] đọc streak lỗi: $e');
      return const StepStreakModel();
    }
  }
}

/// Một bản ghi bước chân một ngày đọc từ Firestore.
class _DailyStepRecord {
  const _DailyStepRecord({required this.steps, required this.goalReached});

  final int steps;
  final bool goalReached;
}