class MedicalPlace {
  final String id;
  final String name;
  final String category; // 'Bệnh viện', 'Nhà thuốc', 'Phòng khám'
  final String address;
  final double distanceKm;
  final double rating;
  final String phoneNumber;
  final bool isOpen24h;
  final double latitude;
  final double longitude;
  final String type; // 'hospital', 'pharmacy', 'clinic'

  const MedicalPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.distanceKm,
    required this.rating,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    this.isOpen24h = false,
    this.type = 'hospital',
  });
}
