import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'insidepages/homies.dart'; // Farmer home
import 'insidepages/Customer_Dashboard.dart'; // Customer dashboard
 import 'insidepages/profile.dart';
 import 'insidepages/chatSeller.dart';
 import 'insidepages/chatBidder.dart';// Profile page (Farmer & Customer)
// import 'insidepages/chat.dart'; // Chat page (Farmer & Customer)

class MajorPage extends StatefulWidget {
  const MajorPage({super.key});

  @override
  _MajorPageState createState() => _MajorPageState();
}

class _MajorPageState extends State<MajorPage> {
  int _selectedIndex = 0;
  String userRole = "customer"; // Default to customer
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && mounted) {
        String role = (userDoc['role'] ?? "customer").toLowerCase();
        print("Retrieved role: $role"); // Debugging log

        setState(() {
          userRole = role;
          _selectedIndex = 0; // Always start at home page based on role
          isLoading = false;
        });
      } else {
        print("User document does not exist!");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("No authenticated user found!");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Define separate pages for Farmer and Customer
  List<Widget> get _pages {
    if (userRole == "farmer") {
      return [
        CustomerDashboardSell(), // Farmer Home
         ProfilePage(), // Farmer Profile
        FarmerChatsScreen(), // Chat
      ];
    } else {
      return [
        customerdashboard(), // Customer Home
        ProfilePage(), // Customer Profile
        MyChatsScreen(), // Chat
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: _pages[_selectedIndex], // Dynamically load selected page
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.white70,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Symbols.home, size: 28, color: Colors.green, fill: 1.0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Symbols.person, size: 28, color: Colors.green, fill: 1.0),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Symbols.chat_apps_script_rounded, size: 28, color: Colors.green, fill: 1.0),
                label: 'Chat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
