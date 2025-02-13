import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'splashscreen.dart';
import 'register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(const MyApp()); // Run the app after Firebase is initialized
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kisan Mitra',
      theme: ThemeData(
        primarySwatch: Colors.green, // Use Material 3
        useMaterial3: true, // Ensure Material Icons work properly
      ),
      // Choose the starting screen here:
      home: Splash(), // Replace with the desired starting page, e.g., HomePage() or SignUpScreen()
      debugShowCheckedModeBanner: false,
    );
  }
}
