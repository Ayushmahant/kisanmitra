import 'package:flutter/material.dart';
import '/widgets/card.dart';
import 'auction.dart';
import 'package:kisanmitra/insidepages/mandi.dart';
import 'directSell.dart';
//IPopScreen

class CustomerDashboardSell extends StatelessWidget {
  const CustomerDashboardSell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          bool isTablet = screenWidth > 600;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: constraints.maxHeight * 0.5,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Seller',
                        style: TextStyle(
                          fontSize: isTablet ? 36 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isTablet ? 3 : 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isTablet ? 2.2 : 2,
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
                        title: "Direct Sell",
                        bgColor: const Color.fromARGB(255, 128, 236, 47),
                        imagePath: "assets/pages/search.jpg",
                        onTap: () {
                          Navigator.of(context).push(_createRoute(DirectSellScreen()));
                        },
                      ),
                      CustomCard(
                        title: "Auction",
                        bgColor: Colors.greenAccent,
                        imagePath: "assets/pages/bid.png",
                        onTap: () {
                          Navigator.push(context, _createRoute(AuctionScreen()));
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
                const SizedBox(height: 20),
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
    transitionDuration: const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds:500),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const reverseBegin = Offset.zero;
      const reverseEnd = Offset(0.0, 1.0);
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var reverseTween = Tween(begin: reverseBegin, end: reverseEnd)
          .chain(CurveTween(curve: curve));
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
