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

class DirectSellScreen extends StatefulWidget {
  const DirectSellScreen({super.key});

  @override
  State<DirectSellScreen> createState() => _DirectSellScreenState();
}

class _DirectSellScreenState extends State<DirectSellScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
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
    }
  }

  Future<void> _addDirectSellItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _image == null || _nameController.text.isEmpty || _quantityController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    Navigator.pop(context);
    showDialog(
      context: context,
      barrierDismissible: false,
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
      FirebaseFirestore.instance.collection('directSell').doc(user.uid).set({
        'userId': user.uid,
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('directSell').doc(user.uid).collection('items').add({
        'name': _nameController.text,
        'quantity': _quantityController.text,
        'price': _priceController.text,
        'imageUrl': imageUrl,
        'farmerId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      setState(() {
        _image = null;
        _nameController.clear();
        _quantityController.clear();
        _priceController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product listed successfully")),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error listing product: $e")),
      );
    }
  }

  Future<String> _uploadToFirebaseStorage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child("direct_sell_images/$fileName");
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  void _viewOrders(String productId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text("Orders Received", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('productId', isEqualTo: productId)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No orders received"));
                    }
                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text("Buyer: ${data['buyerName']}"),
                            subtitle: Text("Quantity: ${data['quantity']}\nPrice: \$${data['price']}"),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('orders').doc(doc.id).update({
                                  'status': 'Delivered',
                                });
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order marked as delivered")));
                              },
                              child: const Text("Deliver"),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
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
        title: const Text("Direct Sell", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('directSell')
            .doc(user!.uid)
            .collection('items')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products listed"));
          }
          return ListView(
            padding: const EdgeInsets.all(8),
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(data['name']),
                  subtitle: Text("Quantity: ${data['quantity']} \nPrice: \$${data['price']}"),
                  trailing: ElevatedButton(
                    onPressed: () => _viewOrders(doc.id),
                    child: const Text("View Orders"),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                    Text("Add Product", style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Enter Product Name", border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    TextField(controller: _quantityController, decoration: const InputDecoration(labelText: "Enter Quantity", border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Enter Price", border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _isLoading ? null : _addDirectSellItem, child: const Text("Save")),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );

  }
}
