import 'package:flutter/material.dart';
import 'package:kisanmitra/loginscreen.dart';
import 'bottomnavbar.dart';
import 'splashscreen.dart';

void main() {
  runApp(const MyApp());
  theme: ThemeData(
    useMaterial3: true, // Ensure Material Icons work properly
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Splash(),

    );
  }
}
