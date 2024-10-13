// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class BtnClose extends StatelessWidget {
  const BtnClose({super.key, required this.onTap});
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ),
    );
  }
}
