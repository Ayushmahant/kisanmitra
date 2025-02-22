import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'insidepages/homies.dart'; // Import your Home Page file
import 'insidepages/auction.dart';

class MajorPage extends StatefulWidget {
  const MajorPage({super.key});

  @override
  _MajorPageState createState() => _MajorPageState();
}

class _MajorPageState extends State<MajorPage> {
  int _selectedIndex = 0;

  // List of pages to display based on the selected index
  final List<Widget> _pages = [
    IPopScreen(),
    AuctionScreen(),// Home Page
    // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Dynamically load selected page

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0), // Adds space around nav bar
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30), // Makes the nav bar rounded
          child: BottomNavigationBar(
            backgroundColor: Colors.white70, // Background color of the nav bar
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.green, // Active item color
            unselectedItemColor: Colors.grey, // Inactive item color
            items: [
              BottomNavigationBarItem(
                icon: Icon(Symbols.home, size: 28, color: Colors.green, fill: 1.0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Symbols.account_box_rounded, size: 28, color: Colors.green, fill: 1.0),
                label: 'Auction',
              ),
              BottomNavigationBarItem(
                icon: Icon(Symbols.person, size: 28, color: Colors.green, fill: 1.0),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Symbols.chat_apps_script_rounded, size: 28, color: Colors.green, fill: 1.0),
                label: 'Chat',
              )
            ],
          ),
        ),
      ),
    );
  }
}