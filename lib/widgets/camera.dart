import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPermission extends StatefulWidget {
  const CameraPermission({super.key});

  @override
  State<CameraPermission> createState() => _CameraPermissionState();
}

class _CameraPermissionState extends State<CameraPermission> {
  File? image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickerImage = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickerImage != null) {
        image = File(pickerImage.path);
      } else {
        print("no Image selected");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image == null)
              ElevatedButton(
                onPressed: () {
                  getImage();
                },
                child: const Icon(Icons.camera, color: Colors.red),
              )
            else
              Column(
                children: [
                  Image.file(image!),
                  ElevatedButton(
                    onPressed: () {
                      // Implement send functionality here
                    },
                    child: const Icon(Icons.send_rounded, color: Colors.green),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}