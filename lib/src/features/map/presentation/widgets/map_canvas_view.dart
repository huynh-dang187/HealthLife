import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../common/constants/colors.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';

class MapCanvasView extends StatelessWidget {
  final MapController? mapController;
  const MapCanvasView({super.key, this.mapController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        final filteredPlaces = state.filteredPlaces;

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: state.currentLocation ?? const LatLng(10.7769, 106.7009), // TP.HCM
            initialZoom: 14.0,
            onTap: (_, __) => context.read<MapCubit>().closeFacilityPopup(),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.healthlife.app',
            ),
            // Vẽ đường đi (Polyline)
            if (state.routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: state.routePoints,
                    color: Colors.blueAccent,
                    strokeWidth: 5.0,
                    borderColor: Colors.white,
                    borderStrokeWidth: 2.0,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                // Vị trí hiện tại
                if (state.currentLocation != null)
                  Marker(
                    point: state.currentLocation!,
                    width: 30,
                    height: 30,
                    child: _buildCurrentLocationMarker(),
                  )
                else
                  Marker(
                    point: const LatLng(10.7769, 106.7009),
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Các Pins cơ sở y tế thật
                ...filteredPlaces.map((place) {
                  final isSelected = state.selectedPlace?.id == place.id;
                  return Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        try {
                          if (!context.mounted) return;
                          context.read<MapCubit>().showFacilityPopup(place);
                          if (mapController != null) {
                            mapController!.move(
                                LatLng(place.latitude, place.longitude), 15.0);
                          }
                        } catch (e) {
                          debugPrint('Error on Marker tap: $e');
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.redAccent : UIColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          place.category == 'Nhà thuốc'
                              ? Icons.local_pharmacy
                              : Icons.local_hospital,
                          color: isSelected ? UIColors.white : Colors.redAccent,
                          size: isSelected ? 26 : 20,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
