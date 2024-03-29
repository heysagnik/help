import 'dart:async';

import 'package:flutter/material.dart';
import 'package:help/provider/auth_provider.dart';
import 'package:help/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:help/screens/welcome_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthProvider ap;
  double _logoScale = 1.0;

  @override
  void initState() {
    super.initState();
    ap = context.read<AuthProvider>();
    _animateLogo();
    _navigateAfterDelay();
  }

  void _animateLogo() async {
    const duration = Duration(milliseconds: 1500);
    const curve = Curves.easeInOut;

    while (mounted) {
      await Future.delayed(duration ~/ 2, () {
        setState(() {
          _logoScale = _logoScale == 1.0 ? 0.8 : 1.0;
        });
      });
      await Future.delayed(duration ~/ 2);
    }
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (ap.isSignedIn) {
        await ap.getDataFromSP();
      }

      Navigator.pushReplacement(
   context,
     MaterialPageRoute(
       builder: (context) =>
      ap.isSignedIn ? const HomeScreen() : const WelcomeScreen(),
     ),
  );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red[50],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: _logoScale,
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    "assets/logo.jpg",
                    height: 300,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Suraksha Sanket",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Safety ki Pukar, Instant Help ki Rahat ",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
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
