import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextFieldLocation extends StatelessWidget {
  const TextFieldLocation({super.key, required this.controller, required this.hintText,});
  final TextEditingController controller;
  final String hintText;
  // final Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Theme.of(context).colorScheme.background : Colors.white,
        border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Color.fromARGB(255, 188, 218, 243), width: 2),
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: TextField(
          // onChanged: onChanged,
          cursorColor: isDarkMode ? Colors.grey.shade700 : Color.fromARGB(255, 188, 218, 243),
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Container(
              // padding: EdgeInsets.only(right: 20.0),
              child: Image.asset('lib/images/haha.png', width: 1.0,)),
            prefixIconConstraints: BoxConstraints(
              minWidth: 50,
              minHeight: 50,
            ),
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextStyle(color: Colors.black, fontFamily: 'Roboto',),
        ),
      ),
    );
  }
}
