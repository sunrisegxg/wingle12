import 'package:flutter/material.dart';

class MyTextField3 extends StatelessWidget {
  const MyTextField3({super.key, required this.controller, required this.hintText, required this.obscureText});
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade600),
            ),
            style: TextStyle(color: Colors.black, fontFamily: 'Roboto',),
          ),
        ),
      ),
    );
  }
}
