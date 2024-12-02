import 'package:flutter/material.dart';

class AllView extends StatefulWidget {
  final Widget child; 
  const AllView({super.key, required this.child});

  @override
  State<AllView> createState() => _AllViewState();
}

class _AllViewState extends State<AllView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: widget.child,
      ),
    );
  }
}