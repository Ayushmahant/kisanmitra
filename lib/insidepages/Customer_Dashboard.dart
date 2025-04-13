import 'package:flutter/material.dart';
import 'package:kisanmitra/bottomnavbar.dart';
import 'package:kisanmitra/insidepages/directBuy.dart';
import '/widgets/card.dart';
import '/bottomnavbar.dart';
import 'package:kisanmitra/insidepages/Auction(C).dart';
import 'package:kisanmitra/widgets/card.dart';
import 'mandi.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class customerdashboard extends StatelessWidget {
  const customerdashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          bool isTablet = screenWidth > 600; // Adjusts layout for tablets

          return SingleChildScrollView( // ✅ Makes the page scrollable
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Background Image
                Container(
                  width: double.infinity,
                  height: constraints.maxHeight * 0.5,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 5,
                        spreadRadius:2 ,
                        //offset: const Offset(0, 3),
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
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white,
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.lighten,
                    child: Image.asset(
                      'assets/pages/customer_dashboard.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Welcome Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Consumer',
                        style: TextStyle(
                          fontSize: isTablet ? 36 : 32, // Responsive Text
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Buy the freshest produce right from the source.',
                            textStyle: TextStyle(
                              fontSize: isTablet ? 20 : 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w300,
                            ),
                            cursor: '',
                            speed: const Duration(milliseconds: 100), // Typing speed per character
                          ),
                        ],
                        repeatForever: true, // Infinite loop
                        pause: const Duration(seconds: 5), // Pause before restarting
                        displayFullTextOnTap: true, // Show full text on tap
                        stopPauseOnTap: true, // Stop pause on tap
                      ),
                    ],
                  ),
                ),




                // Cards Section (Grid)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true, // ✅ Ensures GridView doesn't take infinite height
                    physics: const NeverScrollableScrollPhysics(), // ✅ Prevents nested scrolling issues
                    crossAxisCount: isTablet ? 3 : 2, // Responsive column count
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isTablet ? 2.2 : 2, // Adjust ratio for better fit
                    children: [
                      CustomCard(
                        title: "Market",
                        bgColor: Colors.green,
                        imagePath: "assets/pages/store.png",
                        onTap: () {
                          Navigator.push(context, _createRoute(MandiPriceApp()));
                        },
                      ),
                      CustomCard(
                        title: "Direct Buy",
                        bgColor: const Color.fromARGB(255, 128, 236, 47),
                        imagePath: "assets/pages/search.jpg",
                        onTap: () {
                          Navigator.of(context).push(_createRoute(CustomerProductPage()));
                        },
                      ),
                      CustomCard(
                        title: "Bid",
                        bgColor: Colors.greenAccent,
                        imagePath: "assets/pages/bid.png",
                        onTap: () {
                          Navigator.push(context, _createRoute(CustomerAuctionScreen()));
                        },
                      ),
                      CustomCard(
                        title: "Trends",
                        bgColor: Colors.lightGreenAccent,
                        imagePath: "assets/pages/newspaper-folded.png",
                        onTap: () {
                          // No navigation yet
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20), // Adds space at bottom for better scroll feel
              ],
            ),
          );
        },
      ),
    );
  }
}

Route _createRoute(Widget child) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 900), // Increase duration for smoothness
    reverseTransitionDuration: const Duration(milliseconds: 900), // Smooth back transition
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0); // Slide up
      const end = Offset.zero;
      const reverseBegin = Offset.zero;
      const reverseEnd = Offset(0.0, 1.0); // Slide down when popping
      const curve = Curves.easeInOut; // Smoother transition

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var reverseTween = Tween(begin: reverseBegin, end: reverseEnd)
          .chain(CurveTween(curve: curve));

      // Fade effect for extra smoothness
      var fadeTween = Tween(begin: 0.0, end: 1.0);
      var fadeAnimation = animation.drive(CurveTween(curve: Curves.easeInOut));

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: animation.drive(tween),
          child: SlideTransition(
            position: secondaryAnimation.drive(reverseTween),
            child: child,
          ),
        ),
      );
    },
  );
}


