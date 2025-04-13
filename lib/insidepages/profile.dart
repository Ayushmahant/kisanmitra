import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisanmitra/loginscreen.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "Ayush mahant";
  String _email = "ayushmahant@gmail.com";
  String _mobile = "+91 7758099669";
  String _role = "customer"; // Can be "customer" or "farmer"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient background section from top to divider
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green.shade900,
                    Colors.green.shade500,
                    Colors.green.shade200,
                  ],
                ),
              ),
              padding: const EdgeInsets.only(top: 100, bottom: 40),
              child: Column(
                children: [
                  // Profile header
                  Center(
                    child: Column(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 100,  // Double the radius for full coverage
                            height: 100,
                            child: Image.asset(
                              "assets/user.png",
                              fit: BoxFit.contain,  // This will make the image fill the space
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          _name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Rest of the content
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  _buildSectionTitle('Personal Information'),
                  _buildInfoRow(Icons.person, 'Name', _name),
                  _buildInfoRow(Icons.email, 'Email', _email),
                  _buildInfoRow(Icons.phone, 'Mobile', _mobile),
                  SizedBox(height: 16),

                  // Role Selection
                  _buildSectionTitle('Account Type'),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text('Customer'),
                          selected: _role == 'customer',
                          onSelected: (selected) {
                            setState(() {
                              _role = 'customer';
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text('Farmer'),
                          selected: _role == 'farmer',
                          onSelected: (selected) {
                            setState(() {
                              _role = 'farmer';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Divider
                  Divider(thickness: 1),

                  // Logout button
                  SizedBox(height: 13),
                  Center(
                    
                    child: ElevatedButton(
                       
                      onPressed: _logout,
                      child: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(left: 50,right: 50,top: 12,bottom: 12),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _logout() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear shared preferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);

              // Navigate to login screen
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                      (Route<dynamic> route) => false,
                );
              }
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}