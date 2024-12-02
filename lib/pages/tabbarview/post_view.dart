import 'package:flutter/material.dart';

class PostView extends StatefulWidget {
  final Widget child; 
  const PostView({super.key, required this.child});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: widget.child,
      ),
    );
  }
}