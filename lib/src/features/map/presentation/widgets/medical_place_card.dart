import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/constants/colors.dart';
import '../../domain/entities/medical_place.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';

class MedicalPlaceCard extends StatelessWidget {
  final MedicalPlace? place;
  const MedicalPlaceCard({super.key, this.place});

  @override
  Widget build(BuildContext context) {
    if (place != null) {
      return _buildCard(context, place!);
    }

    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        final selectedPlace = state.selectedPlace;
        if (selectedPlace == null) return const SizedBox.shrink();
        return _buildCard(context, selectedPlace);
      },
    );
  }

  Widget _buildCard(BuildContext context, MedicalPlace place) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: UIColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hospital Thumbnail
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(
                        place.category == 'Nhà thuốc'
                            ? 'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?q=80&w=2070&auto=format&fit=crop'
                            : 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?q=80&w=2053&auto=format&fit=crop',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Hospital Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Địa chỉ: ${place.address}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Khoảng cách: ${place.distanceKm} km',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Đánh giá: ${place.rating}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // CTA Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=driving');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.directions_car, color: UIColors.white),
                    label: const Text('Chỉ đường'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34C759), // Green
                      foregroundColor: UIColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Call phone logic
                    },
                    icon: const Icon(Icons.phone, color: UIColors.white),
                    label: const Text('Gọi điện'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30), // Red/Orange
                      foregroundColor: UIColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
