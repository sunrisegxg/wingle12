import 'package:app/pages/detailed_page/mypost.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ImageView extends StatefulWidget {
  const ImageView({super.key});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  int imageCount = 0;
  @override
  void initState() {
    getImageCount();
    super.initState();
  }

  Future<void> getImageCount() async {
    try {
      CollectionReference imagesRef =
          FirebaseFirestore.instance.collection('posts');
      QuerySnapshot snapshot1 = await imagesRef
          .where('uid', isEqualTo: currentUser.uid)
          .where('imagePost', isNotEqualTo: '')
          .get();
      setState(() {
        imageCount = snapshot1.size;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<Map<String, dynamic>> getImageData(int index) async {
    try {
      CollectionReference imagesRef =
          FirebaseFirestore.instance.collection('posts');
      QuerySnapshot snapshot = await imagesRef
          .where('uid', isEqualTo: currentUser.uid)
          .where('imagePost', isNotEqualTo: '')
          .get();
      List<DocumentSnapshot> documents = snapshot.docs;
      documents.sort((a, b) => b['timepost'].compareTo(a['timepost']));

      DocumentSnapshot imageDoc = documents[index];
      String imagePost = imageDoc['imagePost'];
      String postId = imageDoc['postId'];
      return {'imagePost': imagePost, 'postId': postId};
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(right: 5.0, top: 20.0, left: 25.0,),
      child: imageCount > 0
          ? FutureBuilder(
              future: Future.wait(
                  [for (var i = 0; i < imageCount; i++) getImageData(i)]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<Map<String, dynamic>> imageDataList =
                      snapshot.data as List<Map<String, dynamic>>;
                  return MasonryGridView.builder(
                    itemCount: imageCount,
                    // physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      Map<String, dynamic> imageData = imageDataList[index];
                      String imagePost = imageData['imagePost'] as String;
                      String postId = imageData['postId'] as String;
                      return Padding(
                        padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyPost(postId: postId),
                                ),
                              );
                            },
                            child: FadeInImage(
                              placeholder: AssetImage('assets/shimmer_placeholder.png'),
                              image: NetworkImage(imagePost), 
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
              },
            )
          : Center(
              child: Text('No images available'),
            ),
    );
  }
}
