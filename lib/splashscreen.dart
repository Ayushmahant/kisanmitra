import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginscreen.dart';
import 'bottomnavbar.dart'; // Assuming this is your home screen

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4)); // Simulate splash delay

    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Navigate to Home if logged in, otherwise go to LoginScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn ? MajorPage() : HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 254, 210),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              width: 400,
              height: 400,
            ),
            const SizedBox(height: 100),
            Lottie.asset(
              "assets/animations/Animation - 1738948259531.json",
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
