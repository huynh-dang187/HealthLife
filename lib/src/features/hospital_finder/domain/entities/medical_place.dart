import 'package:geolocator/geolocator.dart';

class MedicalPlace {
  final String id;
  final String name;
  final String category;
  final String address;
  final double distanceKm;
  final double rating;
  final String phoneNumber;
  final bool isOpen24h;
  final double latitude;
  final double longitude;
  final String type;
  final String? imageUrl;

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
    this.imageUrl,
  });

  factory MedicalPlace.fromJson(Map<String, dynamic> json, {double? userLat, double? userLng}) {
    double lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    double lng = (json['longitude'] as num?)?.toDouble() ?? 0.0;

    if (lat == 0 || lng == 0) {
      lat = 10.7769;
      lng = 106.7009;
    }

    double dist = (json['distance_km'] as num?)?.toDouble() ?? 0.0;
    if (dist == 0 && userLat != null && userLng != null) {
      dist = Geolocator.distanceBetween(userLat, userLng, lat, lng) / 1000;
    }

    String mappedCategory = 'Bệnh viện';
    final rawType = json['type']?.toString().toLowerCase() ?? 'hospital';
    if (rawType == 'pharmacy') {
      mappedCategory = 'Nhà thuốc';
    } else if (rawType == 'clinic') {
      mappedCategory = 'Phòng khám';
    }

    return MedicalPlace(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Cơ sở y tế không tên',
      category: mappedCategory,
      address: json['address']?.toString() ?? 'Địa chỉ đang cập nhật',
      distanceKm: double.parse(dist.toStringAsFixed(1)),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      phoneNumber: json['phone']?.toString() ?? json['phone_number']?.toString() ?? 'Đang cập nhật',
      latitude: lat,
      longitude: lng,
      isOpen24h: (json['has_emergency'] ?? json['is_open_24h']) == true,
      type: rawType,
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'distance_km': distanceKm,
      'rating': rating,
      'phone': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'is_open_24h': isOpen24h,
      'type': type,
      'image_url': imageUrl,
    };
  }
}