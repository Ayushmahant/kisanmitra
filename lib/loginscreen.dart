import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
import 'insidepages/Customer_Dashboard.dart';
import 'bottomnavbar.dart';
import 'splashscreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      String input = _emailPhoneController.text.trim();
      String password = _passwordController.text.trim();

      UserCredential userCredential;

      if (input.contains('@')) {
        // Login with Email & Password
        userCredential = await _auth.signInWithEmailAndPassword(
          email: input,
          password: password,
        );

        // Save login state after successful email login
        await _saveLoginState();
        navigateToHomePage();
      } else {
        // Handle phone number authentication
        String phoneNumber = input.trim();

        // Append India country code (+91) if not present
        if (!phoneNumber.startsWith('+91')) {
          phoneNumber = '+91' + phoneNumber;
        }

        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            // Save login state after successful phone login
            await _saveLoginState();
            navigateToHomePage();
          },
          verificationFailed: (FirebaseAuthException e) {
            showError(e.message ?? "Phone number verification failed");
          },
          codeSent: (String verificationId, int? resendToken) {
            _showSmsCodeDialog(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Login failed");
    } catch (e) {
      showError("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> _showSmsCodeDialog(String verificationId) async {
    String smsCode = '';
    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter the SMS Code"),
          content: TextField(
            onChanged: (value) {
              smsCode = value;
            },
            decoration: InputDecoration(hintText: 'Enter SMS Code'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: verificationId,
                  smsCode: smsCode,
                );

                await _auth.signInWithCredential(credential);
                // Save login state after successful SMS verification
                await _saveLoginState();
                navigateToHomePage();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      _createRoute(MajorPage()),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
          FadeInUp(
          duration: Duration(milliseconds: 1500),
          child: Text(
            "Login",
            style: TextStyle(
              fontFamily: 'Bebas Neue',
              color: Color.fromRGBO(49, 39, 79, 1),
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        SizedBox(height: 50),
        FadeInUp(
          duration: Duration(milliseconds: 1000),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(
                  color: Color.fromRGBO(196, 135, 198, .3),
                ),
                boxShadow: [
            BoxShadow(
            color: Color.fromRGBO(196, 135, 198, .3),
            blurRadius: 20,
            offset: Offset(0, 10),
            )],
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromRGBO(196, 135, 198, .3),
                    ),
                  ),
                ),
                child: TextField(
                  controller: _emailPhoneController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email or Phone Number",
                    hintStyle: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 50),
      FadeInUp(
        duration: Duration(milliseconds: 1000),
        child: TextButton(
          onPressed: () {},
          child: Text(
            "Forgot Password?",
            style: TextStyle(color: Color.fromRGBO(196, 135, 198, 1)),
          ),
        ),
      ),
      FadeInUp(
        duration: Duration(milliseconds: 1000),
        child: MaterialButton(
          onPressed: loginUser,
          color: Color.fromRGBO(49, 39, 79, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          height: 50,
          minWidth: double.infinity,
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
            "Login",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      SizedBox(height: 30),
      FadeInUp(
        duration: Duration(milliseconds: 1000),
        child: TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              _createRoute(SignUpScreen()),
            );
          },
          child: Text(
            "Create Account",
            style: TextStyle(color: Color.fromRGBO(49, 39, 79, .6)),
          ),
        ),
      ),
      ],
    ),
    ),
    ),
    );
  }
}

Route _createRoute(Widget child) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}