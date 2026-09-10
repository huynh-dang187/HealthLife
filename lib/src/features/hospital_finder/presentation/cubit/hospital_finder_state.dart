import 'package:latlong2/latlong.dart';
import '../../../../shared/enums/bloc_status.dart';
import '../../domain/entities/medical_place.dart';

class HospitalFinderState {
  final BlocStatus status;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;
  final List<MedicalPlace> places;
  final List<MedicalPlace> historyPlaces;
  final MedicalPlace? selectedPlace;
  final bool isQuickMenuOpen;
  final LatLng? currentLocation;
  final bool isLoadingLocation;
  final List<LatLng> routePoints;
  final MedicalPlace? activePopupFacility;

  const HospitalFinderState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.selectedCategory = 'Gần nhất',
    this.searchQuery = '',
    this.places = const [],
    this.historyPlaces = const [],
    this.selectedPlace,
    this.isQuickMenuOpen = false,
    this.currentLocation,
    this.isLoadingLocation = false,
    this.routePoints = const [],
    this.activePopupFacility,
  });

  List<MedicalPlace> get filteredPlaces {
    return places.where((place) {
      final matchesCategory = selectedCategory == 'Tất cả' ||
          selectedCategory == 'Gần nhất' ||
          selectedCategory == 'Lịch sử' ||
          place.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchesQuery = searchQuery.isEmpty ||
          place.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          place.address.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  HospitalFinderState copyWith({
    BlocStatus? status,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
    List<MedicalPlace>? places,
    List<MedicalPlace>? historyPlaces,
    MedicalPlace? selectedPlace,
    bool? isQuickMenuOpen,
    LatLng? currentLocation,
    bool? isLoadingLocation,
    List<LatLng>? routePoints,
    MedicalPlace? activePopupFacility,
    bool clearSelectedPlace = false,
    bool clearRoutePoints = false,
    bool clearActivePopupFacility = false,
  }) {
    return HospitalFinderState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      places: places ?? this.places,
      historyPlaces: historyPlaces ?? this.historyPlaces,
      selectedPlace:
      clearSelectedPlace ? null : (selectedPlace ?? this.selectedPlace),
      isQuickMenuOpen: isQuickMenuOpen ?? this.isQuickMenuOpen,
      currentLocation: currentLocation ?? this.currentLocation,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      routePoints: clearRoutePoints ? [] : (routePoints ?? this.routePoints),
      activePopupFacility: clearActivePopupFacility
          ? null
          : (activePopupFacility ?? this.activePopupFacility),
    );
  }
}