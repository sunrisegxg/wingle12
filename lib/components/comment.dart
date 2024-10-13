import 'package:app/pages/detailed_page/other_accounts_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Comment{
  Future<bool> comments({
    required String comment,
    required String type,
    required String postuid,
    required String uid,
    required List likeComment,
  }) async {
    var uid2 = Uuid().v4();
    Timestamp timeComment = Timestamp.now();
    await FirebaseFirestore.instance
        .collection(type)
        .doc(postuid)
        .collection('comments')
        .doc(uid2)
        .set({
      'comment': comment,
      'timeComment': timeComment,
      'uid': uid,
      'uidComment': uid2,
      'likeComment': likeComment,
    });
    return true;
  }
}
