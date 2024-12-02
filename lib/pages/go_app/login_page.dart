import 'dart:developer';

import 'package:app/components/page_common.dart';
import 'package:app/services/auth/auth_page.dart';
import 'package:app/components/button_sign_in.dart';
import 'package:app/components/square_tile.dart';
import 'package:app/components/textFielduser.dart';
import 'package:app/pages/go_app/forgot_pw_password.dart';
import 'package:app/pages/go_app/loading_page.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/gg-fb/firebase_services.dart';
import 'package:app/services/gg-fb/firebase_services2.dart';
import 'package:app/services/user/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

//login method
  void login() async {
    // auth service
    final authService = AuthService();
    setState(() {
      _isLoading = true;
    });
    //try log in
    try {
      if (_validateFields()) {
        await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        final pres = await SharedPreferences.getInstance();
        pres.setBool('isLoggedIn', true);

        if(!mounted) return;
        Future.delayed(const Duration(seconds: 5), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const CommonPage(),
          ));
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Missing Fields"),
            content: Text("Please fill in all required fields."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'))
            ],
          ),
        );
      }
      // catch any error
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Warning"),
          content: Text("Email or password is incorrect."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel'))
          ],
        ),
      );
    }
  }

  bool _validateFields() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        Image.asset('lib/images/logo_1.png', width: 100),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: 'Welcome to ',
                                ),
                                TextSpan(
                                    text: 'Wingle',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    )),
                              ]),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "Enter your email address and password to get access your account.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  // username textfield
                  MyTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      obscureText: false),
                  SizedBox(
                    height: 10,
                  ),
                  //password textfield
                  MyTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  //forgot password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ForgotPasswordPage();
                        }));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forgot Password ?',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  //sign in button
                  BtnSignIn(
                    onTap: () async {
                      login();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey[700],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 16),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  // google +fb sign in button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //google button
                      MaterialButton(
                        padding: const EdgeInsets.all(5.0),
                        child: SquareTile(imagePath: 'lib/images/google.png'),
                        onPressed: () async {
                          bool success =
                              await FireBaseServices().signInWithGoogle();
                          if (success) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return LoadingPage();
                            }));
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return AuthPage();
                            }));
                          }
                        },
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      //facebook button
                      MaterialButton(
                          padding: EdgeInsets.all(5.0),
                          onPressed: () async {
                            UserCredential? userCredential =
                                await FireBaseServices2().signInFacebook();
                            if (userCredential != null) {
                              // Nếu đăng nhập thành công, điều hướng đến trang LoadingPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoadingPage()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AuthPage()),
                              );
                            }
                          },
                          child:
                              SquareTile(imagePath: 'lib/images/facebook.png')),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  // not a member, register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member ? ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: Text(
                          'Register now',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black87,
                child: Center(child: CircularProgressIndicator())),
        ]),
      ),
    );
  }
}
