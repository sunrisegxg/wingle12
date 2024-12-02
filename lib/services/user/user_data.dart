import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  // lấy 1 bản ghi của người dùng dựa vào uid
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  // lấy 1 bản ghi của người dùng trả về tên của người dùng
  Future getUserName(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        String firstName = doc.get('first name');
        String lastName = doc.get('last name');
        return "$firstName $lastName";
      }
      return null;
    } catch (e) {
      print("Error getting current user name: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    List<Map<String, dynamic>> postsList = [];

    // Lấy tất cả documents trong collection 'posts'
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('posts').get();

    // Thu thập tất cả uid
    Set<String> uids =
        querySnapshot.docs.map((doc) => doc['uid'] as String).toSet();

    // Lấy thông tin người dùng
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: uids.toList())
        .get();
    Map<String, Map<String, dynamic>> usersData = {
      for (var doc in usersSnapshot.docs)
        doc.id: doc.data() as Map<String, dynamic>
    };

    // Kết hợp thông tin bài post và người dùng
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
      String uid = postData['uid'];
      Map<String, dynamic>? userData = usersData[uid];

      if (userData != null) {
        postData['first name'] = userData['first name'];
        postData['last name'] = userData['last name'];
        postData['avatar'] = userData['avatar'];
      }

      postsList.add(postData);
    }

    return postsList;
  }
}
