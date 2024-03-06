import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/home_screen.dart';
import 'package:help/screens/profile_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RescueScreen extends StatefulWidget {
  const RescueScreen({super.key});

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  int currentPageIndex = 1;
  void navigateToRescueScreen() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context, // Pass current context from the widget
      PageTransition(
        type: PageTransitionType.fade, // Example transition type
        duration: const Duration(milliseconds: 200), // Adjust duration as needed
        child: const HomeScreen(), // Replace with your RescueScreen widget
      ),
    );
  }

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Handle permanently denied permission
        return Future.error('Location permission denied forever');
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
            icon: Icon(Icons.emergency,), label: 'Emergency'),
        NavigationDestination(icon: Icon(Icons.support), label: 'Rescue'),
      ],
      selectedIndex: currentPageIndex,
      onDestinationSelected: (index) {
        if (index == 0) { // Check if index corresponds to "Rescue" button (index 1)
          navigateToRescueScreen();
        } else {
          // Handle other actions for other button selections (optional)
        }
        setState(() {
          currentPageIndex = index;
        });
      },
    ),
      body: const SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child:Card(
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.all(8.0),
                  child: SizedBox.expand(
                    child: Center(
                      child: Text(
                        'MAPS',
                        style: TextStyle(fontSize: 24,),
                      ),
                    ),
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

