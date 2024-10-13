// ignore_for_file: prefer_const_constructors

import 'package:app/services/auth/auth_page.dart';
import 'package:app/intro/intro_page1.dart';
import 'package:app/intro/intro_page2.dart';
import 'package:app/intro/intro_page3.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  //controller to keep track of which page we're on
  final PageController _controller = PageController();

  //keep track of if we're on the last page or not
  bool _onLastPage = false;
  bool _onSecondPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Stack(
        children: [
          //page view
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _onLastPage = (index == 2);
                _onSecondPage = (index >= 1);
              });
            },
            children: const [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),

          //dot indicator
          Container(
            // alignment: Alignment(0, 0.75),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Color.fromARGB(255, 116, 93, 244), // Màu sắc của chỉ số trang hiện tại
                    dotColor: Colors.grey, // Màu sắc của các chỉ số trang khác
                    dotHeight: 12,
                    dotWidth: 12,
                    spacing: 8,
                    expansionFactor: 3,
                  ),
                ),
                SizedBox(height: 110,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //skip
                    _onSecondPage
                    ? GestureDetector(
                      onTap: () {
                        _controller.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                        child: Text('Back',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    //BACK PREVIOUS PAGE
                    : GestureDetector(
                      onTap: () {
                        _controller.jumpToPage(2);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                        child: Text('Skip',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    //next or done
                    _onLastPage
                    ? GestureDetector(
                      child: MaterialButton(
                        color: Color.fromARGB(255, 116, 93, 244),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // Độ cong của góc
                        ),
                        onPressed: () async {
                          // show one time
                          final pres = await SharedPreferences.getInstance();
                          pres.setBool('onboarding', true);

                          if(!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AuthPage();
                              }
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
                          child: Text('Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    : GestureDetector(
                      child: MaterialButton(
                        // textColor: Colors.white,
                        color: Color.fromARGB(255, 116, 93, 244),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // Độ cong của góc
                        ),
                        onPressed: () {
                          _controller.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                          child: Text('Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
