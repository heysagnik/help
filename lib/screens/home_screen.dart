import 'dart:io';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/profile_screen.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<EmergencyButtonData> _buttons = [
    EmergencyButtonData(
        icon: Icons.car_crash_outlined,
        label: 'Ambulance',
        color: Colors.red.shade400),
    EmergencyButtonData(
        icon: Icons.local_police_outlined,
        label: 'Police',
        color: Colors.blue.shade400),
    EmergencyButtonData(
        icon: Icons.fire_truck_outlined,
        label: 'Fire',
        color: Colors.orange.shade400),
    EmergencyButtonData(
        icon: Icons.group, label: 'Abuse', color: Colors.green.shade400),
  ];

  Future<FileImage> getPreviewImage(String filePath) async {
    final file = File(filePath);
    return FileImage(file);
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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }


  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/logo.jpg", width: 56),
        leadingWidth: 100,
        titleSpacing: 0,
        title: const Text("HELP"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
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
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.asset('assets/map.jpeg'),
            ),
            Expanded( // Wrap GridView with Expanded
              child: Padding(
                padding: const EdgeInsets.only(top: 50,right: 20, left: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  // Ensure equal width and height for square buttons
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: _buttons
                      .map((buttonData) => buildEmergencyButton(context, buttonData))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmergencyButton(
      BuildContext context, EmergencyButtonData buttonData) {
    return InkWell(
      onTap: () async {
        final pickedFile = await _picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          var image = File(pickedFile.path);
          try {
            // Get current location
            final position = await getCurrentLocation();
            final latitude = position.latitude;
            final longitude = position.longitude;
            // Prepare accident data
            final data = {
              'image': image, // Placeholder for image URL
              'phoneNumber': Provider.of<AuthProvider>(context, listen: false)
                  .userModel
                  .phoneNumber, // Assuming phone number is available
              'timeUploaded': DateTime.now(),
              'coordinates': GeoPoint(latitude, longitude),// Add  coordinates
            };


            // Show confirmation dialog
            final confirmed = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm Upload'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Are you sure you want to upload the following data?\n\n',
                          textAlign: TextAlign.left, // Ensure phone number is left-aligned
                        ),
                        if (pickedFile != null)
                          FutureBuilder<ImageProvider>(
                            future: getPreviewImage(pickedFile.path),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ClipRRect(  // Add ClipRRect for rounded corners
                                  borderRadius: BorderRadius.circular(10.0),  // Set border radius
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4,  // Set aspect ratio to 3:4
                                    child: Image(
                                      image: snapshot.data!,
                                      fit: BoxFit.cover,  // Adjust fit if needed
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Text('Error loading image preview');
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        Text(
                          '\n Phone number: ${Provider.of<AuthProvider>(context, listen: false).userModel.phoneNumber}           \n',
                          textAlign: TextAlign.left, // Maintain left alignment
                        ),
                        Text('Coordinates: $latitude, $longitude'),
                      ],
                    ),
                  ),

                actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Send'),
                    ),
                  ],
                );
              },
            );

            if (confirmed ?? false) {
              // Upload image and data if confirmed
              // ... (same upload logic as before)
            }
          } catch (error) {
            // Handle errors
            print(error);
          }
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: 50.0, // Set a specific height for consistency
          color: buttonData.color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(buttonData.icon, size: 30, color: Colors.white),
              const SizedBox(height: 10),
              Text(buttonData.label,
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyButtonData {
  final IconData icon;
  final String label;
  final Color color;

  const EmergencyButtonData(
      {required this.icon, required this.label, required this.color});
}