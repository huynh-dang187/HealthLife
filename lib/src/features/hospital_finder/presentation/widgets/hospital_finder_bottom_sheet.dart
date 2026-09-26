import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../../domain/entities/medical_place.dart';
import 'hospital_finder_place_list.dart';

class HospitalFinderBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final PageController pageController;
  final bool isMinimized;
  final double sheetHeight;
  final int currentPage;
  final List<MedicalPlace> filteredPlaces;
  final List<MedicalPlace> historyPlaces;
  final ValueChanged<int> onPageChanged;

  const HospitalFinderBottomSheet({
    super.key,
    required this.scrollController,
    required this.pageController,
    required this.isMinimized,
    required this.sheetHeight,
    required this.currentPage,
    required this.filteredPlaces,
    required this.historyPlaces,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UIColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.1),
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
                    color: currentPage == 0
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
                    color: currentPage == 1
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                currentPage == 0
                    ? 'suggested_title'.tr()
                    : 'search_history_title'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: UIColors.black,
                ),
              ),
            ),
          SizedBox(
            height: isMinimized ? 0 : sheetHeight - 120,
            child: PageView(
              controller: pageController,
              onPageChanged: onPageChanged,
              physics: const PageScrollPhysics(),
              children: [
                HospitalFinderPlaceList(
                  isMinimized: isMinimized,
                  places: filteredPlaces,
                ),
                HospitalFinderPlaceList(
                  isMinimized: isMinimized,
                  places: historyPlaces,
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}