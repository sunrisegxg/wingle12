import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyTextField2 extends StatelessWidget {
  const MyTextField2({super.key, required this.controller, required this.hintText, required this.obscureText, this.focusNode});
  final controller;
  final String hintText;
  final bool obscureText;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black38 : Colors.grey.shade200,
          // border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            maxLines: null,
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
            style: TextStyle(fontFamily: 'Roboto',),
          ),
        ),
      ),
    );
  }
}
