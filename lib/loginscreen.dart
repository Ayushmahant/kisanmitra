import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'register.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                      ),
                    ],
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
                          controller: _usernameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Name",
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
             // SizedBox(height: 30),
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: MaterialButton(
                  onPressed: () {}, // No logic added yet
                  color: Color.fromRGBO(49, 39, 79, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  height: 50,
                  minWidth: double.infinity,
                  child: Text(
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
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
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
