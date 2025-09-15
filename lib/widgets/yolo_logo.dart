import 'package:flutter/material.dart';

class YoloLogo extends StatelessWidget {
  final double size;

  const YoloLogo({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Yolo',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            fontFamily: 'NeuePowerTrial', // Use the primary font
          ),
        ),
      ),
    );
  }
}