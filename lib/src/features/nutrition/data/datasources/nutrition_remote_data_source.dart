import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/daily_target_model.dart';
import '../model/food_model.dart';
import '../model/meal_log_model.dart';

class NutritionRemoteDataSource {
  NutritionRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid =>
      _auth.currentUser?.uid ??
      (throw StateError('Chưa đăng nhập để truy cập dữ liệu dinh dưỡng'));

  CollectionReference<Map<String, dynamic>> get _foods =>
      _firestore.collection('foods');

  CollectionReference<Map<String, dynamic>> get _mealLogs =>
      _firestore.collection('users').doc(_uid).collection('meal_logs');

  /// Tìm kiếm thực phẩm theo `name_search` (đã chuẩn hoá không dấu).
  /// Prefix query: keyword <= name_search < keyword + '\uf8ff'
  Future<List<FoodModel>> searchFoods(String keyword) async {
    final snap = await _foods
        .where(
          'name_search',
          isGreaterThanOrEqualTo: keyword,
          isLessThan: '$keyword\uf8ff',
        )
        .limit(50)
        .get();

    return snap.docs
        .map((doc) => FoodModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Lấy nhật ký ăn của user trong [start, end] (bao gồm cả 2 đầu).
  /// Query theo chuỗi `date` yyyy-MM-dd, lọc chặn trên trong memory để
  /// không phát sinh yêu cầu composite index trên Firestore.
  Future<List<MealLogModel>> getMealLogsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final startKey = _dayString(start);
    final endKey = _dayString(end);

    final snap = await _mealLogs
        .where('date', isGreaterThanOrEqualTo: startKey)
        .orderBy('date')
        .get();

    final logs = snap.docs
        .where((doc) => (doc.data()['date'] as String? ?? '').compareTo(endKey) <= 0)
        .map((doc) => MealLogModel.fromMap(doc.data(), doc.id))
        .toList();

    logs.sort((a, b) => b.mealTime.compareTo(a.mealTime));
    return logs;
  }

  /// Ghi 1 bữa ăn vào `users/{uid}/meal_logs`.
  /// Dinh dưỡng đã được scale theo [grams] so với serving_g gốc.
  Future<MealLogModel> addMealLog({
    required FoodModel food,
    required double grams,
    DateTime? mealTime,
  }) async {
    final at = mealTime ?? DateTime.now();
    final nutrients = food.nutrientsFor(grams).rounded();

    final docRef = await _mealLogs.add({
      'foodId': food.id,
      'foodName': food.name,
      'calo': nutrients.calo,
      'protein': nutrients.protein,
      'fat': nutrients.fat,
      'carb': nutrients.carb,
      'fiber': nutrients.fiber,
      'grams': grams,
      'mealTime': Timestamp.fromDate(at),
      'date': _dayString(at),
    });

    return MealLogModel(
      id: docRef.id,
      foodId: food.id,
      foodName: food.name,
      calo: nutrients.calo,
      protein: nutrients.protein,
      fat: nutrients.fat,
      carb: nutrients.carb,
      fiber: nutrients.fiber,
      grams: grams,
      mealTime: at,
    );
  }

  Future<void> deleteMealLog(String logId) async {
    await _mealLogs.doc(logId).delete();
  }

  /// Mục tiêu calo: ưu tiên field `dailyCalorieGoal` đã lưu, nếu chưa có thì
  /// tự tính BMR từ hồ sơ (Mifflin-St Jeor × 1.2) rồi lưu lại để user chỉnh sau.
  Future<DailyTargetModel> fetchDailyTargets() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    final data = doc.data();

    final savedCalo = data?['dailyCalorieGoal'] as num?;
    if (savedCalo != null) {
      return DailyTargetModel.fromCalories(savedCalo.toDouble());
    }

    final dob = data?['dateOfBirth'] as Timestamp?;
    final target = DailyTargetModel.fromProfile(
      heightCm: (data?['height'] as num?)?.toDouble(),
      weightKg: (data?['weight'] as num?)?.toDouble(),
      ageYears: dob == null
          ? null
          : DateTime.now()
                    .difference(dob.toDate())
                    .inDays ~/
                365,
      gender: data?['gender'] as String?,
    );

    await doc.reference.set(target.toMap(), SetOptions(merge: true));
    return target;
  }

  static String _dayString(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}