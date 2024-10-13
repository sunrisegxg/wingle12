
import 'dart:io';

import 'package:app/components/navigationprovider.dart';
import 'package:app/components/page_common.dart';
import 'package:app/intro/onboarding_screen.dart';
import 'package:app/pages/bottom_app_bar_page/message_page.dart';
import 'package:app/pages/detailed_page/chat_page.dart';
import 'package:app/services/auth/auth_page.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // await ZIMKit().init(
  //   appID: 1007293522,
  //   appSign: '20962baf250e829a7e9b17ddc9a03f4d5345db7bd344079264bb0e80a47d7d55',
  // );
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid ? await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyA7ezMyFp6lyhd2vnhZ5QXARZoCoeoJ5BU',
      appId: '1:234751558894:android:652e75069b55c91d889fff',
      messagingSenderId: '234751558894',
      projectId: 'fir-tutorial-35d29',
      storageBucket: "fir-tutorial-35d29.appspot.com",
    )
  ) : await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug
  );
  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool('onboarding')??false;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ChatPageActiveProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        // Thêm các provider khác nếu cần
      ],
      child: MyApp(onboarding: onboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // routerConfig: router,
      debugShowCheckedModeBanner: false,
      home: onboarding ? const AuthPage() : const OnBoardingScreen(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnBoardingScreen(),
      // routes: [
      //   GoRoute(
      //     path: 'login',
      //     builder: (_,__) => AuthPage(),
      //   ),
      // ]
    ),
    // GoRoute(
    //   path: '/chat',
    //   builder: (context, state) =>  ChatPage(),
    // ),
  ]
);


