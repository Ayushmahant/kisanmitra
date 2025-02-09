import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino icons
import 'package:google_fonts/google_fonts.dart';
import 'loginscreen.dart'; // Import the Login screen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String selectedRole = "Farmer"; // Default selection
  final TextEditingController aadhaarController = TextEditingController();
  String? aadhaarError;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            width: double.infinity,
            child: Column(
              children: [
                // Top image section
                Container(
                  height: size.height * 0.1, // Reduced height
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/check.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // Form Section
                Container(
                  width: double.infinity,

                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const SizedBox(height: 20),
                        Text(
                          "Register Yourself",
                          style: GoogleFonts.bebasNeue(fontSize: 32),
                        ),
                        const SizedBox(height: 20),

                        Text("Select Your Role",style: TextStyle(fontSize: 15,fontWeight:FontWeight.w600),),

                        const SizedBox(height: 10),

                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedRole,
                              icon: const Icon(CupertinoIcons.chevron_down, color: Colors.blue),
                              items: ["Farmer", "Customer"].map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role, style: const TextStyle(fontSize: 16)),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedRole = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Name field
                        RoundedInputField(
                          hintText: "Name",
                          icon: CupertinoIcons.person,
                        ),
                        // Password field
                        const RoundedPasswordField(),
                        // Aadhaar card field
                        AadhaarInputField(
                          controller: aadhaarController,
                          errorText: aadhaarError,
                          onChanged: (value) {
                            setState(() {
                              if (value.length == 12) {
                                aadhaarError = null; // No error if exactly 12 digits
                              } else {
                                aadhaarError = "Aadhaar number must be 12 digits";
                              }
                            });
                          },
                        ),
                        RoundedButton(
                          text: "REGISTER",
                          press: () {
                            if (aadhaarController.text.length != 12) {
                              setState(() {
                                aadhaarError = "Aadhaar number must be 12 digits";
                              });
                            } else {
                              // Proceed with registration
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Already have an account? Login here",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
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

// Aadhaar Input Field with Validation
class AadhaarInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final Function(String) onChanged;

  const AadhaarInputField({
    Key? key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 12, // Limits input to 12 digits
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: const Icon(CupertinoIcons.number, color: Colors.blue),
          hintText: "Aadhaar Number",
          border: InputBorder.none,
          counterText: "", // Hides character count indicator
          errorText: errorText, // Shows validation message
        ),
      ),
    );
  }
}

// Rounded Button
class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final Color color, textColor;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = Colors.blue,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
    );
  }
}

// Rounded Input Field
class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;

  const RoundedInputField({
    Key? key,
    required this.hintText,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.blue),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// Rounded Password Field
class RoundedPasswordField extends StatefulWidget {
  const RoundedPasswordField({Key? key}) : super(key: key);

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        obscureText: _isHidden,
        decoration: InputDecoration(

          icon: const Icon(CupertinoIcons.lock_fill, color: Colors.blue),
          hintText: "Password",
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              _isHidden ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
              color: Colors.blue,
            ),
            onPressed: () {
              setState(() {
                _isHidden = !_isHidden;
              });
            },
          ),
        ),
      ),
    );
  }
}
