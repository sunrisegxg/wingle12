
import 'dart:io';

import 'package:app/components/navigationprovider.dart';
import 'package:app/components/page_common.dart';
import 'package:app/intro/onboarding_screen.dart';
import 'package:app/pages/bottom_app_bar_page/home_page.dart';
import 'package:app/pages/bottom_app_bar_page/message_page.dart';
import 'package:app/pages/detailed_page/chat_page.dart';
import 'package:app/provider/search_history_provider.dart';
import 'package:app/services/auth/auth_page.dart';
import 'package:app/storage/dynamics_link.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
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
  DynamicLinkProvider().initDynamicLink();
  /// 1.1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool('onboarding')??false;
  final isLoggedIn = prefs.getBool('isLoggedIn')??false;
  // call the useSystemCallingUI
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => ChatPageActiveProvider()),
          ChangeNotifierProvider(create: (context) => NavigationProvider()),
          ChangeNotifierProvider(create: (context) => SearchHistoryProvider()),
          // Thêm các provider khác nếu cần
        ],
        child: MyApp(
          onboarding: onboarding,
          isLoggedIn: isLoggedIn,
          navigatorKey: navigatorKey,
        ),
      ),
    );
  });
  
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final bool onboarding;
  final bool isLoggedIn;
  const MyApp({super.key, this.onboarding = false, this.isLoggedIn = false, required this.navigatorKey});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      // routerConfig: router,
      debugShowCheckedModeBanner: false,
      home: (widget.onboarding) 
        ? (widget.isLoggedIn) 
          ? const CommonPage() : const AuthPage()
        : const OnBoardingScreen(),
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


