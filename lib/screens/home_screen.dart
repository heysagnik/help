import 'dart:io';
import 'dart:math';

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

  double generateRandomLatitude() {
    // Minimum and maximum latitude values for India (approximate)
    final minLat = 6.7404;
    final maxLat = 35.4238;
    return minLat + (maxLat - minLat) * Random().nextDouble();
  }

  double generateRandomLongitude() {
    // Minimum and maximum longitude values for India (approximate)
    final minLon = 68.1762;
    final maxLon = 97.2470;
    return minLon + (maxLon - minLon) * Random().nextDouble();
  }

  Map<String, dynamic> generateRandomCoordinates() {
    return {
      'latitude': generateRandomLatitude(),
      'longitude': generateRandomLongitude(),
    };
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
            // Prepare accident data
            final data = {
              'image': image, // Placeholder for image URL
              'phoneNumber': Provider.of<AuthProvider>(context, listen: false)
                  .userModel
                  .phoneNumber, // Assuming phone number is available
              'timeUploaded': DateTime.now(),
              'coordinates': generateRandomCoordinates(), // Add simulated coordinates
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
                        ),
                        if (pickedFile != null)
                          FutureBuilder<ImageProvider>(
                            future: getPreviewImage(pickedFile.path),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image(image: snapshot.data!);
                              } else if (snapshot.hasError) {
                                return Text('Error loading image preview');
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        Text(
                          'Phone number: ${Provider.of<AuthProvider>(context, listen: false).userModel.phoneNumber}\n',
                        ),
                        Text(
                            'Latitude: 28.5220332\n'
                            'Longitude: 77.2552968\n',
                          //'Latitude: ${generateRandomLatitude()}\n'
                              //'Longitude: ${generateRandomLongitude()}\n',
                        ),
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