import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/permission_screen.dart';
import 'package:help/screens/user_information_screen.dart';
import 'package:help/screens/welcome_screen.dart';
import 'package:help/widgets/custom_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:updater/updater.dart';


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

      appBar: AppBar(

        title: const Text("Settings",),
      ),
      body: Center(

          child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              margin: const EdgeInsets.all(10.0),
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.green[50], // Use white background for better contrast
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Add padding for better spacing
                child: Column(
                  children: [
                    Row( // First row with logo, app name, and edit icon
                      children: [
                        Image.asset(
                          "assets/logo.jpg",
                          height: 36,
                        ),
                        const SizedBox(width: 10.0),
                        const Text(
                          'SURAKSHA ID',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context, // Pass current context from the widget
                              PageTransition(
                                type: PageTransitionType.fade, // Example transition type
                                duration: const Duration(milliseconds: 200), // Adjust duration as needed
                                child: const UserInfromationScreen(), // Replace with your RescueScreen widget
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0), // Add spacing between rows
                    Row( // Second row with profile picture, user information
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.redAccent.shade100,
                          backgroundImage: NetworkImage(ap.userModel.profilePic),
                          radius: 30,
                        ),
                        const SizedBox(width: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align text left
                          children: [
                            Row( // Row for "Name:" and name
                              children: [
                                const Icon(Icons.badge_outlined,color: Colors.grey,size: 20,),
                                const SizedBox(width: 5.0), // Add a small space between label and value
                                Text(
                                  ap.userModel.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5.0), // Add spacing between rows within the Column
                            Row( // Row for "Phone Number:" and phone number
                              children: [
                                const Icon(Icons.call_outlined,color: Colors.grey,size: 20,),
                                const SizedBox(width: 5.0),
                                Text(
                                  ap.userModel.phoneNumber,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5.0), // Add spacing between rows within the Column
                            const Row( // Row for "Blood Type:" and blood type
                              children: [
                                Icon(Icons.bloodtype,color: Colors.grey,size: 20,),
                                SizedBox(width: 5.0),
                                Text(
                                  "B+", // Replace with ap.userModel.bloodType if it's available
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 20,),
            InkWell(

              onTap: (){},
              //borderRadius: BorderRadius.circular(10.0),
              child: const SizedBox(
                height:50,
                child: Row(
                  children: [
                    SizedBox(width: 20.0),
                    Icon(
                      Icons.brush_outlined,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 16.0,

                      ),
                    ),
                  ],
                ),
              ),

            ),
            const SizedBox(height: 10,),
            InkWell(

              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PermissionsScreen(),
                  )
                );
              },
              //borderRadius: BorderRadius.circular(10.0),
              child: const SizedBox(
                height:50,
                child: Row(
                  children: [
                    SizedBox(width: 20.0),
                    Icon(
                      Icons.token_outlined,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Permissions',
                      style: TextStyle(
                        fontSize: 16.0,

                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10,),
            InkWell(

              onTap: (){},
              //borderRadius: BorderRadius.circular(10.0),
              child: const SizedBox(
                height:50,
                child: Row(
                  children: [
                    SizedBox(width: 20.0),
                    Icon(
                      Icons.book_outlined,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16.0,

                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10,),
            InkWell(

              onTap: (){},
              //borderRadius: BorderRadius.circular(10.0),
              child: const SizedBox(
                height:50,
                child: Row(
                  children: [
                    SizedBox(width: 20.0),
                    Icon(
                      Icons.circle_outlined,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Suraksha Sanket',
                      style: TextStyle(
                        fontSize: 16.0,

                      ),
                    ),
                    Text(
                      'v1.0',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10,),
            InkWell(
              onTap: (){
                  ap.userSignOut().then(
                        (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    ),
                  );
              },
              child: SizedBox(
                height:50,
                child: Row(
                  children: [
                    const SizedBox(width: 20.0),
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.redAccent.shade200,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16.0,
                        color:Colors.redAccent.shade200,
                      ),
                    ),
                  ],
                ),
              ),

            )
          ],
        ),
          ),
    );
  }
}

