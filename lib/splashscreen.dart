import 'dart:async';  // Import for Timer
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register.dart';
import 'loginscreen.dart';

class Splash extends StatefulWidget {  // Change to StatefulWidget
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();

    // Timer for 5 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpScreen()),  // Navigate to HomeScreen
      );
    });
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
              "assets/splashscreen/screen.png",
              width: 200,
              height: 200,
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