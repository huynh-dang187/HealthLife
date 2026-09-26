import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/colors.dart';
import '../../domain/entities/medical_place.dart';
import '../cubit/hospital_finder_cubit.dart';
import 'medical_place_card.dart';

class HospitalFinderFacilityPopup extends StatelessWidget {
  final MedicalPlace place;

  const HospitalFinderFacilityPopup({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => context.read<HospitalFinderCubit>().closeFacilityPopup(),
            child: Container(
              color: UIColors.black.withValues(alpha: 0.2),
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
                MedicalPlaceCard(place: place),
                Positioned(
                  top: -10,
                  right: -10,
                  child: GestureDetector(
                    onTap: () =>
                        context.read<HospitalFinderCubit>().closeFacilityPopup(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: UIColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}