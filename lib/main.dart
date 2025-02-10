import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kisanmitra/loginscreen.dart';
import 'splashscreen.dart';
import 'register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpScreen(),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:kisanmitra/loginscreen.dart';
// import 'splashscreen.dart';
//
// void main() {
//   runApp(const MyApp());
//   theme: ThemeData(
//     useMaterial3: true, // Ensure Material Icons work properly
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(primarySwatch: Colors.green),
//       home: Splash(),
//
//     );
//   }
// }
