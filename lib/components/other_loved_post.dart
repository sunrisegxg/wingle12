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
class OtherLovedSection extends StatefulWidget {
  final String uid;
  final String postId;
  const OtherLovedSection({super.key, required this.postId, required this.uid});
  @override
  State<OtherLovedSection> createState() => _OtherLovedSectionState();
}

class _OtherLovedSectionState extends State<OtherLovedSection> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  int postCount = 0;
  @override
  void initState() {
    getPostCount();
    super.initState();
  }

  Future<void> getPostCount() async {
    try {
      CollectionReference docsRef =
          FirebaseFirestore.instance.collection('posts');
      QuerySnapshot snapshot1 =
          await docsRef.where('like', arrayContains: currentUser.uid).get();
      setState(() {
        postCount = snapshot1.size;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return postCount > 0
    ? FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('posts')
            .where('like', arrayContains: currentUser.uid)
            .orderBy('timepost', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            QuerySnapshot postData = snapshot.data as QuerySnapshot;
            List<QueryDocumentSnapshot> postDocs = postData.docs;
            postDocs.shuffle(Random());
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'My other loved posts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  height: 150,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(postDocs.length, (index) {
                          final post = postDocs[index].data() as Map<String, dynamic>;
                          return post['postId'] == widget.postId ? Container() : Padding(
                            padding: const EdgeInsets.only(right: 10.0, bottom: 16.0,),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FutureBuilder(
                                future: () async {
                                  if (post['imagePost'] != null &&
                                      post['videoPost'] == null) {
                                    return post['imagePost'];
                                  } else if (post['videoPost'] != null &&
                                      post['imagePost'] == null) {
                                    try {
                                      final tempDir = await getTemporaryDirectory();
                                      final videoDir = Directory(
                                          "${tempDir.path}/videos/${post['postId']}");
                                      if (!videoDir.existsSync()) {
                                        videoDir.createSync(recursive: true);
                                      }
                                      final thumbnailPath = videoDir.path;
                                      final thumbnailFile =
                                          await VideoThumbnail.thumbnailFile(
                                        video: post['videoPost'],
                                        thumbnailPath: thumbnailPath,
                                        imageFormat: ImageFormat.PNG,
                                        maxHeight: 100,
                                        quality: 100,
                                      );
                                      return thumbnailFile;
                                    } catch (e) {
                                      print("Error generating video thumbnail: $e");
                                      return null;
                                    }
                                  } else {
                                    return null;
                                  }
                                }(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container();
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text("Error: ${snapshot.error}"));
                                  } else {
                                    if (post['imagePost'] != null &&
                                        post['videoPost'] == null) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MyPost(postId: post['postId']),
                                            ),
                                          );
                                        },
                                        child: FadeInImage(
                                          placeholder: AssetImage('assets/shimmer_placeholder.png'),
                                          image: NetworkImage(post['imagePost']), 
                                          fit: BoxFit.cover,
                                          height: MediaQuery.of(context).size.height,
                                           width: 150,
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
                                                height: MediaQuery.of(context).size.height,
                                                width: 150,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    } else if (post['videoPost'] != null &&
                                        post['imagePost'] == null) {
                                      final videoUrl = snapshot.data as String;
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MyPost(postId: post['postId']),
                                            ),
                                          );
                                        },
                                        child: FadeInImage(
                                          placeholder: AssetImage('assets/shimmer_placeholder.png'),
                                          image: FileImage(File(videoUrl)),
                                          fit: BoxFit.cover,
                                          height: MediaQuery.of(context).size.height,
                                          width: 150,
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
                                                height: MediaQuery.of(context).size.height,
                                                width: 150,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    return Container();
                                  }
                                },
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
        }
    )
    : Center(
        // child: Text('No images available'),
    );
  }
}