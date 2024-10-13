// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 134,),
              Lottie.asset('lib/images/1709657138655.json', animate: true),
              SizedBox(height: 70,),
              Text('Be easier to communciate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 23, 4, 92),
                  fontSize: 22,
                  height: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,),
              Text('Just using your phone, you can make friend, text and chat easier and more quickly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 121, 126, 203),
                  height: 2,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}