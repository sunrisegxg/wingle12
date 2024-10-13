import 'package:app/services/auth/auth_page.dart';
import 'package:app/components/page_common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
final GlobalKey<CommonPageState> commonPageKey = GlobalKey<CommonPageState>();

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is logged in
          if (snapshot.hasData) {
            return CommonPage(
              key: commonPageKey,
            );
            // user is not logged in
          } else {
            return const AuthPage();
          }
        },
      )
    );
  }
}