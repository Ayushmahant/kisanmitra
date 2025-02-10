import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color bgColor;
  //final VoidCallback onTap; // Added callback for navigation

  const CustomCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.bgColor,
   // required this.onTap, // Required navigation function
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Detects taps
     // onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // Subtle shadow
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Color
            Positioned.fill(
              child: Container(
                color: bgColor.withValues(alpha: 0.1), // Light tint of color
              ),
            ),
            // Card Content
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      imagePath,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
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
