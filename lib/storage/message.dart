import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String? message;
  final String? imageUrl;
  final String? videoUrl;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileExtension;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    this.message,
    this.imageUrl,
    this.videoUrl,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileExtension,
    required this.timestamp,
  });

  // Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileExtension': fileExtension,
      'timestamp': timestamp,
    };
  }
}
