import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class AuthService {
  //instance of auth & firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //sign in
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      //sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password
      );
      // log("\nUser: ${userCredential.user}");
      // log("\nUserAdditionalInfo: ${userCredential.additionalUserInfo}");
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: 1007293522,
        appSign: '20962baf250e829a7e9b17ddc9a03f4d5345db7bd344079264bb0e80a47d7d55',
        // callID: widget.callid,
        userID: getCurrentUser()!.uid,
        userName: "User : ${getCurrentUser()!.uid}",
        plugins: [ZegoUIKitSignalingPlugin()],
        config: ZegoCallInvitationConfig(
          permissions: [
            ZegoCallInvitationPermission.microphone,
            ZegoCallInvitationPermission.camera,
          ]),
        requireConfig: (ZegoCallInvitationData data) {
          if (data.type == ZegoCallType.videoCall) {
            return ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              ..turnOnCameraWhenJoining = false
              ..turnOnMicrophoneWhenJoining = true
              ..useSpeakerWhenJoining = false;
          } else if (data.type == ZegoCallType.voiceCall) {
            return ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
              // ..turnOnCameraWhenJoining = false
              ..turnOnMicrophoneWhenJoining = true
              ..useSpeakerWhenJoining = false;
          } else {
            // Trả về cấu hình mặc định hoặc null
            return ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall() // Hoặc cấu hình nào đó bạn muốn
              ..turnOnMicrophoneWhenJoining = true
              ..useSpeakerWhenJoining = false;
          }
        },
        

      );
      // String userId = userCredential.user!.uid; // You can use the Firebase user ID
      // String userName = userCredential.user!.displayName ?? 'User'; // Get display name or set a default
      // // Now call ZegoKit login
      // await ZIMKit().connectUser(id: userId, name: userName);
      // //save user info if it doesn't already exist
      // await _firestore.collection("users").doc(userCredential.user!.uid).set(
      //   {
      //     'uid': userCredential.user!.uid,
      //     'email': email,
      //   }
      // );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign up
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password, String firstName, String lastName, String age, String phoneNumber, String job, String bio, String avatar, List<dynamic> following, List<dynamic> followers) async {
    try {
      //create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password
      );
      // if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty || age.isEmpty) {
      //   throw Exception('Please fill in all required fields');
      // }
      // // Cập nhật thông tin người dùng với tên hiển thị
      // await userCredential.user?.updateDisplayName(firstName + ' ' + lastName);
      //save user info in a separate doc
      await _firestore.collection("users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
          'first name': firstName,
          'last name': lastName,
          'age': age,
          'phone number': phoneNumber,
          'job' : job,
          'bio': bio,
          'avatar': avatar,
          'following': following,
          'followers' : followers,
        }
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  //sign out
  Future<void> signOut() async {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    return await _auth.signOut();
  }
  //errors
}