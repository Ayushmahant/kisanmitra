import 'package:flutter/material.dart';

class AuctionScreen extends StatelessWidget {
  const AuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search auctions...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 10, // Sample auction items
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.green),
              title: Text("Auction Item ${index + 1}"),
              subtitle: Text("Current Bid: \$${(index + 1) * 10}"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: Text("Bid"),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add auction screen
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: Colors.green,
      //   unselectedItemColor: Colors.grey,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: "Home",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.gavel),
      //       label: "Auction",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: "Profile",
      //     ),
      //   ],
      // ),
    );
  }
}
