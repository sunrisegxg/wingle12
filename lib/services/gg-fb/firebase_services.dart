import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FireBaseServices {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  
  // _checkIfisLoggedIn() async {
  //   final accessToken = await FacebookAuth.instance.accessToken;

  //   setState(() {
  //     _checking = false;
  //   }
  // }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = 
        await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = 
          await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        await _auth.signInWithCredential(authCredential);
        return true; // Trả về true nếu quá trình đăng nhập thành công
      } else {
        return false; // Trả về false nếu quá trình đăng nhập không thành công
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }
  
  signOut() async {
    await _auth.signOut();
    // await _googleSignIn.signOut();
  }

  
}