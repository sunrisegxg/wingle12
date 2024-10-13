import 'dart:async';

import 'package:app/components/page_common.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _animationCompleted = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.network(
          'https://lottie.host/3ead8317-0e5e-4326-9a93-f0f87963f08e/L4Fkyxbdfi.json',
          onLoaded: (composition) {
            Timer(Duration(seconds: 5), () {
              setState(() {
                _animationCompleted = true;
              });
              if (_animationCompleted) {
                // Chuyển đến trang mới sau khi animation dừng
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CommonPage()),
                );
              }
            });
          },
          animate: !_animationCompleted,
        ),
      ),
    );
  }
}