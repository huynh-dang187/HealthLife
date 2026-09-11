import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/medical_place.dart';

class HospitalFinderService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _osrmUrl = 'http://router.project-osrm.org/route/v1/driving';

  Future<List<MedicalPlace>> fetchNearbyFacilities(double lat, double lng) async {
    try {
      debugPrint('==> Đang gọi RPC get_nearby_places với lat: $lat, lng: $lng');

      final response = await _supabase.rpc(
        'get_nearby_places',
        params: {
          'user_lat': lat,
          'user_lng': lng,
        },
      );

      debugPrint('==> Dữ liệu thô từ Supabase: $response');

      if (response == null) return [];

      final List<dynamic> data = response as List<dynamic>;

      // Ep kieu Map an toan bang Map<String, dynamic>.from()
      return data.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        return MedicalPlace.fromJson(
          map,
          userLat: lat,
          userLng: lng,
        );
      }).toList();

    } catch (e, stackTrace) {
      // In loi chi tiet ra Console de de dang kiem tra
      debugPrint('==> LỖI CỤ THỂ TẠI SERVICE: $e');
      debugPrint('==> STACKTRACE: $stackTrace');

      // Quang loi de Cubit nhan biet va hien thi trang thai Failure
      rethrow;
    }
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng destination) async {
    final url = '$_osrmUrl/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];
        return coordinates.map((c) => LatLng(c[1], c[0])).toList();
      }
    } catch (e) {
      debugPrint('Lỗi fetchRoute: $e');
    }
    return [];
  }
}