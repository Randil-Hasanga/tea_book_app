import 'package:flutter/material.dart';

class RoundedCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final double height,width;

  const RoundedCard({
    super.key,
    required this.title, // Pass the text dynamically
    required this.icon, // Pass the icon dynamically
    this.backgroundColor = const Color.fromARGB(255, 221, 255, 234),
    this.iconBackgroundColor = const Color.fromARGB(255, 193, 239, 210),
    this.iconColor = const Color.fromARGB(255, 58, 183, 110),
    this.height = 100,
    this.width = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50, // Circle size
            width: 50,  // Circle size
            decoration: BoxDecoration(
              color: iconBackgroundColor, // Background color for the circle
              shape: BoxShape.circle,    // Circular shape
            ),
            child: Center(
              child: Icon(
                icon, // Dynamic icon
                size: 30, // Icon size
                color: iconColor, // Dynamic icon color
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title, // Dynamic title
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
