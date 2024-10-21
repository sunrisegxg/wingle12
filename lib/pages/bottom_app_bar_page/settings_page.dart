import 'package:app/components/navigationprovider.dart';
import 'package:app/pages/detailed_page/language_page.dart';
import 'package:app/services/auth/auth_page.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/chat/chat_service.dart';
import 'package:app/services/gg-fb/firebase_services.dart';
import 'package:app/services/gg-fb/firebase_services2.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({super.key});

  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  void logout() async {
    final _auth = AuthService();
    _auth.signOut();
  }
  Stream<List<Map<String, dynamic>>> userStream = ChatService().getUserStream();
  //Xóa doc đơn
  Future<void> deleteDocumentsByField(String collectionName, String fieldName, dynamic value) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionName).where(fieldName, isEqualTo: value).get();
    final List<DocumentSnapshot> documents = snapshot.docs;

    if (documents.isNotEmpty) {
      for (DocumentSnapshot document in documents) {
        await document.reference.delete();
      }

      print('Deleted documents from collection: $collectionName where $fieldName = $value');
    } else {
      print('No documents found in collection: $collectionName where $fieldName = $value');
    }
  }
  // xóa đữ liệu trường mảng
  Future<void> deleteDocumentsByFieldCondition(String collectionName, String fieldName, String fieldValue) async {
  // Truy vấn các tài liệu trong bộ sưu tập có trường followers chứa giá trị fieldValue
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionName).where(fieldName, arrayContains: fieldValue).get();

    // Lặp qua tất cả các tài liệu thỏa điều kiện
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      // Xóa trường fieldName khỏi tài liệu
      await doc.reference.update({
        fieldName: FieldValue.arrayRemove([fieldValue]),
      });
    }
  }

  // Xóa doc collection2 
  Future<void> deleteCommentsByUID(String uid) async {
    try {
      // Truy vấn tất cả các tài liệu trong collection 'posts' để lấy ra 'postId'.
      QuerySnapshot postSnapshot =
          await FirebaseFirestore.instance.collection('posts').get();

      // Lặp qua tất cả các tài liệu trong collection để lấy ra 'postId'.
      for (QueryDocumentSnapshot postDoc in postSnapshot.docs) {
        // Lấy ra 'postId' từ mỗi tài liệu.
        String postId = postDoc.id;

        // Truy vấn tất cả các tài liệu trong bộ sưu tập 'comments' có trường 'uid' bằng với giá trị 'uid'.
        QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .where('uid', isEqualTo: uid)
            .get();

        // Tạo một batch để xóa tất cả các tài liệu trong snapshot.
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // Lặp qua từng tài liệu trong snapshot và thêm chúng vào batch để xóa.
        commentSnapshot.docs.forEach((doc) {
          batch.delete(doc.reference);
        });

        // Commit batch để xóa tất cả các tài liệu một cách an toàn và hiệu quả.
        await batch.commit();
      }
    } catch (error) {
      // Xử lý lỗi nếu có.
      print('Error deleting comments: $error');
    }
  }
  //Xóa 2 với array
  Future<void> deleteLikesComment(String userId) async {
    // Lấy tất cả các bài viết từ bảng posts
    QuerySnapshot postSnapshot = await FirebaseFirestore.instance.collection('posts').get();
    
    // Lặp qua tất cả các bài viết
    for (QueryDocumentSnapshot postDoc in postSnapshot.docs) {
      String postId = postDoc.id;

      // Tạo đường dẫn tới collection con message của postId
      CollectionReference messagesRef = FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments');

      // Truy vấn các tài liệu trong collection message có trường like chứa giá trị userId
      QuerySnapshot snapshot = await messagesRef.where('likeComment', arrayContains: userId).get();

      // Lặp qua tất cả các tài liệu thỏa điều kiện
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        // Xóa giá trị userId khỏi trường like của mỗi tài liệu
        await doc.reference.update({
          'likeComment': FieldValue.arrayRemove([userId]),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String senderID = AuthService().getCurrentUser()!.uid;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        // centerTitle: true,
        title: const Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Text(
          'Settings',
          style: TextStyle(
              fontSize: 25, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false, // mất nút quay về
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey.shade400,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 26.0),
            child: Text(
              "Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(left: 25, right: 25, bottom: 20, top: 10),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //dark mode
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:Colors.black, // Màu nền của hình tròn
                      ),
                      child: Center(
                        child: Icon(Icons.mode_night, size: 17, color: isDarkMode ? Colors.white : Colors.white,),
                      ),
                    ),
                    SizedBox(width: 10,),
                    const Text("Dark mode", style: TextStyle(fontSize: 17),),
                  ],
                ),
                //switch toggle
                CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
                  onChanged: (value) {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  },
                ),
              ]
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(),)),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(right: 25, left: 25, bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange.shade400, // Màu nền của hình tròn
                    ),
                    child: Center(
                      child: Icon(Icons.language, size: 17, color: isDarkMode ? Colors.white : Colors.white,),
                    ),
                  ),
                  SizedBox(width: 10,),
                  const Text("Language and region",  style: TextStyle(fontSize: 17),),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(right: 25, left: 25, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade400, // Màu nền của hình tròn
                  ),
                  child: Center(
                    child: Icon(Icons.check_circle, size: 17, color: isDarkMode ? Colors.white : Colors.white,),
                  ),
                ),
                SizedBox(width: 10,),
                const Text("Active status",  style: TextStyle(fontSize: 17),),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(right: 25, left: 25, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurpleAccent, // Màu nền của hình tròn
                  ),
                  child: Center(
                    child: Icon(Icons.list, size: 17, color: isDarkMode ? Colors.white : Colors.white,),
                  ),
                ),
                SizedBox(width: 10,),
                const Text("Activity diary",  style: TextStyle(fontSize: 17),),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(right: 25, left: 25, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.shade400, // Màu nền của hình tròn
                  ),
                  child: Center(
                    child: Icon(Icons.notifications, size: 17, color: isDarkMode ? Colors.white : Colors.white,),
                  ),
                ),
                SizedBox(width: 10,),
                const Text("Notification",  style: TextStyle(fontSize: 17),),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 26.0),
            child: Text(
              "Support",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(right: 25, left: 25, bottom: 20, top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey, // Màu nền của hình tròn
                  ),
                  child: Center(
                    child: Icon(Icons.description, size: 17, color: isDarkMode ? Colors.white : Colors.white,),
                  ),
                ),
                SizedBox(width: 10,),
                const Text("Terms and policies",  style: TextStyle(fontSize: 17),),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(right: 25, left: 25, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade400, // Màu nền của hình tròn
                  ),
                  child: Center(
                    child: Icon(Icons.help_outline, size: 17, color: isDarkMode ? Colors.white : Colors.white,),
                  ),
                ),
                SizedBox(width: 10,),
                const Text("Help",  style: TextStyle(fontSize: 17),),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 26.0),
            child: Text(
              "Exit",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () async {
              logout();
              await FireBaseServices().signOut();
              await FireBaseServices2().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()), // Chuyển đến trang đăng nhập sau khi đăng xuất
              );
              Provider.of<NavigationProvider>(context, listen: false).resetIndex();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(right: 25, left: 25, bottom: 20, top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Log out
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyan.shade400, // Màu nền của hình tròn
                        ),
                        child: Center(
                          child: Icon(Icons.logout, size: 17, color: isDarkMode ? Colors.white : Colors.white,),
                        ),
                      ),
                      SizedBox(width: 10,),
                      const Text("Log out",  style: TextStyle(fontSize: 17),),
                    ],
                  ),
                ]
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              bool confirmDelete = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm delete'),
                  content: Text('Are you sure you want to delete your account?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black ),),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Delete', style: TextStyle(color: Colors.red),),
                    )
                  ],
                ),
              );
              if (confirmDelete == true) {
                final user = FirebaseAuth.instance.currentUser;
                await deleteDocumentsByFieldCondition('users', 'following', user!.uid); // xóa đang follow người
                await deleteDocumentsByFieldCondition('users', 'followers', user.uid); // xóa người follow
                await deleteDocumentsByFieldCondition('posts', 'like', user.uid); // xóa like bài đăng
                await deleteCommentsByUID(user.uid); // xóa comment bài đăng
                await deleteLikesComment(user.uid); // xóa like comment
                await deleteDocumentsByField('posts', 'uid', user.uid);// xóa cả bảng posts
                await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();// xóa cả bảng users
                await user.delete();// xóa tài khoản
                userStream.listen((List<Map<String, dynamic>> users) async { // xóa all chat liên quan tới tk
                  for (var user in users) {
                    var uid = user['uid']; // Lấy uid của người dùng
                    // Gọi hàm deleteMessagesWithCondition với userID là uid
                    await ChatService().deleteMessagesWithCondition(uid, senderID);
                  }
                });
                logout();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthPage(),));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(right: 25, left: 25, bottom: 20,),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade400, // Màu nền của hình tròn
                        ),
                        child: Center(
                          child: Icon(Icons.delete, size: 17, color: isDarkMode ? Colors.white : Colors.white,),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Text("Delete account",  style: TextStyle(fontSize: 17),),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ] 
      ),
    );
  }
}