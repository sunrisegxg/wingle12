import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  const SquareTile({super.key, required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0) ,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Image.asset(
          imagePath,
          height: 30,
        ));
  }
}
