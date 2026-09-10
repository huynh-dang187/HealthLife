import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../../common/constants/colors.dart';
import '../../domain/entities/medical_place.dart';
import '../cubit/hospital_finder_cubit.dart';

class HospitalDetailSheet extends StatelessWidget {
  final MedicalPlace place;
  final LatLng? currentLocation;

  const HospitalDetailSheet({
    super.key,
    required this.place,
    this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: UIColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UIColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(place.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(place.category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  place.address,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.directions_walk, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                "Cách bạn ${place.distanceKm} km",
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: UIColors.black),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Nút Chỉ đường & Gọi điện
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<HospitalFinderCubit>().makePhoneCall(place),
                  icon: const Icon(Icons.phone, color: Colors.green),
                  label: const Text("Gọi điện"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.read<HospitalFinderCubit>().openExternalMaps(place),
                  icon: const Icon(Icons.directions_car, color: UIColors.white),
                  label: const Text(
                    "Chỉ đường",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34C759),
                    foregroundColor: UIColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Nhà thuốc':
        return Colors.orange;
      case 'Bệnh viện':
        return Colors.redAccent;
      case 'Phòng khám':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}