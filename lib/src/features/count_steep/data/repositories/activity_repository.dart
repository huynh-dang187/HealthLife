import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:healthlife/src/features/count_steep/data/models/step_streak_model.dart';
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

  Future<Box> _cache() async {
    if (Hive.isBoxOpen(cacheBoxName)) return Hive.box(cacheBoxName);
    return Hive.openBox(cacheBoxName);
  }

  String _dateKey(tz.TZDateTime now) {
    final y = now.year;
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
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

    final goal = await _fetchStepGoal(user.uid);
    final goalReached = steps >= goal;
    final dateKey = _dateKey(now);

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
  }

  bool _shouldWrite(int steps, tz.TZDateTime now) {
    final lastSteps = _lastWrittenSteps;
    final lastTime = _lastWriteTime;
    if (lastSteps == null || lastTime == null) return true;
    final delta = (steps - lastSteps).abs();
    if (delta >= _minStepDeltaWrite) return true;
    return now.difference(lastTime) >= _minWriteInterval;
  }

  /// Mục tiêu bước hiện tại từ `users/{uid}.stepGoal`, mặc định 6000.
  Future<int> fetchStepGoal() async {
    final user = _auth.currentUser;
    if (user == null) return defaultStepGoal;
    return _fetchStepGoal(user.uid);
  }

  Future<int> _fetchStepGoal(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final goal = doc.data()?['stepGoal'];
      return goal is num ? goal.toInt() : defaultStepGoal;
    } catch (e) {
      debugPrint('[ActivityRepo] đọc stepGoal lỗi, dùng mặc định: $e');
      return defaultStepGoal;
    }
  }

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