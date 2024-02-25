import 'package:flutter/material.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      bottomNavigationBar: const BottomAppBar(
        color: Colors.white,


      ),
      appBar: AppBar(

        backgroundColor: Colors.purple,
        title: const Text("Suraksha Sanket"),
        actions: [
          IconButton(
            onPressed: () {
              ap.userSignOut().then(
                    (value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple,
                backgroundImage: NetworkImage(ap.userModel.profilePic),
                radius: 50,
              ),
              const SizedBox(height: 20),
              Text(ap.userModel.name),
              Text(ap.userModel.phoneNumber),
              Text(ap.userModel.email),
              Text(ap.userModel.bio),
            ],
          )),
    );
  }
}
