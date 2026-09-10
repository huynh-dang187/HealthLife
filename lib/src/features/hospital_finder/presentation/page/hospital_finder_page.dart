import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../common/constants/colors.dart';
import '../../../../shared/enums/bloc_status.dart';
import '../../domain/entities/medical_place.dart';
import '../cubit/hospital_finder_cubit.dart';
import '../cubit/hospital_finder_state.dart';
import '../widgets/hospital_finder_canvas_view.dart';
import '../widgets/hospital_finder_quick_actions.dart';
import '../widgets/hospital_finder_search_header.dart';
import '../widgets/medical_place_card.dart';

class HospitalFinderPage extends StatelessWidget {
  const HospitalFinderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HospitalFinderCubit(),
      child: const _HospitalFinderBody(),
    );
  }
}

class _HospitalFinderBody extends StatefulWidget {
  const _HospitalFinderBody();

  @override
  State<_HospitalFinderBody> createState() => _HospitalFinderBodyState();
}

class _HospitalFinderBodyState extends State<_HospitalFinderBody> {
  late PageController _pageController;
  late MapController _mapController;
  late DraggableScrollableController _sheetController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _mapController = MapController();
    _sheetController = DraggableScrollableController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleMyLocation();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    final cubit = context.read<HospitalFinderCubit>();
    if (page == 0) {
      cubit.selectCategory('nearest'.tr());
    } else {
      cubit.selectCategory('history'.tr());
      cubit.loadSearchHistory();
    }
  }

  Future<void> _handleMyLocation() async {
    final cubit = context.read<HospitalFinderCubit>();
    final location = await cubit.getCurrentLocation();

    if (location != null) {
      _mapController.move(location, 15.0);
    }

    if (mounted) {
      final state = cubit.state;
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            behavior: SnackBarBehavior.floating,
            action: _buildSnackBarAction(state.errorMessage!),
          ),
        );
      }
    }
  }

  SnackBarAction? _buildSnackBarAction(String message) {
    if (message.contains('gps_disabled'.tr())) {
      return SnackBarAction(
        label: 'enable_gps'.tr(),
        onPressed: () => Geolocator.openLocationSettings(),
      );
    } else if (message.contains('app_settings'.tr())) {
      return SnackBarAction(
        label: 'settings'.tr(),
        onPressed: () => Geolocator.openAppSettings(),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const HospitalFinderSearchHeader(),
                Expanded(
                  child: HospitalFinderCanvasView(mapController: _mapController),
                ),
              ],
            ),

            BlocBuilder<HospitalFinderCubit, HospitalFinderState>(
              buildWhen: (p, c) =>
              p.isQuickMenuOpen != c.isQuickMenuOpen ||
                  p.isLoadingLocation != c.isLoadingLocation,
              builder: (context, state) {
                if (state.isQuickMenuOpen) return const SizedBox.shrink();
                return Positioned(
                  right: 16,
                  top: MediaQuery.of(context).size.height * 0.38,
                  child: GestureDetector(
                    onTap: _handleMyLocation,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: UIColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: state.isLoadingLocation
                          ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : const Icon(Icons.my_location, color: Colors.blueAccent),
                    ),
                  ),
                );
              },
            ),

            BlocBuilder<HospitalFinderCubit, HospitalFinderState>(
              buildWhen: (p, c) =>
              p.activePopupFacility != c.activePopupFacility ||
                  p.isQuickMenuOpen != c.isQuickMenuOpen,
              builder: (context, state) {
                if (state.activePopupFacility == null || state.isQuickMenuOpen) {
                  return const SizedBox.shrink();
                }

                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () =>
                            context.read<HospitalFinderCubit>().closeFacilityPopup(),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            MedicalPlaceCard(place: state.activePopupFacility!),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: GestureDetector(
                                onTap: () => context
                                    .read<HospitalFinderCubit>()
                                    .closeFacilityPopup(),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 20, color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            BlocListener<HospitalFinderCubit, HospitalFinderState>(
              listenWhen: (previous, current) =>
              previous.searchQuery != current.searchQuery,
              listener: (context, state) {
                if (state.searchQuery.trim().isNotEmpty &&
                    _sheetController.isAttached) {
                  _sheetController.animateTo(
                    0.65,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
              child: BlocBuilder<HospitalFinderCubit, HospitalFinderState>(
                buildWhen: (previous, current) =>
                previous.places != current.places ||
                    previous.historyPlaces != current.historyPlaces ||
                    previous.selectedCategory != current.selectedCategory ||
                    previous.searchQuery != current.searchQuery ||
                    previous.status != current.status,
                builder: (context, state) {
                  return DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: 0.08,
                    minChildSize: 0.08,
                    maxChildSize: 0.65,
                    snap: true,
                    snapSizes: const [0.08, 0.65],
                    snapAnimationDuration: const Duration(milliseconds: 200),
                    builder: (context, scrollController) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final sheetHeight = constraints.maxHeight;
                          final isMinimized = sheetHeight < 150;

                          return Container(
                            decoration: BoxDecoration(
                              color: UIColors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: ListView(
                              controller: scrollController,
                              physics: const ClampingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              children: [
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                if (!isMinimized) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _currentPage == 0
                                              ? const Color(0xFFFF3B30)
                                              : Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _currentPage == 1
                                              ? const Color(0xFFFF3B30)
                                              : Colors.grey[300],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (sheetHeight > 60)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: Text(
                                      _currentPage == 0
                                          ? 'suggested_title'.tr()
                                          : 'search_history_title'.tr(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  height: isMinimized ? 0 : sheetHeight - 120,
                                  child: PageView(
                                    controller: _pageController,
                                    onPageChanged: _onPageChanged,
                                    physics: const PageScrollPhysics(),
                                    children: [
                                      _buildPageContent(
                                        title: '',
                                        isMinimized: isMinimized,
                                        places: state.filteredPlaces,
                                      ),
                                      _buildPageContent(
                                        title: '',
                                        isMinimized: isMinimized,
                                        places: state.historyPlaces,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).padding.bottom),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const HospitalFinderQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent({
    required String title,
    required bool isMinimized,
    required List<MedicalPlace> places,
  }) {
    if (isMinimized) return const SizedBox.shrink();

    final limitedPlaces = places.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: limitedPlaces.isEmpty
              ? BlocBuilder<HospitalFinderCubit, HospitalFinderState>(
            builder: (context, state) {
              if (state.status == BlocStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: Text('no_places_found'.tr()),
              );
            },
          )
              : ListView.separated(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: limitedPlaces.length,
            separatorBuilder: (context, index) =>
            const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final place = limitedPlaces[index];
              return GestureDetector(
                onTap: () => context
                    .read<HospitalFinderCubit>()
                    .selectPlaceAndDrawRoute(place),
                child: MedicalPlaceCard(place: place),
              );
            },
          ),
        ),
      ],
    );
  }
}