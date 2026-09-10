import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/enums/bloc_status.dart';
import '../../data/services/hospital_finder_service.dart';
import '../../domain/entities/medical_place.dart';
import 'hospital_finder_state.dart';

class HospitalFinderCubit extends Cubit<HospitalFinderState> {
  final HospitalFinderService _hospitalFinderService = HospitalFinderService();

  HospitalFinderCubit() : super(const HospitalFinderState()) {
    // We will load data once we have location
  }

  Future<void> loadNearbyFacilities(double lat, double lng) async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      final facilities = await _hospitalFinderService.fetchNearbyFacilities(lat, lng);
      
      if (facilities.isEmpty) {
        // Fallback to mock data if API returns empty
        final mocks = getMockFacilities(lat, lng);
        emit(state.copyWith(
          status: BlocStatus.success,
          places: mocks,
        ));
      } else {
        emit(state.copyWith(
          status: BlocStatus.success,
          places: facilities,
        ));
      }
    } catch (e) {
      // Fallback to mock data on error
      final mocks = getMockFacilities(lat, lng);
      emit(state.copyWith(
        status: BlocStatus.success,
        places: mocks,
        errorMessage: 'Không thể kết nối máy chủ. Đang hiển thị dữ liệu mẫu.',
      ));
    }
  }

  List<MedicalPlace> getMockFacilities(double lat, double lng) {
    return [
      MedicalPlace(
        id: 'mock_1',
        name: 'Bệnh viện Đa khoa Tâm Anh',
        address: '2B Phổ Quang, Phường 2, Tân Bình',
        category: 'Bệnh viện',
        latitude: lat + 0.003,
        longitude: lng + 0.002,
        type: 'hospital',
        distanceKm: 0.35,
        rating: 4.8,
        phoneNumber: '1800 6858',
        isOpen24h: true,
      ),
      MedicalPlace(
        id: 'mock_2',
        name: 'Bệnh viện Chợ Rẫy',
        address: '201B Nguyễn Chí Thanh, Phường 12, Quận 5',
        category: 'Bệnh viện',
        latitude: lat - 0.004,
        longitude: lng + 0.003,
        type: 'hospital',
        distanceKm: 0.82,
        rating: 4.5,
        phoneNumber: '028 3855 4137',
        isOpen24h: true,
      ),
      MedicalPlace(
        id: 'mock_3',
        name: 'Nhà thuốc Pharmacity',
        address: 'Gần vị trí của bạn',
        category: 'Nhà thuốc',
        latitude: lat + 0.002,
        longitude: lng - 0.003,
        type: 'pharmacy',
        distanceKm: 0.18,
        rating: 4.6,
        phoneNumber: '1800 6821',
        isOpen24h: false,
      ),
      MedicalPlace(
        id: 'mock_4',
        name: 'Bệnh viện Nhi Đồng 1',
        address: '341 Sư Vạn Hạnh, Phường 10, Quận 10',
        category: 'Bệnh viện',
        latitude: lat - 0.002,
        longitude: lng - 0.004,
        type: 'hospital',
        distanceKm: 0.55,
        rating: 4.7,
        phoneNumber: '028 3927 1119',
        isOpen24h: true,
      ),
    ];
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void selectPlace(MedicalPlace? place) {
    if (place == null) {
      emit(state.copyWith(clearSelectedPlace: true, clearRoutePoints: true));
    } else {
      emit(state.copyWith(selectedPlace: place));
    }
  }

  Future<void> showFacilityPopup(MedicalPlace facility) async {
    emit(state.copyWith(activePopupFacility: facility));
    await selectPlaceAndDrawRoute(facility);
  }

  void closeFacilityPopup() {
    emit(state.copyWith(
      clearActivePopupFacility: true,
      clearRoutePoints: true,
      clearSelectedPlace: true,
    ));
  }

  Future<void> selectFacility(MedicalPlace facility) async {
    await selectPlaceAndDrawRoute(facility);
  }

  Future<void> selectPlaceAndDrawRoute(MedicalPlace place) async {
    emit(state.copyWith(selectedPlace: place, status: BlocStatus.loading));
    
    if (state.currentLocation == null) {
      emit(state.copyWith(status: BlocStatus.success));
      return;
    }

    try {
      final route = await _hospitalFinderService.fetchRoute(
        state.currentLocation!,
        LatLng(place.latitude, place.longitude),
      );
      emit(state.copyWith(
        status: BlocStatus.success,
        routePoints: route,
      ));
    } catch (e) {
      // Fallback: Nối đường thẳng nếu OSRM lỗi
      final fallbackRoute = [
        state.currentLocation!,
        LatLng(place.latitude, place.longitude),
      ];
      emit(state.copyWith(
        status: BlocStatus.success,
        routePoints: fallbackRoute,
        errorMessage: 'Lỗi khi vẽ đường đi chi tiết. Đang hiển thị đường nối thẳng.',
      ));
    }
  }

  Future<void> openExternalMaps(MedicalPlace place) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      emit(state.copyWith(errorMessage: 'Không thể mở Google Maps.'));
    }
  }

  void toggleQuickMenu() {
    emit(state.copyWith(isQuickMenuOpen: !state.isQuickMenuOpen));
  }

  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    emit(state.copyWith(isLoadingLocation: true, errorMessage: null));

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        emit(state.copyWith(
          errorMessage: 'Vui lòng bật GPS để ứng dụng định vị chính xác.',
        ));
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(state.copyWith(errorMessage: 'Quyền truy cập vị trí bị từ chối.'));
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(state.copyWith(
          errorMessage: 'Cần cấp quyền vị trí trong Cài đặt để sử dụng tính năng này.',
        ));
        return null;
      }

      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        final lastLatLng = LatLng(lastPosition.latitude, lastPosition.longitude);
        emit(state.copyWith(currentLocation: lastLatLng));
        loadNearbyFacilities(lastLatLng.latitude, lastLatLng.longitude);
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);
      emit(state.copyWith(currentLocation: currentLatLng));
      loadNearbyFacilities(currentLatLng.latitude, currentLatLng.longitude);
      return currentLatLng;
    } catch (e) {
      if (state.currentLocation != null) return state.currentLocation;

      const fallbackLocation = LatLng(10.7769, 106.7009);
      emit(state.copyWith(
        currentLocation: fallbackLocation,
        errorMessage: 'Lỗi kết nối định vị. Đang hiển thị khu vực TP.HCM.',
      ));
      loadNearbyFacilities(fallbackLocation.latitude, fallbackLocation.longitude);
      return fallbackLocation;
    } finally {
      emit(state.copyWith(isLoadingLocation: false));
    }
  }
}
