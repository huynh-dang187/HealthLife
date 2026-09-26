import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/enums/bloc_status.dart';
import '../../domain/entities/medical_place.dart';
import '../cubit/hospital_finder_cubit.dart';
import '../cubit/hospital_finder_state.dart';
import 'medical_place_card.dart';

class HospitalFinderPlaceList extends StatelessWidget {
  final bool isMinimized;
  final List<MedicalPlace> places;

  const HospitalFinderPlaceList({
    super.key,
    required this.isMinimized,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    if (isMinimized) return const SizedBox.shrink();

    final limitedPlaces = places.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: limitedPlaces.isEmpty
              ? BlocBuilder<HospitalFinderCubit, HospitalFinderState>(
                  builder: (context, state) {
                    if (state.status == BlocStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Center(
                      child: Text(
                        'no_places_found'.tr(),
                        style: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    );
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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