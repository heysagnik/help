import 'package:flutter/material.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/profile_screen.dart';
import 'package:help/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/logo.jpg"),
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
      body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {  },
        backgroundColor: Colors.red.shade50,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
