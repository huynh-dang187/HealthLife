class MedicineModel {
  final String id;
  final String name;
  final String dosage;
  final double price;

  const MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.price,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      dosage: json['dosage'].toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
