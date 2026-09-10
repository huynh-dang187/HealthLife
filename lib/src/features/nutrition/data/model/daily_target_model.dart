import 'package:equatable/equatable.dart';

/// Mục tiêu dinh dưỡng 1 ngày.
///
/// Calo được lấy từ `users/{uid}.dailyCalorieGoal` (tự tính BMR theo hồ sơ
/// khi chưa có, theo Mifflin-St Jeor × 1.2), 4 đại lượng còn lại suy ra theo
/// tỉ lệ: Đạm 20%, Béo 25%, Carbs 55%, chất xơ mặc định 25g.
class DailyTargetModel extends Equatable {
  const DailyTargetModel({
    required this.calo,
    required this.protein,
    required this.fat,
    required this.carb,
    required this.fiber,
  });

  /// Trạng thái khởi tạo (trước khi load từ Firestore): calo = fromCalories(2000).
  const DailyTargetModel.defaults()
      : calo = 2000,
        protein = 100,
        fat = 55.6,
        carb = 275,
        fiber = 25;

  final double calo;
  final double protein;
  final double fat;
  final double carb;
  final double fiber;

  /// Từ 1 con số calo, chia nhỏ theo tỉ lệ chuẩn.
  factory DailyTargetModel.fromCalories(double calories) {
    final cal = (calories / 10).round() * 10.0;
    return DailyTargetModel(
      calo: cal,
      protein: cal * 0.2 / 4, // 4 kcal/g
      fat: cal * 0.25 / 9, // 9 kcal/g
      carb: cal * 0.55 / 4, // 4 kcal/g
      fiber: 25,
    );
  }

  /// BMR Mifflin-St Jeor: 10·W + 6.25·H − 5·A + s (s = +5 nam, −161 nữ)
  /// Nhân hệ số vận động 1.2; thiếu dữ liệu thì fallback 2000 kcal.
  factory DailyTargetModel.fromProfile({
    double? heightCm,
    double? weightKg,
    int? ageYears,
    String? gender,
  }) {
    double calories;
    if (heightCm != null && weightKg != null && ageYears != null) {
      final base = 10 * weightKg + 6.25 * heightCm - 5 * ageYears;
      final sexOffset = gender?.toLowerCase() == 'male' ? 5.0 : -161.0;
      calories = (base + sexOffset) * 1.2;
    } else {
      calories = 2000;
    }
    return DailyTargetModel.fromCalories(calories);
  }

  factory DailyTargetModel.fromMap(Map<String, dynamic> map) {
    final calo = (map['dailyCalorieGoal'] as num?)?.toDouble() ?? 2000;
    return DailyTargetModel.fromCalories(calo);
  }

  Map<String, dynamic> toMap() => {'dailyCalorieGoal': calo};

  @override
  List<Object?> get props => [calo, protein, fat, carb, fiber];
}