import 'package:flutter/material.dart';
import '/widgets/card.dart';
import 'auction.dart';
import 'package:kisanmitra/mandi.dart';

class IPopScreen extends StatelessWidget {
  //final Function(int) onItemSelected; // Function to update bottom nav index

  const IPopScreen({super.key}); // required this.onItemSelected

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image restricted to Half Screen with Shadow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.lighten,
                child: Image.asset(
                  'assets/pages/example2.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Content (Text & Cards)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Welcome Ayush',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bringing you the freshest produce right from the source.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2,
                    children: [
                      CustomCard(
                        title: "Market",
                        bgColor: Colors.green,
                        imagePath: "assets/pages/store.png",
                        onTap: () {print('Market tapped');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MandiPriceApp(),
                          ),
                        );}, // No navigation
                      ),
                      CustomCard(
                        title: "Sell",
                        bgColor: const Color.fromARGB(255, 128, 236, 47),
                        imagePath: "assets/pages/buy.png",
                        onTap: () {}, // No navigation
                      ),
                      CustomCard(
                        title: "Auction",
                        bgColor: Colors.greenAccent,
                        imagePath: "assets/pages/bid.png",
                        onTap: () {
                          print('Auction card tapped');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuctionScreen(),
                            ),
                          );
                        },

                      ),
                      CustomCard(
                        title: "Trends",
                        bgColor: Colors.lightGreenAccent,
                        imagePath: "assets/pages/newspaper-folded.png",
                        onTap: () {}, // No navigation
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
