// import 'dart:js';
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, annotate_overrides, sort_child_properties_last

import 'package:app/components/button_reset_pass.dart';
import 'package:app/components/textFieldreset.dart';
import 'package:app/components/textFielduser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password reset link sent! Check your email.'),
            );
          },
        );
    } on FirebaseAuthException catch (e) {
      if (_emailController.text.trim().isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Please enter your email'),
            );
          },
        );
      }
      else {
      print(e);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Forgot Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Colors.grey[300],
            height: 2,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('Please, enter your email and we will send you instructions on how to reset your password.',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),),
          ),
          SizedBox(
            height: 20,
          ),
          // username textfield
          MyTextField3(controller: _emailController, hintText: 'Email', obscureText: false),
          SizedBox(
            height: 30,
          ),
          BtnResetPass(onTap: passwordReset),
        ],
      ),
    );
  }
}
