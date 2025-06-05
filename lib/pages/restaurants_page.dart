import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ordrmate/components/branch_info_sheet.dart';
import 'package:ordrmate/components/restaurant_map.dart';
import 'package:ordrmate/models/Branch.dart';
import 'package:ordrmate/services/restaurant_service.dart';
import '../ui/theme/app_theme.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {

  final RestaurantService restaurantService = RestaurantService();

  List<Branch> _branches = [];
  bool isLoading = true;
  String? errorMessage;
  LatLng? userLocation;
  MapController mapController = MapController();
  final zoomLevel = 13.0;

  @override
  void initState() {
    super.initState();
    loadBranches();
    getCurrentLocation();
  }

  Future<void> loadBranches() async {
    try {
      final branches = await restaurantService.getAllBranches();
        debugPrint('Loaded branches: ${branches.length}');
      setState(() {
        _branches = branches;
        isLoading = false;
      });
    }
    catch (e) {
      setState(() {
        errorMessage = 'Failed to load branches: $e';
        isLoading = false;
      });
    }
  }

  Future<void> getCurrentLocation() async {
    try{
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
      });

    }
    catch (e) {
      setState(() {
        errorMessage = 'Failed to get current location: $e';
      });
    }
  }

  void _handleBranchTap(Branch branch) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BranchInfoSheet(
        branch: branch,
        onClose: () => Navigator.pop(context),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingM),
              ElevatedButton(
                onPressed: loadBranches,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.surfaceColor,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          RestaurantMap(
            branches: _branches,
            currentLocation: userLocation,
            mapController: mapController,
            onBranchTap: _handleBranchTap,
          ),
        ],
      ),
    );
  }
}