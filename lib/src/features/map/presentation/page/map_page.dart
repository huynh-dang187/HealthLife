import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../common/constants/colors.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../widgets/map_canvas_view.dart';
import '../widgets/map_search_header.dart';
import '../widgets/medical_place_card.dart';
import '../widgets/map_quick_actions.dart';
import '../../domain/entities/medical_place.dart';
import '../../../../shared/enums/bloc_status.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapCubit(),
      child: const _MapBody(),
    );
  }
}

class _MapBody extends StatefulWidget {
  const _MapBody();

  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  late PageController _pageController;
  late MapController _mapController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _mapController = MapController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    final cubit = context.read<MapCubit>();
    if (page == 0) {
      cubit.selectCategory('Gần nhất');
    } else {
      cubit.selectCategory('Lịch sử');
    }
  }

  Future<void> _handleMyLocation() async {
    final cubit = context.read<MapCubit>();
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
    if (message.contains('GPS đang tắt')) {
      return SnackBarAction(
        label: 'Bật GPS',
        onPressed: () => Geolocator.openLocationSettings(),
      );
    } else if (message.contains('Cài đặt ứng dụng')) {
      return SnackBarAction(
        label: 'Cài đặt',
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
                const MapSearchHeader(),
                Expanded(
                  child: MapCanvasView(mapController: _mapController),
                ),
              ],
            ),

            BlocBuilder<MapCubit, MapState>(
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        ),
                      )
                          : const Icon(Icons.my_location,
                          color: Colors.blueAccent),
                    ),
                  ),
                );
              },
            ),

            BlocBuilder<MapCubit, MapState>(
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
                            context.read<MapCubit>().closeFacilityPopup(),
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
                            MedicalPlaceCard(place: state.activePopupFacility),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: GestureDetector(
                                onTap: () => context
                                    .read<MapCubit>()
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

            BlocBuilder<MapCubit, MapState>(
              buildWhen: (previous, current) =>
              previous.places != current.places ||
                  previous.selectedCategory != current.selectedCategory ||
                  previous.status != current.status,
              builder: (context, state) {
                return DraggableScrollableSheet(
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
                                  margin:
                                  const EdgeInsets.symmetric(vertical: 8),
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
                                        ? 'Gợi ý Bệnh viện & Nhà thuốc'
                                        : 'Lịch sử tìm kiếm',
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
                                      places: state.places,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height:
                                  MediaQuery.of(context).padding.bottom),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),

            const MapQuickActions(),
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
          child: places.isEmpty
              ? BlocBuilder<MapCubit, MapState>(
            builder: (context, state) {
              if (state.status == BlocStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(
                child: Text('Không tìm thấy cơ sở y tế nào gần đây.'),
              );
            },
          )
              : ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            itemCount: places.length,
            separatorBuilder: (context, index) =>
            const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final place = places[index];
              return GestureDetector(
                onTap: () => context
                    .read<MapCubit>()
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