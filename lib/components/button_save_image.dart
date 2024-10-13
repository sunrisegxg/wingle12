// ignore_for_file: prefer_const_constructors

import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BtnSaveImage extends StatelessWidget {
  const BtnSaveImage({super.key, required this.onTap});
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.blue : Color.fromARGB(255, 78, 170, 246),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Center(
            child: Text(
              'Save image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
