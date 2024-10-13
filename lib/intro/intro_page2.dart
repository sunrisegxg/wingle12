// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

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
              SizedBox(height: 122,),
              Lottie.asset('lib/images/1709647326178.json', animate: true),
              SizedBox(height: 20,),
              Text('Be more flexible and secure',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 23, 4, 92),
                  fontSize: 22,
                  height: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10,),
              Text("Use this platform in all your devices, don't worry about anything, we protect you!!!",
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