import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/home_screen.dart';
import 'package:help/provider/location_service.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RescueScreen extends StatefulWidget {
  const RescueScreen({super.key});

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  int currentPageIndex = 1;
  LatLng? _currentLocation;
  LatLng? _nearestStation;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (await _locationService.handleLocationPermission()) {
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        LatLng? nearestStation =
            await _locationService.getNearestPoliceStation(position);
        if (nearestStation != null) {
          setState(() {
            _nearestStation = nearestStation;
          });
        }
      }
    }
  }

  void navigateToRescueScreen() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 200),
        child: const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.grey.shade50,
        indicatorColor: Colors.red.shade400,
        animationDuration: const Duration(milliseconds: 100),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.emergency), label: 'Emergency'),
          NavigationDestination(icon: Icon(Icons.support), label: 'Rescue'),
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            navigateToRescueScreen();
          }
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Card(
                  shadowColor: Colors.transparent,
                  margin: const EdgeInsets.all(8.0),
                  child: _currentLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          options: MapOptions(
                            center: _currentLocation,
                            zoom: 15.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentLocation!,
                                  width: 80.0,
                                  height: 80.0,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40.0,
                                  ),
                                ),
                                if (_nearestStation != null)
                                  Marker(
                                    point: _nearestStation!,
                                    width: 80.0,
                                    height: 80.0,
                                    child: const Icon(
                                      Icons.local_police,
                                      color: Colors.blue,
                                      size: 40.0,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
