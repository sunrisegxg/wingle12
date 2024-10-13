import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreDataImage {
  Future<String> uploadImageToStorage(String uid, Uint8List file) async {
    try {
      String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
      Reference refRoot = _storage.ref();
      Reference refDirImages = refRoot.child('profileImage');
      Reference refImageToUpload = refDirImages.child(uniqueFileName);
      UploadTask uploadTask = refImageToUpload.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print(error.toString());
      return "";
    }
  }
}