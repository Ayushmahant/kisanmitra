import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  Future<void> _pickAndCropImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      try {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          );
          if (croppedFile != null) {
            setState(() {
              _image = File(croppedFile.path);
            });
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick or crop image: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission to access gallery is required")),
      );
    }
  }

  Future<void> _addAuctionItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _image == null || _nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    // Close the bottom sheet before showing the loader
    Navigator.pop(context);

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing it manually
      builder: (context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Saving item, please wait..."),
            ],
          ),
        );
      },
    );

    try {
      String imageUrl = await _uploadToFirebaseStorage(_image!);

      // Ensure auction collection has seller info
      FirebaseFirestore.instance.collection('auctions').doc(user.uid).set({
        'userId': user.uid,
        'sellerName': user.displayName ?? 'Unknown Seller', // Optional, for display purposes
      }, SetOptions(merge: true));

      // ✅ Store `sellerId` when adding item
      await FirebaseFirestore.instance.collection('auctions').doc(user.uid).collection('items').add({
        'name': _nameController.text,
        'quantity': _quantityController.text,
        'imageUrl': imageUrl,
        'sellerId': user.uid, // ✅ Add the seller ID
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Close the loading dialog
      Navigator.pop(context);

      setState(() {
        _image = null;
        _nameController.clear();
        _quantityController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Auction item added successfully")),
      );
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding auction item: $e")),
      );
    }
  }


  Future<String> _uploadToFirebaseStorage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child("auction_images/$fileName");
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  void _showBids(String itemId) {
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('auctions')
              .doc(user!.uid) // Auction owner's document
              .collection('items')
              .doc(itemId)
              .collection('bids')
              .orderBy('amount', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No bids available"));
            }
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text("Bid: ₹${data['amount']}"),
                  // subtitle: Text("Bidder: ${data['bidderName']}"),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('auctions')
                          .doc(user.uid)
                          .collection('items')
                          .doc(itemId)
                          .update({'selectedBid': data});
                      Navigator.pop(context);
                    },
                    child: const Text("Select"),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }



  void _showBottomSheet(BuildContext context) {
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
              Text("Add Auction Item", style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickAndCropImage,
                child: _image != null
                    ? Image.file(_image!, height: 150)
                    : Container(
                  height: 150,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Icon(CupertinoIcons.photo, color: Colors.grey[700], size: 50)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Enter Item Name", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _quantityController, decoration: const InputDecoration(labelText: "Enter Item Quantity", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _addAuctionItem,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Auction", style: const TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('auctions').doc(user!.uid).collection('items').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No auction items available"));
          }
          return ListView(
            padding: const EdgeInsets.all(8),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(data['name']),
                  subtitle: Text("Quantity: ${data['quantity']}"),
                  trailing: ElevatedButton(
                    onPressed: () => _showBids(doc.id),
                    child: const Text("View Bids"),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }
}
