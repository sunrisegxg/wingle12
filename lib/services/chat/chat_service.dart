import 'package:app/storage/message.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {

  //get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user stream

  /* List<Map<String, dynamic> =
  [
    {
    'email': test@gmai.com,
    'id': ..
    }
    {
    'email': test@gmai.com,
    'id': ..
    }
    {
    'email': test@gmai.com,
    'id': ..
    }
  ]
  
   abc 
   ade*/
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        // return user
        return user;
      }).toList();
    });
  }

  Future<DateTime?> getLastMessageTime(String userID, String otherUserID) async {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    final snapshot = await _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .orderBy("timestamp", descending: true)
      .limit(1)
      .get();

    if (snapshot.docs.isNotEmpty) {
      return (snapshot.docs.first.data()["timestamp"] as Timestamp).toDate();
    } else {
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserStreamSorted() {
    return FirebaseFirestore.instance.collection("users").snapshots().asyncMap((snapshot) async {
      final List<Map<String, dynamic>> users = snapshot.docs.map((doc) => doc.data()).toList();

      // Tạo một danh sách chứa các Future để lấy thời gian mới nhất của tin nhắn từ mỗi người dùng
      List<Future<Map<String, dynamic>>> futures = [];

      // Lặp qua danh sách người dùng và thêm các Future vào danh sách futures
      for (var user in users) {
        futures.add(getLastMessageTime(user["uid"], AuthService().getCurrentUser()!.uid).then((DateTime? lastMessageTime) {
          // Thêm thời gian mới nhất của tin nhắn vào dữ liệu người dùng
          user["lastMessageTime"] = lastMessageTime;
          return user;
        }));
      }

      // Sử dụng phương thức Future.wait để đợi tất cả các Future hoàn thành và lấy kết quả
      List<Map<String, dynamic>> updatedUsers = await Future.wait(futures);

      // Sắp xếp danh sách người dùng dựa trên thời gian mới nhất của tin nhắn
      updatedUsers.sort((a, b) {
        DateTime timeA = a["lastMessageTime"] ?? DateTime(0);
        DateTime timeB = b["lastMessageTime"] ?? DateTime(0);
        return timeB.compareTo(timeA);
      });

      return updatedUsers;
    });
  }

  //send message
  Future<void> sendMessage(String receiverID, message) async {
   // get current user info
   final String currentUserID = _auth.currentUser!.uid;
   final String currentUserEmail = _auth.currentUser!.email!;
   final Timestamp timestamp = Timestamp.now();
   //create a new message
   Message newMessage = Message(
    senderID: currentUserID,
    senderEmail: currentUserEmail,
    receiverID: receiverID,
    message: message,
    timestamp: timestamp
    );
  
   //construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

   // add new message to database
   await _firestore
    .collection("chat_rooms")
    .doc(chatRoomID)
    .collection("messages")
    .add(newMessage.toMap());
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construc a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore.collection("chat_rooms").doc(chatRoomID).collection("messages").orderBy("timestamp", descending: false).snapshots();
  }
  Stream<QuerySnapshot> getMessages3(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .orderBy("timestamp", descending: true)
      .snapshots()
      .where((snapshot) => snapshot.docs.isNotEmpty); // Chỉ trả về khi danh sách tin nhắn không rỗng
  }
  Future<void> deleteMessages(String userID, otherUserID) async {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    final CollectionReference messagesRef = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages');

    // Get all documents in the messages collection
    QuerySnapshot messagesSnapshot = await messagesRef.get();

    // Delete each document
    for (DocumentSnapshot doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }
  }
  Future<void> deleteMessagesWithCondition(String userID, otherUserID) async {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    QuerySnapshot messagesSnapshot = await _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .where('senderID', isEqualTo: otherUserID)
      .get();

    QuerySnapshot otherMessagesSnapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .where('receiverID', isEqualTo: otherUserID)
        .get();

    // Combine the two snapshots into one.
    List<QueryDocumentSnapshot> combinedSnapshots = [];
    combinedSnapshots.addAll(messagesSnapshot.docs);
    combinedSnapshots.addAll(otherMessagesSnapshot.docs);

    WriteBatch batch = _firestore.batch();

    for (QueryDocumentSnapshot messageDoc in combinedSnapshots) {
      batch.delete(messageDoc.reference);
    }

    await batch.commit();
  }

}