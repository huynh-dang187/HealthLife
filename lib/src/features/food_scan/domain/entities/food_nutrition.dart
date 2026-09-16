class FoodNutrition {
  final bool isFood;
  final String? errorMessage;
  final String foodName;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final String assessment;

  const FoodNutrition({
    required this.isFood,
    this.errorMessage,
    this.foodName = '',
    this.calories = 0,
    this.proteinG = 0,
    this.fatG = 0,
    this.carbsG = 0,
    this.assessment = '',
  });
}