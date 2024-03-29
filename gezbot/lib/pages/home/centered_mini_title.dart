import 'package:flutter/material.dart';

class CenteredMiniTitle extends StatelessWidget {
  final String title;
  final double top;
  final double width;

  const CenteredMiniTitle({
    required this.title,
    required this.top,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      width: width,
      child: Column(
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: width * 0.6, // Adjust the percentage based on your design
            child: const Divider(
              color: Colors.blueGrey,
              thickness: 2, // Adjust the thickness of the divider as needed
              height: 20, // Adjust the height between the title and the divider as needed
            ),
          ),
        ],
      ),
    );
  }
}