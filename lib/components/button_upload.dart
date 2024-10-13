// ignore_for_file: prefer_const_constructors

import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BtnUpload extends StatefulWidget {
  const BtnUpload({super.key, required this.onTap, required this.isButtonEnabled});
  final Function()? onTap;
  final bool isButtonEnabled;

  @override
  State<BtnUpload> createState() => _BtnUploadState();
}

class _BtnUploadState extends State<BtnUpload> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return GestureDetector(
      onTap: widget.isButtonEnabled ? widget.onTap : null,
        child: AnimatedOpacity(
          opacity: widget.isButtonEnabled ? 1.0 : 0.3,
          duration: Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blue : Color.fromARGB(255, 78, 170, 246),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Upload',
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
