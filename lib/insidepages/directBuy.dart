import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DirectBuyPage extends StatefulWidget {
  @override
  _DirectBuyPageState createState() => _DirectBuyPageState();
}

class _DirectBuyPageState extends State<DirectBuyPage> {
  String selectedLocation = 'Nagpur';
  String searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedLocation,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search crops or farmers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),
            // Location Dropdown
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: selectedLocation,
                items: <String>['Nagpur', 'Indore', 'Ambala', 'Delhi']
                    .map<DropdownMenuItem<String>>((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location, style: TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLocation = newValue!;
                  });
                },
                isExpanded: true,
                underline: SizedBox(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('direct_buy_items')
                    .where('location', isEqualTo: selectedLocation)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No items available for direct buy'));
                  }

                  var filteredCrops = snapshot.data!.docs
                      .map((doc) => Crop.fromFirestore(doc))
                      .where((crop) =>
                  crop.cropName.toLowerCase().contains(searchTerm.toLowerCase()) ||
                      crop.farmerName.toLowerCase().contains(searchTerm.toLowerCase()))
                      .toList();

                  return ListView.builder(
                    itemCount: filteredCrops.length,
                    itemBuilder: (context, index) {
                      return CropCard(crop: filteredCrops[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Crop {
  final String farmerName;
  final String farmerId;
  final String address;
  final String weight;
  final String land;
  final String available;
  final String rate;
  final String cropName;
  final String date;
  final String location;
  final String imageUrl;

  Crop({
    required this.farmerName,
    required this.farmerId,
    required this.address,
    required this.weight,
    required this.land,
    required this.available,
    required this.rate,
    required this.cropName,
    required this.date,
    required this.location,
    required this.imageUrl,
  });

  factory Crop.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Crop(
      farmerName: data['farmerName'] ?? 'Unknown Farmer',
      farmerId: data['farmerId'] ?? 'N/A',
      address: data['address'] ?? 'Unknown Address',
      weight: "${data['weight'] ?? 0} Tons",
      land: data['land'] ?? 'N/A',
      available: data['available'] ?? 'N/A',
      rate: data['rate'] ?? '₹ 0',
      cropName: data['cropName'] ?? 'Unknown Crop',
      date: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate().toString().substring(0, 10)
          : 'N/A',
      location: data['location'] ?? 'N/A',
      imageUrl: data['imageUrl'] ?? 'assets/pages/placeholder.png',
    );
  }
}

class CropCard extends StatelessWidget {
  final Crop crop;

  CropCard({required this.crop});

  void _showBuyDialog(BuildContext context) {
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Purchase"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                crop.imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/pages/placeholder.png', height: 100, width: 100, fit: BoxFit.cover);
                },
              ),
              SizedBox(height: 10),
              Text("Price: ${crop.rate} per KG"),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter Quantity (KG)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (quantityController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Purchase Confirmed!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Confirm Buy"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.network(
              crop.imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/pages/placeholder.png', height: 100, width: 100, fit: BoxFit.cover);
              },
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Farmer: ${crop.farmerName}"),
                  Text("Rate: ${crop.rate} Per KG"),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _showBuyDialog(context),
                        child: Text("Buy Now"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}