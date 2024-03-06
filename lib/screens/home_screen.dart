import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/profile_screen.dart';
import 'package:help/screens/rescue_screen.dart';
import 'package:help/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:help/widgets/slidetoact.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;
  void navigateToRescueScreen() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context, // Pass current context from the widget
      PageTransition(
        type: PageTransitionType.fade, // Example transition type
        duration: const Duration(milliseconds: 200), // Adjust duration as needed
        child: const RescueScreen(), // Replace with your RescueScreen widget
      ),
    );
  }
  void navigateToProfileScreen() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context, // Pass current context from the widget
      PageTransition(
        type: PageTransitionType.fade, // Example transition type
        duration: const Duration(milliseconds: 200), // Adjust duration as needed
        child: const ProfileScreen(), // Replace with your RescueScreen widget
      ),
    );
  }
  bool isFinished = false;
  bool _animate = true;
  final _picker = ImagePicker();
  XFile? _imageFile;
  String? _currentAddress;
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Inform user and provide clear instructions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'To use location-based features, please enable location services in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings(); // Open system settings
                Navigator.of(context).pop();
              },
              child: const Text('Go to Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return false;
    }

    // Check and request location permission if service is enabled
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are denied'),
        ));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location permissions are permanently denied. Please go to settings to enable them.'),
      ));
      return false;
    }

    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        '${place.locality},\n ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imageFile = pickedFile;
      }
    });
  }






  void _showConfirmationBottomSheet() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_imageFile != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                    ),
                  ),
            const SizedBox(height: 10.0),
            if (_currentPosition != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 10,),
                  Text(
                    "${_currentPosition!.latitude.toStringAsFixed(3)},${_currentPosition!.longitude.toStringAsFixed(3)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                ],
              ),

            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Icons.call_outlined),
                 Text(ap.userModel.phoneNumber,style: const TextStyle(fontWeight: FontWeight.bold),),
               ],
            ),

            Padding(
              padding: const EdgeInsets.all(50.0),
              child:SlideAction(
                textColor: Colors.red,
                text: 'Send',
                borderRadius: 50,
                elevation: 0,
                innerColor: Colors.red[600],
                outerColor: Colors.red[100],
                onSubmit: (){
                  Navigator.push(
                    context, // Pass current context from the widget
                    PageTransition(
                      type: PageTransitionType.fade, // Example transition type
                      duration: const Duration(milliseconds: 200), // Adjust duration as needed
                      child: const RescueScreen(), // Replace with your RescueScreen widget
                    ),
                  );
                  return null;
                },
              ),
            )

          ],
        ),
      ),
    );
  }




  @override
    Widget build(BuildContext context) {
      final ap = Provider.of<AuthProvider>(context, listen: false);
      return Scaffold(

        appBar: AppBar(
          leading: SizedBox(
            child: Row(
              children: [
                IconButton(onPressed: _getCurrentPosition, icon: const Icon(Icons.my_location_outlined))
                ,
                Text(' ${_currentAddress ?? ""}')
              ],
            ),
          ),
          leadingWidth: 200,
          actions: [
            IconButton(
              onPressed:() => navigateToProfileScreen(),

              icon: CircleAvatar(
                backgroundColor: Colors.redAccent.shade100,
                backgroundImage: NetworkImage(ap.userModel.profilePic),
                radius: 20,
                child: ap.userModel.profilePic.isEmpty
                    ? const Icon(
                  Icons.person,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
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
            if (index == 1) { // Check if index corresponds to "Rescue" button (index 1)
              navigateToRescueScreen();
            } else {
              // Handle other actions for other button selections (optional)
            }
            setState(() {
              currentPageIndex = index;
            });
          },
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  AvatarGlow(
                    animate: _animate,
                    glowColor: Colors.red,
                    glowRadiusFactor: 0.5
                    ,
                    child: Material(
                        elevation: 8.0,
                        shape: const CircleBorder(),
                        child: SizedBox(
                          width: double.infinity,
                          height: 200,

                          child: ElevatedButton(
                              onPressed: () async {
                                await _captureImage();
                                await _getCurrentPosition();
                                if (_imageFile != null && _currentPosition != null) {
                                  _showConfirmationBottomSheet();
                                }
                              },
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<
                                    Color>(Colors.white),
                                backgroundColor: MaterialStateProperty.all<
                                    Color>(Colors.red.shade500),
                                shape: MaterialStateProperty.all<CircleBorder>(
                                  const CircleBorder(

                                  ),
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.sos, size: 100,),

                                ],
                              )

                          ),
                        )
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      );
    }
  }


