import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

class CustomerAuctionScreen extends StatefulWidget {
  const CustomerAuctionScreen({super.key});

  @override
  State<CustomerAuctionScreen> createState() => _CustomerAuctionScreenState();
}

class _CustomerAuctionScreenState extends State<CustomerAuctionScreen> {
  final TextEditingController _bidController = TextEditingController();
  String? selectedItemId;
  Map<String, dynamic>? selectedItem;
  Set<String> placedBids = {};

  @override
  void initState() {
    super.initState();
    _fetchPlacedBids();
  }

  Future<void> _fetchPlacedBids() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('bids')
        .doc(user.uid)
        .collection('bids')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        placedBids = snapshot.docs.map((doc) => doc.id).toSet();
      });
    });
  }

  void _showBidBottomSheet(Map<String, dynamic> itemData, String itemId) {
    if (placedBids.contains(itemId)) return;

    setState(() {
      selectedItem = itemData;
      selectedItemId = itemId;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Place Your Bid", style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (selectedItem != null)
                Column(
                  children: [
                    Image.network(selectedItem!["imageUrl"], height: 150),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _bidController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Enter Bid Price",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _placeBid,
                      child: const Text("Submit Bid"),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _placeBid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedItemId == null || _bidController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid bid amount")),
      );
      return;
    }

    String? sellerId = selectedItem?['sellerId'];
    if (sellerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Seller ID not found!")),
      );
      return;
    }

    double? bidAmount = double.tryParse(_bidController.text);
    if (bidAmount == null || bidAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid bid amount")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('auctions')
          .doc(sellerId)
          .collection('items')
          .doc(selectedItemId)
          .collection('bids')
          .doc(user.uid)
          .set({
        'amount': bidAmount,
        'bidderId': user.uid,
        'bidderName': user.displayName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('bids')
          .doc(user.uid)
          .collection('bids')
          .doc(selectedItemId)
          .set({'bidPlaced': true});

      setState(() {
        placedBids.add(selectedItemId!);
      });

      Navigator.pop(context);
      _bidController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bid placed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing bid: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Available Auctions", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('auctions').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No auctions available"));
          }
          return ListView(
            padding: const EdgeInsets.all(8),
            children: snapshot.data!.docs.map((auctionDoc) {
              return StreamBuilder(
                stream: auctionDoc.reference.collection('items').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> itemsSnapshot) {
                  if (!itemsSnapshot.hasData || itemsSnapshot.data!.docs.isEmpty) {
                    return const SizedBox(); // Return an empty widget if no items
                  }
                  return Column(
                    children: itemsSnapshot.data!.docs.map((itemDoc) {
                      Map<String, dynamic> data = itemDoc.data() as Map<String, dynamic>;
                      bool hasPlacedBid = placedBids.contains(itemDoc.id);
                      return Card(
                        child: ListTile(
                          leading: Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                          title: Text(data['name']),
                          subtitle: Text("Quantity: ${data['quantity']}"),
                          trailing: ElevatedButton(
                            onPressed: hasPlacedBid ? null : () => _showBidBottomSheet(data, itemDoc.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasPlacedBid ? Colors.grey : Colors.blue,
                            ),
                            child: Text(hasPlacedBid ? "Bid Placed" : "Place Bid"),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            }).toList(),
          );

        },
      ),
    );
  }
}