import 'dart:io';
import 'dart:math';

import 'package:app/pages/detailed_page/mypost.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class OtherVideoSection extends StatefulWidget {
  final String uid;
  final String postId;
  const OtherVideoSection({super.key, required this.postId, required this.uid});
  @override
  State<OtherVideoSection> createState() => _OtherVideoSectionState();
}

class _OtherVideoSectionState extends State<OtherVideoSection> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  int videoCount = 0;
  @override
  void initState() {
    getVideoCount();
    super.initState();
  }

  Future<void> getVideoCount() async {
    try {
      
      CollectionReference videosRef = FirebaseFirestore.instance.collection('posts');
      QuerySnapshot snapshot1 = await videosRef.where('uid', isEqualTo: currentUser.uid).where('videoPost', isNotEqualTo: '').get();
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
        .where('uid', isEqualTo: currentUser.uid)
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
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return videoCount > 0
        ? FutureBuilder(
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
                videoDataList.shuffle(Random());
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'My other video posts',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      height: 150,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List.generate(
                            videoDataList.length,
                            (index) {
                              final videoData = videoDataList[index]
                                  as Map<String, dynamic>;
                              String videoPost = videoData['videoPost'] as String;
                              String postId = videoData['postId'] as String;
                              return postId == widget.postId ? Container() : Padding(
                                padding: const EdgeInsets.only(
                                  right: 10.0,
                                  bottom: 16.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MyPost(postId: postId),
                                        ),
                                      );
                                    },
                                    child: FadeInImage(
                                      placeholder: AssetImage(
                                          'assets/shimmer_placeholder.png'),
                                      image: FileImage(File(videoPost)),
                                      fit: BoxFit.cover,
                                      height: MediaQuery.of(context).size.height,
                                      width: 150,
                                      fadeInDuration:
                                          Duration(milliseconds: 500),
                                      placeholderErrorBuilder:
                                          (context, error, stackTrace) {
                                        return Shimmer.fromColors(
                                          baseColor: isDarkMode
                                              ? Colors.black54
                                              : Colors.black26,
                                          highlightColor: isDarkMode
                                              ? Colors.white30
                                              : Colors.white38,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.black54,
                                            ),
                                            height: MediaQuery.of(context).size.height,
                                            width: 150,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            })
        : Center(
            // child: Text('No images available'),
            );
  }
}
