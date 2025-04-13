import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chatScreen.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("You must be logged in to view chats.")),
      );
    }

    final currentUserId = currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text("User ID is not available.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Bids & Chats")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('auctions').snapshots(),
        builder: (context, auctionSnapshot) {
          if (auctionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sellerDocs = auctionSnapshot.data!.docs;
          List<Widget> chatCards = [];

          for (var sellerDoc in sellerDocs) {
            final sellerId = sellerDoc.id;

            chatCards.add(StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('auctions')
                  .doc(sellerId)
                  .collection('items')
                  .where('selectedBid.bidderId', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, itemSnapshot) {
                if (!itemSnapshot.hasData || itemSnapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: itemSnapshot.data!.docs.map((itemDoc) {
                    final data = itemDoc.data() as Map<String, dynamic>;
                    final itemId = itemDoc.id;
                    final chatId = '${itemId}_${sellerId}_$currentUserId';

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .where('read', isEqualTo: false)
                          .where('senderId', isEqualTo: sellerId)
                          .snapshots(),
                      builder: (context, unreadSnapshot) {
                        final unreadDocs = unreadSnapshot.data?.docs ?? [];
                        final unreadCount = unreadDocs.length;

                        return Card(
                          child: ListTile(
                            leading: data['imageUrl'] != null
                                ? Image.network(
                              data['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                                : const Icon(Icons.image),
                            title: Text(data['name'] ?? "Item"),
                            subtitle: Text(
                                "You won the bid for ₹${data['selectedBid']['amount']}"),
                            trailing: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    // Mark all unread messages as read before navigating
                                    for (var doc in unreadDocs) {
                                      await doc.reference.update({'read': true});
                                    }

                                    // Navigate to chat screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          itemId: itemId,
                                          sellerId: sellerId,
                                          bidderId: currentUserId,
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
                  }).toList(),
                );
              },
            ));
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
