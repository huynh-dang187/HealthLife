import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../common/constants/colors.dart';
import '../cubit/hospital_finder_cubit.dart';
import '../cubit/hospital_finder_state.dart';
import '../widgets/hospital_finder_bottom_sheet.dart';
import '../widgets/hospital_finder_canvas_view.dart';
import '../widgets/hospital_finder_facility_popup.dart';
import '../widgets/hospital_finder_location_button.dart';
import '../widgets/hospital_finder_quick_actions.dart';
import '../widgets/hospital_finder_search_header.dart';

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
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: UIColors.white,
      ),
      child: Scaffold(
        backgroundColor: UIColors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const HospitalFinderSearchHeader(),
                  Expanded(
                    child: HospitalFinderCanvasView(
                      mapController: _mapController,
                    ),
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
                    child: HospitalFinderLocationButton(
                      isLoading: state.isLoadingLocation,
                      onTap: _handleMyLocation,
                    ),
                  );
                },
              ),
              BlocBuilder<HospitalFinderCubit, HospitalFinderState>(
                buildWhen: (p, c) =>
                    p.activePopupFacility != c.activePopupFacility ||
                    p.isQuickMenuOpen != c.isQuickMenuOpen,
                builder: (context, state) {
                  if (state.activePopupFacility == null ||
                      state.isQuickMenuOpen) {
                    return const SizedBox.shrink();
                  }

                  return HospitalFinderFacilityPopup(
                    place: state.activePopupFacility!,
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

                            return HospitalFinderBottomSheet(
                              scrollController: scrollController,
                              pageController: _pageController,
                              isMinimized: isMinimized,
                              sheetHeight: sheetHeight,
                              currentPage: _currentPage,
                              filteredPlaces: state.filteredPlaces,
                              historyPlaces: state.historyPlaces,
                              onPageChanged: _onPageChanged,
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
      ),
    );
  }
}