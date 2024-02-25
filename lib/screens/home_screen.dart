import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/profile_screen.dart';
import 'package:image_picker/image_picker.dart';


import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<EmergencyButtonData> _buttons = [
    EmergencyButtonData(icon: Icons.car_crash_outlined, label: 'Ambulance', color: Colors.red.shade400),
    EmergencyButtonData(icon: Icons.local_police_outlined, label: 'Police', color: Colors.blue.shade400),
    EmergencyButtonData(icon: Icons.fire_truck_outlined, label: 'Fire', color: Colors.orange.shade400),
    EmergencyButtonData(icon: Icons.group, label: 'Abuse', color: Colors.green.shade400),
  ];

  Future<FileImage> getPreviewImage(String filePath) async {
    final file = File(filePath);
    return FileImage(file);
  }
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/logo.jpg", width:56),
        leadingWidth: 100,
        titleSpacing: 0,
        title: const Text("Suraksha Sanket"),
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
                Icons.person, // Replace with your desired fallback icon
                color: Colors.white,
              )
                  : null,
            ),
          ),
          const SizedBox(width: 10,)
        ],

      ),
      body:  SafeArea(
        child:
        Padding(
          padding: const EdgeInsets.only(top: 50,right: 20,left: 20),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1, // Ensure equal width and height for square buttons
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: _buttons.map((buttonData) => buildEmergencyButton(buttonData)).toList(),
          ),
        ),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final pickedFile = await _picker.pickImage(source: ImageSource.camera);
          if (pickedFile != null) {
            var image = File(pickedFile.path);
            try {
              // Get current location
              //final position = await Geolocator.getCurrentPosition();

              // Prepare accident data
              final data = {
                'image': image, // Placeholder for image URL
                //'latitude': position.latitude,
                //'longitude': position.longitude,
                'phoneNumber': ap.userModel.phoneNumber, // Assuming phone number is available
                'timeUploaded': DateTime.now(),
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
                            //'Latitude: ${position.latitude}\n'
                            // 'Longitude: ${position.longitude}\n'
                            'Phone number: ${ap.userModel.phoneNumber}\n',
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
        child: const Icon(Icons.camera_alt),
      ),

    );
  }
}



Widget buildEmergencyButton(EmergencyButtonData buttonData) {
  return InkWell(
    onTap: () {}, // Replace with your on-tap action
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
            Text(buttonData.label, style: const TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    ),
  );
}


class EmergencyButtonData {
  final IconData icon;
  final String label;
  final Color color;

  const EmergencyButtonData({required this.icon, required this.label, required this.color});
}