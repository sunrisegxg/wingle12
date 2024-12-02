import 'package:flutter/material.dart';

class EveryoneView extends StatefulWidget {
  final Widget child; 
  const EveryoneView({super.key, required this.child});

  @override
  State<EveryoneView> createState() => _EveryoneViewState();
}

class _EveryoneViewState extends State<EveryoneView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: widget.child,
      ),
    );
  }
}