import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/Branch.dart';
import '../ui/theme/app_theme.dart';

class RestaurantMap extends StatelessWidget {
  final List<Branch> branches;
  final LatLng? currentLocation;
  final MapController mapController;
  final Function(Branch) onBranchTap;

  const RestaurantMap({
    super.key,
    required this.branches,
    required this.currentLocation,
    required this.mapController,
    required this.onBranchTap,
  });

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) return const SizedBox.shrink();

    double avgLat = branches.map((b) => b.latitude).reduce((a, b) => a + b) / branches.length;
    double avgLng = branches.map((b) => b.longitude).reduce((a, b) => a + b) / branches.length;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: currentLocation ?? LatLng(avgLat, avgLng),
        zoom: 12.0,
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'com.ordrmate.customer',
        ),

        MarkerLayer(
          rotate: false,
          markers: [
            if (currentLocation != null)
              Marker(
                point: currentLocation!,
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.secondaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ...branches.map((branch) {
              return Marker(
                point: LatLng(branch.latitude, branch.longitude),
                width: 110,
                height: 54,
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onBranchTap(branch),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingS),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.restaurant,
                              color: AppTheme.surfaceColor,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}