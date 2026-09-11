import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/enums/bloc_status.dart';
import '../../data/datasources/hospital_finder_local_data_source.dart';
import '../../data/services/hospital_finder_service.dart';
import '../../domain/entities/medical_place.dart';
import 'hospital_finder_state.dart';

class HospitalFinderCubit extends Cubit<HospitalFinderState> {
  final HospitalFinderService _hospitalFinderService = HospitalFinderService();
  final HospitalFinderLocalDataSource _localDataSource = HospitalFinderLocalDataSource();

  HospitalFinderCubit() : super(const HospitalFinderState()) {
    loadSearchHistory();
  }

  Future<void> loadSearchHistory() async {
    final history = await _localDataSource.getHistoryPlaces();
    emit(state.copyWith(historyPlaces: history));
  }

  Future<void> loadNearbyFacilities(double lat, double lng) async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      final facilities = await _hospitalFinderService.fetchNearbyFacilities(lat, lng);

      if (facilities.isEmpty) {
        emit(state.copyWith(
          status: BlocStatus.success,
          places: [],
          errorMessage: 'Không tìm thấy cơ sở y tế nào trong bán kính 5km.',
        ));
      } else {
        emit(state.copyWith(
          status: BlocStatus.success,
          places: facilities,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.failure,
        places: [],
        errorMessage: 'Không thể kết nối với máy chủ. Vui lòng kiểm tra lại mạng.',
      ));
    }
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

  // Xem thông tin chi tiết: CHƯA lưu lịch sử
  Future<void> showFacilityPopup(MedicalPlace facility) async {
    emit(state.copyWith(activePopupFacility: facility));
    await selectPlaceAndDrawRoute(facility, saveToHistory: false);
  }

  void closeFacilityPopup() {
    emit(state.copyWith(
      clearActivePopupFacility: true,
      clearRoutePoints: true,
      clearSelectedPlace: true,
    ));
  }

  Future<void> selectFacility(MedicalPlace facility) async {
    await selectPlaceAndDrawRoute(facility, saveToHistory: false);
  }

  // Hành động 1: Chỉ đường vẽ trên App (Lưu lịch sử khi saveToHistory = true)
  Future<void> selectPlaceAndDrawRoute(MedicalPlace place, {bool saveToHistory = true}) async {
    emit(state.copyWith(selectedPlace: place, status: BlocStatus.loading));

    if (saveToHistory) {
      await _localDataSource.savePlaceToHistory(place);
      await loadSearchHistory();
    }

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

  // Hành động 2: Mở ứng dụng Bản đồ ngoài (Lưu lịch sử)
  Future<void> openExternalMaps(MedicalPlace place) async {
    await _localDataSource.savePlaceToHistory(place);
    await loadSearchHistory();

    final url = 'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      emit(state.copyWith(errorMessage: 'Không thể mở Google Maps.'));
    }
  }

  // Hành động 3: Gọi điện (Lưu lịch sử)
  Future<void> makePhoneCall(MedicalPlace place) async {
    await _localDataSource.savePlaceToHistory(place);
    await loadSearchHistory();

    final cleanNumber = place.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final url = 'tel:$cleanNumber';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      emit(state.copyWith(errorMessage: 'Không thể kết nối cuộc gọi.'));
    }
  }

  Future<void> navigateToNearestHospital() async {
    if (state.places.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Chưa có danh sách cơ sở y tế gần bạn.',
      ));
      return;
    }

    final nearest = state.places.firstWhere(
          (p) => p.type.toLowerCase() == 'hospital' || p.category.toLowerCase() == 'bệnh viện',
      orElse: () => state.places.first,
    );

    await openExternalMaps(nearest);
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