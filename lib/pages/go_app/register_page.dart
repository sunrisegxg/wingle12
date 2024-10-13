// ignore_for_file: prefer_const_constructors
import 'package:app/services/auth/auth_page.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/components/button_sign_up.dart';
import 'package:app/components/textFielduser.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
    bool _isLoading = false;
  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  // late final String _phoneNumber;
  // late final String _job;
  // late final String _bio;
  final String _avatar ="https://cdn-icons-png.flaticon.com/512/3177/3177440.png";
  // late final List<dynamic> following;
  // late final List<dynamic> followers;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void register() {
    //get auth service
    final _auth = AuthService();
    setState(() {
      _isLoading = true;
    });
    try {
    //passwords match -> create user
      if (_validateFields() && passwordConfirmed()) {
          _auth.signUpWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
            _ageController.text.trim(),
            '',
            '',
            '',
            _avatar,
            [],
            [],
          );

          Future.delayed(const Duration(seconds: 5), () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const AuthPage(),
            ));
            setState(() {
            _isLoading = false;
          });
          });
      //passwords don't match -> tell user to fix
      } else if(!passwordConfirmed()) {
        setState(() {
        _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Warning"),
            content: Text("Passwords do not match."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
            ],
          ),
        );
      } else if (!_validateFields()) {
        setState(() {
        _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Missing Fields"),
            content: Text("Please fill in all required fields."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          )
        );
    }
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() == _confirmpasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }
  bool _validateFields() {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmpasswordController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        Text(
                          'Create Account',
                          style:
                              TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
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
                                  "Please enter your valid information to access your account.",
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
                  // firstname textfield
                  MyTextField(
                      controller: _firstNameController,
                      hintText: 'First Name',
                      obscureText: false),
                  SizedBox(
                    height: 10,
                  ),
                  // lastname textfield
                  MyTextField(
                      controller: _lastNameController,
                      hintText: 'Last Name',
                      obscureText: false),
                  SizedBox(
                    height: 10,
                  ),
                  // age textfield
                  MyTextField(
                      controller: _ageController,
                      hintText: 'Age',
                      obscureText: false),
                  SizedBox(
                    height: 10,
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
                    height: 10,
                  ),
                  //confirm password textfield
                  MyTextField(
                    controller: _confirmpasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  //sign in button
                  BtnSignUp(
                    onTap: () {
                      register();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  // a member, login now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('I am a member ? ', style: TextStyle(fontSize: 16, color: Colors.black),),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: Text(
                          'Login now',
                          style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
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
              child: Center(child: CircularProgressIndicator())
            ),
          ],
        ),
      ),
    );
  }
}