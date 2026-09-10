import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../domain/entities/medical_place.dart';

class MapService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const String _osrmUrl = 'http://router.project-osrm.org/route/v1/driving';

  Future<List<MedicalPlace>> fetchNearbyFacilities(double lat, double lng) async {
    final query = '[out:json];node(around:5000,$lat,$lng)["amenity"~"hospital|pharmacy|clinic"];out;';
    final response = await http.get(Uri.parse('$_overpassUrl?data=${Uri.encodeComponent(query)}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List elements = data['elements'];

      return elements.map((e) {
        final double facilityLat = e['lat'];
        final double facilityLng = e['lon'];
        final double distance = Geolocator.distanceBetween(lat, lng, facilityLat, facilityLng) / 1000;
        
        final tags = e['tags'] ?? {};
        final String category = tags['amenity'] == 'pharmacy' ? 'Nhà thuốc' : (tags['amenity'] == 'hospital' ? 'Bệnh viện' : 'Phòng khám');

        return MedicalPlace(
          id: e['id'].toString(),
          name: tags['name'] ?? 'Cơ sở y tế không tên',
          category: category,
          address: tags['addr:full'] ?? tags['addr:street'] ?? 'Địa chỉ đang cập nhật',
          distanceKm: double.parse(distance.toStringAsFixed(1)),
          rating: 4.5, // Mock rating as Overpass doesn't provide it
          phoneNumber: tags['phone'] ?? tags['contact:phone'] ?? 'Đang cập nhật',
          isOpen24h: tags['opening_hours'] == '24/7',
          latitude: facilityLat,
          longitude: facilityLng,
          type: tags['amenity'] ?? 'hospital',
        );
      }).toList();
    }
    return [];
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng destination) async {
    final url = '$_osrmUrl/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List coordinates = data['routes'][0]['geometry']['coordinates'];
      return coordinates.map((c) => LatLng(c[1], c[0])).toList();
    }
    return [];
  }
}
