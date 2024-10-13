import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreDataVideoPost {
  Future<String> uploadVideoPostToStorage(String uid, File videoURL) async {
    try {
      String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
      Reference refRoot = _storage.ref();
      Reference refDirVideos = refRoot.child('postVideo');
      Reference refVideoToUpload = refDirVideos.child(uniqueFileName);
      await refVideoToUpload.putFile(videoURL);
      String downloadUrl = await refVideoToUpload.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print(error.toString());
      return "";
    }
  }
}