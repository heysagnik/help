import 'package:flutter/material.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/welcome_screen.dart';
import 'package:help/widgets/custom_button.dart';
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
      appBar: AppBar(

        backgroundColor: Colors.redAccent.shade100,
        title: const Text("HELP"),
      ),
      body: Center(
        child:Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircleAvatar(
              backgroundColor: Colors.purple,
              backgroundImage: NetworkImage(ap.userModel.profilePic),
              radius: 50,
            ),
            const SizedBox(height: 20),
            Text(ap.userModel.name,style: const TextStyle(
              fontSize: 20,

            ),),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CustomButton(
                onPressed: (){}, text: 'Edit Details',
              ),),

            const SizedBox(height: 20.0),
            const Divider(thickness: 1.0),
            const SizedBox(height: 20.0),
            const Row(
              children: [
                Icon(
                  Icons.settings,
                ),
                SizedBox(width: 20.0),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward,
                )
              ],
            ),
            const SizedBox(height: 20.0),
            const Divider(thickness: 1.0),
            const SizedBox(height: 20.0),
            const Row(
              children: [
                Icon(
                  Icons.info,
                ),
                SizedBox(width: 20.0),
                Text(
                  'About Us',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward,
                )
              ],
            ),
            const SizedBox(height: 20.0),
            const Divider(thickness: 1.0),
            const SizedBox(height: 20.0),
            const Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                ),
                SizedBox(width: 20.0),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Spacer(),



              ],
            ),
          ],
        ),
        )
          ),
    );
  }
}
