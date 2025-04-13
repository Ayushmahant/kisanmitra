import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class CustomerProductPage extends StatefulWidget {
  const CustomerProductPage({super.key});

  @override
  State<CustomerProductPage> createState() => _CustomerProductPageState();
}

class _CustomerProductPageState extends State<CustomerProductPage> {
  final TextEditingController _quantityController = TextEditingController();

  void _placeOrder(String productId, String sellerId, String productName, String price) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Place Order"),
          content: TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Enter Quantity"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                int quantity = int.tryParse(_quantityController.text) ?? 0;
                if (quantity > 0) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  // Fetch buyer's name from Firestore
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
                  String buyerName = userDoc.exists ? (userDoc["name"] ?? "Unknown Buyer") : "Unknown Buyer";

                  // Store order with buyerName
                  await FirebaseFirestore.instance.collection("orders").add({
                    "buyerId": user.uid,
                    "buyerName": buyerName, // Now correctly stored
                    "productId": productId,
                    "sellerId": sellerId,
                    "productName": productName,
                    "quantity": quantity,
                    "price": price,
                    "status": "Pending",
                    "timestamp": FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);

                  final snackBar = SnackBar(

                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Placed !',
                      message: 'Your order for $productName has been placed successfully!',
                      contentType: ContentType.success, // Success message style
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }


  Future<List<DocumentSnapshot>> _fetchProducts() async {
    QuerySnapshot farmersSnapshot = await FirebaseFirestore.instance.collection("directSell").get();
    List<DocumentSnapshot> allProducts = [];

    for (var farmerDoc in farmersSnapshot.docs) {
      QuerySnapshot itemsSnapshot = await farmerDoc.reference.collection("items").get();
      allProducts.addAll(itemsSnapshot.docs);
    }
    return allProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Products"), backgroundColor: Colors.green),
      body: FutureBuilder(
        future: _fetchProducts(),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products available"));
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: snapshot.data!.map((doc) {
              Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

              if (data == null || !data.containsKey('name') || !data.containsKey('price')) {
                return const SizedBox(); // Skip invalid data
              }

              String productId = doc.id;
              String sellerId = data['farmerId'] ?? 'Unknown Seller';

              return Card(
                child: ListTile(
                  leading: data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                      ? Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, size: 50), // Placeholder for missing images
                  title: Text(data['name'] ?? 'Unknown Product'),
                  subtitle: Text("Quantity: ${data['quantity'] ?? 'N/A'} \nPrice: \$${data['price'] ?? 'N/A'}"),
                  trailing: ElevatedButton(
                    onPressed: () => _placeOrder(productId, sellerId, data['name'] ?? '', data['price'] ?? ''),
                    child: const Text("Order"),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
