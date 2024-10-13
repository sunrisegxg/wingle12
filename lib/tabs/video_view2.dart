import 'dart:io';
import 'dart:typed_data';

import 'package:app/pages/detailed_page/mypost.dart';
import 'package:app/pages/detailed_page/yourpost.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoView2 extends StatefulWidget {
  const VideoView2({super.key, required this.uid});
  final String uid;
  @override
  State<VideoView2> createState() => _VideoView2State();
}

class _VideoView2State extends State<VideoView2> {
  int videoCount = 0;
  // final currentUser = FirebaseAuth.instance.currentUser!;
  // late String thumbnailPath;
  @override
  void initState() {
    getVideoCount();
    // clearThumbnailDirectory();
    super.initState();
  }
  Future<void> getVideoCount() async {
    try {
      
      CollectionReference videosRef = FirebaseFirestore.instance.collection('posts');
      QuerySnapshot snapshot1 = await videosRef.where('uid', isEqualTo: widget.uid).where('videoPost', isNotEqualTo: '').get();
      setState(() {
        videoCount = snapshot1.size;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getVideoData(int index) async {
    try {
      CollectionReference videosRef = FirebaseFirestore.instance.collection('posts');
      QuerySnapshot snapshot = await videosRef
        .where('uid', isEqualTo: widget.uid)
        .where('videoPost', isNotEqualTo: '').get();
      List<DocumentSnapshot> documents = snapshot.docs;
      documents.sort((a, b) => b['timepost'].compareTo(a['timepost']));
      DocumentSnapshot videoDoc = documents[index];
      String videoPost = videoDoc['videoPost'];
      String postId = videoDoc['postId'];
      // Tạo thư mục con riêng cho mỗi video
      final tempDir = await getTemporaryDirectory();
      final videoDir = Directory('${tempDir.path}/videos/$postId');
      if (!videoDir.existsSync()) {
        videoDir.createSync(recursive: true);
      }
      final thumbnailPath = videoDir.path;
      // Directory tempDir = await getTemporaryDirectory();
      final thumbnailFile  = await VideoThumbnail.thumbnailFile(
        video: videoPost,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.PNG, // Định dạng ảnh đại diện
        maxHeight: 100, // Chiều cao tối đa của ảnh đại diện
        quality: 100, // Chất lượng ảnh đại diện
      );

      return {'videoPost': thumbnailFile , 'postId': postId};
    } catch (e) {
      throw e;
    }
  }
@override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(right: 5.0, top: 20.0, left: 25.0,),
      child: videoCount > 0 ? FutureBuilder(
        future: Future.wait(
                  [for (var i = 0; i < videoCount; i++) getVideoData(i)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Map<String, dynamic>> videoDataList =
                snapshot.data as List<Map<String, dynamic>>;
            return MasonryGridView.builder(
              itemCount: videoCount,
              // physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                Map<String, dynamic> videoData = videoDataList[index];
                String videoPost = videoData['videoPost'] as String;
                String postId = videoData['postId'] as String;
                return Padding(
                  padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onTap:() {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => YourPost(postId: postId, uid: widget.uid),));
                      },
                      child: FadeInImage(
                        placeholder: AssetImage('assets/shimmer_placeholder.png'),
                        image: FileImage(File(videoPost)),
                        fit: BoxFit.cover,
                        height: 125,
                        fadeInDuration: Duration(milliseconds: 500),
                        placeholderErrorBuilder: (context, error, stackTrace) {
                          return Shimmer.fromColors(
                            baseColor: isDarkMode ? Colors.black54 : Colors.black26,
                            highlightColor: isDarkMode ? Colors.white30 : Colors.white38,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black54,
                              ),
                              height: 125,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
      )
      : Center(
        child: Text('No videos available'),
      )
    );
  }
}