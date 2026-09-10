/// Tập dinh dưỡng (dùng cho tổng hợp trong ngày và scale theo gram).
class FoodNutrients {
  const FoodNutrients({
    this.calo = 0,
    this.protein = 0,
    this.fat = 0,
    this.carb = 0,
    this.fiber = 0,
  });

  final double calo;
  final double protein;
  final double fat;
  final double carb;
  final double fiber;

  FoodNutrients operator +(FoodNutrients other) => FoodNutrients(
    calo: calo + other.calo,
    protein: protein + other.protein,
    fat: fat + other.fat,
    carb: carb + other.carb,
    fiber: fiber + other.fiber,
  );

  FoodNutrients operator *(double factor) => FoodNutrients(
    calo: calo * factor,
    protein: protein * factor,
    fat: fat * factor,
    carb: carb * factor,
    fiber: fiber * factor,
  );

  FoodNutrients rounded({int decimals = 1}) {
    double r(double v) {
      final m = _pow10(decimals);
      return (v * m).round() / m;
    }

    return FoodNutrients(
      calo: r(calo),
      protein: r(protein),
      fat: r(fat),
      carb: r(carb),
      fiber: r(fiber),
    );
  }

  static double _pow10(int n) {
    var m = 1.0;
    for (var i = 0; i < n; i++) {
      m *= 10;
    }
    return m;
  }

  @override
  String toString() =>
      'FoodNutrients(calo: $calo, protein: $protein, fat: $fat, '
      'carb: $carb, fiber: $fiber)';
}

/// Map đúng 1 document trong collection Firestore `foods`.
class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    required this.nameSearch,
    required this.type,
    required this.group,
    required this.servingG,
    required this.calo,
    required this.protein,
    required this.fat,
    required this.carb,
    required this.fiber,
    this.cholesterol,
    this.calcium,
    this.phosphorus,
    this.iron,
    this.sodium,
    this.potassium,
    this.betaCarotene,
    this.vitaminA,
    this.vitaminB1,
    this.vitaminC,
  });

  final String id;
  final String name;
  final String nameSearch;
  final String type; // "dish" | "ingredient"
  final String group;
  final double servingG;

  final double calo;
  final double protein;
  final double fat;
  final double carb;
  final double fiber;

  // Chỉ có ở type = "ingredient", có thể null với "dish"
  final double? cholesterol;
  final double? calcium;
  final double? phosphorus;
  final double? iron;
  final double? sodium;
  final double? potassium;
  final double? betaCarotene;
  final double? vitaminA;
  final double? vitaminB1;
  final double? vitaminC;

  factory FoodModel.fromMap(Map<String, dynamic> map, String id) {
    double n(Object? value) => (value as num?)?.toDouble() ?? 0;

    return FoodModel(
      id: id,
      name: map['name'] as String? ?? '',
      nameSearch: map['name_search'] as String? ?? '',
      type: map['type'] as String? ?? '',
      group: map['group'] as String? ?? '',
      servingG: n(map['serving_g']),
      calo: n(map['calo']),
      protein: n(map['protein']),
      fat: n(map['fat']),
      carb: n(map['carb']),
      fiber: n(map['fiber']),
      cholesterol: (map['cholesterol'] as num?)?.toDouble(),
      calcium: (map['calcium'] as num?)?.toDouble(),
      phosphorus: (map['phosphorus'] as num?)?.toDouble(),
      iron: (map['iron'] as num?)?.toDouble(),
      sodium: (map['sodium'] as num?)?.toDouble(),
      potassium: (map['potassium'] as num?)?.toDouble(),
      betaCarotene: (map['beta_carotene'] as num?)?.toDouble(),
      vitaminA: (map['vitamin_a'] as num?)?.toDouble(),
      vitaminB1: (map['vitamin_b1'] as num?)?.toDouble(),
      vitaminC: (map['vitamin_c'] as num?)?.toDouble(),
    );
  }

  /// Dinh dưỡng ứng với [grams] thực tế (tỉ lệ so với serving_g gốc).
  FoodNutrients nutrientsFor(double grams) {
    final factor = servingG <= 0 ? 0.0 : grams / servingG;
    return FoodNutrients(
      calo: calo,
      protein: protein,
      fat: fat,
      carb: carb,
      fiber: fiber,
    ) * factor;
  }

  @override
  String toString() => 'FoodModel(id: $id, name: $name, servingG: $servingG)';
}