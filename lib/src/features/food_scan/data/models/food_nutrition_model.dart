import '../../domain/entities/food_nutrition.dart';

class FoodNutritionModel extends FoodNutrition {
  const FoodNutritionModel({
    required super.isFood,
    super.errorMessage,
    super.foodName,
    super.calories,
    super.proteinG,
    super.fatG,
    super.carbsG,
    super.assessment,
  });

  factory FoodNutritionModel.fromJson(Map<String, dynamic> json) {
    return FoodNutritionModel(
      isFood: json['is_food'] as bool? ?? false,
      errorMessage: json['error_message']?.toString(),
      foodName: json['food_name']?.toString() ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0,
      assessment: json['assessment']?.toString() ?? '',
    );
  }
}