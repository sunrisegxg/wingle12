// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class BtnResetPass extends StatelessWidget {
  const BtnResetPass({super.key, required this.onTap});
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              'Reset password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
