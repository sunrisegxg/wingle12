import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FireBaseServices2 {
  Map<String, dynamic>? _userData;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login(permissions: ['email,']);
    try {
      if (loginResult == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        _userData = userData;
      } else if (loginResult.status == LoginStatus.cancelled) {
        print("User cancelled login");
        return null; // Trả về null để biểu thị rằng người dùng đã hủy đăng nhập
      } else if (loginResult.status == LoginStatus.failed) {
        print("Login failed");
        return null; // Trả về null để xử lý trường hợp đăng nhập thất bại
      }
      final OAuthCredential oAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
      return FirebaseAuth.instance.signInWithCredential(oAuthCredential);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }
  Future<void> signOut() async {
    await _auth.signOut();
    await FacebookAuth.instance.logOut();
  }
}