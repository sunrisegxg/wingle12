import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class MyTextArea extends StatelessWidget {
  const MyTextArea({super.key, required this.controller, required this.hintText});
  final controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDarkMode ? Theme.of(context).colorScheme.background : Colors.white,
        border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Color.fromARGB(255, 188, 218, 243), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          cursorColor: isDarkMode ? Colors.grey.shade700 : Color.fromARGB(255, 188, 218, 243),
          keyboardType: TextInputType.multiline,
          maxLines: null, // Setting maxLines to null allows for multi-line input
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextStyle(fontFamily: 'Roboto',),
        ),
      ),
    );
  }
}
