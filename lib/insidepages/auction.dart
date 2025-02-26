import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as path; // ✅ Fix for 'path' package issue

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  File? _selectedImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final String rpcUrl = "http://192.168.1.105:8545";
  final String privateKey = "0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e";
  late Web3Client client;
  late Credentials credentials;

  @override
  void initState() {
    super.initState();
    client = Web3Client(rpcUrl, Client());
    credentials = EthPrivateKey.fromHex(privateKey);
  }

  Future<void> _pickAndCropImage() async {
    var status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      try {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Colors.green,
                toolbarWidgetColor: Colors.white,
                hideBottomControls: false,
                lockAspectRatio: false,
                statusBarColor: Colors.green,
                backgroundColor: Colors.black,
              ),
              IOSUiSettings(title: 'Crop Image')
            ],
          );

          if (croppedFile != null) {
            setState(() {
              _selectedImage = File(croppedFile.path);
            });
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to pick or crop image")),
        );
      }
    } else if (status.isDenied) {
      openAppSettings();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission to access gallery is required")),
      );
    }
  }

  Future<String> _uploadToFirebaseStorage(File image) async {
    String fileName = path.basename(image.path);
    Reference ref = FirebaseStorage.instance.ref().child("auction_images/$fileName");
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _addAuctionItem() async {
    if (_selectedImage == null || _nameController.text.isEmpty || _quantityController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      print("📤 Uploading image...");
      String imageUrl = await _uploadToFirebaseStorage(_selectedImage!);
      print("✅ Image uploaded: $imageUrl");

      final EthereumAddress contractAddress = EthereumAddress.fromHex("0x5FbDB2315678afecb367f032d93F642f64180aa3");

      final String abi = '''
    [
      {
        "inputs": [
          {"internalType": "string", "name": "_name", "type": "string"},
          {"internalType": "uint256", "name": "_quantity", "type": "uint256"},
          {"internalType": "string", "name": "_imageUrl", "type": "string"}
        ],
        "name": "addAuctionItem",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ]
    ''';

      final contract = DeployedContract(ContractAbi.fromJson(abi, "Auction"), contractAddress);
      final function = contract.function("addAuctionItem");

      print("⏳ Sending transaction...");
      await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: function,
          parameters: [_nameController.text, BigInt.from(int.parse(_quantityController.text)), imageUrl],
        ),
      );

      print("✅ Transaction successful!");

      // Close loading indicator
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item added successfully!")),
        );
        Navigator.pop(context); // Close the modal bottom sheet
      }
    } catch (e) {
      print("❌ Error: $e");

      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }


  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) { // ✅ Corrected context usage
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
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
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, height: 150)
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
              ElevatedButton(onPressed: _addAuctionItem, child: const Text("Save"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Auction", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        backgroundColor: Colors.green,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }
}
