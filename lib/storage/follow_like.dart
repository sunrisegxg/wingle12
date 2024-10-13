import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreDataFavorite {
  final user = FirebaseAuth.instance.currentUser!;
  //follow
  Future<String> follow(
    {required String uid}
  ) async {
    String res = 'Some errors';
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    List follow = (snapshot.data()! as dynamic)['following'];
    try {
      if (follow.contains(uid)) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
          {
            'following' : FieldValue.arrayRemove([uid])
          }
        );
        await FirebaseFirestore.instance.collection('users').doc(uid).update(
          {
            'followers' : FieldValue.arrayRemove([user.uid])
          }
        );
      } else {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
          {
            'following' : FieldValue.arrayUnion([uid])
          }
        );
        await FirebaseFirestore.instance.collection('users').doc(uid).update(
          {
            'followers' : FieldValue.arrayUnion([user.uid])
          }
        );
      }
      res = 'Success';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }
  //like
  Future<String> like({
    required List like,
    required String type,
    required String uid,
    required String postId,
  }) async {
    String res = 'some error';
    try {
      if (like.contains(uid)) {
        FirebaseFirestore.instance.collection(type).doc(postId).update({
          'like': FieldValue.arrayRemove([uid])
        });
      } else {
        FirebaseFirestore.instance.collection(type).doc(postId).update({
          'like': FieldValue.arrayUnion([uid])
        });
      }
      res = 'Success';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }
  //like comment
  Future<String> likecomment({
    required List like,
    required String type,
    required String uid,
    required String postId,
    required String uidComment
  }) async {
    String res = 'some error';
    try {
      if (like.contains(uid)) {
        FirebaseFirestore.instance.collection(type).doc(postId).collection('comments').doc(uidComment).update({
          'likeComment': FieldValue.arrayRemove([uid])
        });
      } else {
        FirebaseFirestore.instance.collection(type).doc(postId).collection('comments').doc(uidComment).update({
          'likeComment': FieldValue.arrayUnion([uid])
        });
      }
      res = 'Success';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }
}
