import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatScreen.dart'; // make sure this import points to your ChatScreen

class FarmerChatsScreen extends StatefulWidget {
  const FarmerChatsScreen({Key? key}) : super(key: key);

  @override
  _FarmerChatsScreenState createState() => _FarmerChatsScreenState();
}

class _FarmerChatsScreenState extends State<FarmerChatsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("You must be logged in to view chats.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Chats with Buyers")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('auctions')
            .doc(currentUser.uid)
            .collection('items')
            .snapshots(),
        builder: (context, itemSnapshot) {
          if (itemSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final itemDocs = itemSnapshot.data!.docs;
          List<Widget> chatCards = [];

          for (var itemDoc in itemDocs) {
            final data = itemDoc.data() as Map<String, dynamic>;
            final selectedBid = data['selectedBid'];
            final itemId = itemDoc.id;

            if (selectedBid != null) {
              final bidderId = selectedBid['bidderId'];

              // Fetch the buyer's name using bidderId
              chatCards.add(FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users') // Assuming the buyers are stored in the 'users' collection
                    .doc(bidderId)
                    .get(),
                builder: (context, buyerSnapshot) {
                  if (buyerSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!buyerSnapshot.hasData || !buyerSnapshot.data!.exists) {
                    return const Center(child: Text("Buyer details not found"));
                  }

                  final buyerData = buyerSnapshot.data!.data() as Map<String, dynamic>;
                  final buyerName = buyerData['name'] ?? 'Unnamed Buyer';

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc('$itemId${currentUser.uid}_$bidderId') // Construct chatId
                        .collection('messages')
                        .where('read', isEqualTo: false) // Filter for unread messages
                        .snapshots(),
                    builder: (context, unreadSnapshot) {
                      final unreadDocs = unreadSnapshot.data?.docs ?? [];
                      final unreadCount = unreadDocs.length;

                      return Card(
                        child: ListTile(
                          leading: data['imageUrl'] != null
                              ? Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.image),
                          title: Text("${data['name']} ($buyerName)"),  // Display Product Name and Buyer Name
                          subtitle: Text("Selected Bid: ₹${selectedBid['amount']}"),
                          trailing: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Mark all unread messages as read before navigating
                                  for (var doc in unreadDocs) {
                                    doc.reference.update({'read': true});
                                  }

                                  // Navigate to chat screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        itemId: itemId,
                                        sellerId: currentUser.uid,
                                        bidderId: bidderId,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Chat"),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ));
            }
          }

          if (chatCards.isEmpty) {
            return const Center(child: Text("No active chats yet."));
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: chatCards,
          );
        },
      ),
    );
  }
}
