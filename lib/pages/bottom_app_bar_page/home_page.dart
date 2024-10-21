import 'dart:math';

import 'package:app/components/comment.dart';
import 'package:app/pages/detailed_page/search_common.dart';
import 'package:app/storage/follow_like.dart';
import 'package:app/storage/like_animation.dart';
import 'package:app/pages/detailed_page/other_accounts_page.dart';
import 'package:app/shimmer/shimmer_card.dart';
import 'package:app/shimmer/shimmer_user.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String?> translatedComments = {};
  Map<String, String> originalComments = {};
  bool isTranslated = false;
  bool isAnimating = false;
  bool isLoading = true;
  bool _isDisposed = false;
  final user = FirebaseAuth.instance.currentUser;
  final comment = TextEditingController();
  final List<VideoPlayerController?> _videoControllers = [];
  final List<ChewieController?> _chewieControllers = [];
  // List<String> videoUrls = []; // Danh sách video URLs rỗng
  loadData() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    loadData();
  }

  void _initializeControllers() {
    int defaultLength = 1000;
    for (int i = 0; i < defaultLength; i++) {
      _videoControllers.add(null);
      _chewieControllers.add(null);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    for (var chewieController in _chewieControllers) {
      chewieController?.dispose();
    }
    _videoControllers.clear();
    _chewieControllers.clear();
  }

  final translator = GoogleTranslator();

  Future<ChewieController?> _initializeVideoPlayer(
      String videoUrl, int index) async {
    try {
      if (_videoControllers[index] == null) {
        _videoControllers[index] =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await _videoControllers[index]!.initialize();
        _chewieControllers[index] = ChewieController(
          videoPlayerController: _videoControllers[index]!,
          autoPlay: false,
          looping: true,
        );
        // _videoControllers.add(_videoControllers[index]);
        // _chewieControllers.add(_chewieControllers[index]);
        return _chewieControllers[index];
      }
      return _chewieControllers[index];
    } catch (e) {
      print("Error generating video: $e");
      return null;
    }
  }

  String timestampToString(Timestamp timestamp) {
    DateTime now = DateTime.now();
    DateTime dateTime = timestamp.toDate();
    Duration difference = now.difference(dateTime);
    difference = difference.abs();
    if (difference.inDays > 0) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else {
      return getTimeAgo(difference);
    }
  }

  String getTimeAgo(Duration difference) {
    if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    if (user != null) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //   toolbarHeight: 65,
        //   // centerTitle: true,
        //   title: Padding(
        //     padding: const EdgeInsets.only(left: 5.0),
        //     child: Text(
        //       'Wingle',
        //       style: TextStyle(
        //           fontSize: 25, color: Colors.blue, fontWeight: FontWeight.bold),
        //     ),
        //   ),
        //   elevation: 0,
        //   automaticallyImplyLeading: false, // mất nút quay về
        //   backgroundColor: Colors.transparent,
        //   foregroundColor: Colors.grey,
        //   //logo
        //   // leading: Padding(
        //   //   padding: const EdgeInsets.only(
        //   //     left: 20.0,
        //   //   ),
        //   //   child: Image.asset(
        //   //     'lib/images/logo_1.png',
        //   //   ),
        //   // ),
        //   //share and
        //   actions: [
        //     Padding(
        //       padding: EdgeInsets.only(
        //         right: 5.0,
        //       ),
        //       child: Row(children: [
        //         IconButton(
        //           onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchCommon(),)),
        //           icon: const Icon(Icons.search),
        //           color: Colors.blue,
        //         ),
        //         IconButton(
        //           icon: const Icon(Icons.share),
        //           onPressed: () async {
        //             final result = await Share.shareWithResult(
        //                 'Welcome to Wingle: wingle19.page.link',
        //                 subject: 'Invitation');
        //             if (result.status == ShareResultStatus.success) {
        //               ScaffoldMessenger.of(context).showSnackBar(
        //                 SnackBar(
        //                   content: Text('Share successfully'),
        //                 ),
        //               );
        //             } else {
        //               ScaffoldMessenger.of(context).showSnackBar(
        //                 SnackBar(
        //                   content: Text('Share failure'),
        //                 ),
        //               );
        //             }
        //           },
        //           color: Colors.blue,
        //         ),
        //       ]),
        //     ),
        //   ],
        // ),

        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true, // AppBar sẽ hiện ra ngay khi cuộn xuống
                snap: true, // AppBar xuất hiện ngay lập tức mà không cần cuộn đến hết chiều dài
                pinned: false, // AppBar sẽ không được cố định trên cùng
                automaticallyImplyLeading: true,
                elevation: 0,
                backgroundColor: Colors.transparent, // màu header ban đầu
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Theme.of(context).colorScheme.background, // Giữ cùng màu với body
                  ),
                ),
                toolbarHeight: 65,
                title: const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Wingle',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchCommon()),
                          ),
                          icon: const Icon(Icons.search),
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () async {
                            final result = await Share.shareWithResult(
                              'Welcome to Wingle: wingle19.page.link',
                              subject: 'Invitation',
                            );
                            if (result.status == ShareResultStatus.success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Share successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Share failure')),
                              );
                            }
                          },
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('uid', isNotEqualTo: user!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      // Convert QuerySnapshot to List
                      List<DocumentSnapshot> docs = snapshot.data!.docs;
                      return RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(Duration(seconds: 2));
                          // setState(() {
                          //   docs.shuffle(Random());
                          //   _disposeControllers();
                          //   _initializeControllers();
                          // });
                        },
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable scrolling for ListView within CustomScrollView
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final postData =
                                docs[index].data() as Map<String, dynamic>;
                            return FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(postData['uid'])
                                    .get(),
                                builder: (context, usersnapshot) {
                                  if (usersnapshot.hasData &&
                                      usersnapshot.data!.data() != null) {
                                    final userData = usersnapshot.data!.data()
                                        as Map<String, dynamic>;
                                    bool isLiked = postData['like'] != null &&
                                        postData['like'].contains(user!.uid);
                                    return StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(postData['postId'])
                                          .collection('comments')
                                          .snapshots(),
                                      builder: (context, snapshot7) {
                                        if (!snapshot7.hasData) {
                                          return Container();
                                        }
                                        final int postCommentCount =
                                            snapshot7.data!.docs.length;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0, vertical: 10.0),
                                          child: Column(children: [
                                            Center(
                                              child: isLoading
                                                  ? const ShimmerUser()
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                            // borderRadius: BorderRadius.circular(50),
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            OtherAccountsPage(
                                                                      uid: userData[
                                                                          'uid'],
                                                                      initialTabIndex:
                                                                          0,
                                                                    ),
                                                                  ));
                                                            },
                                                            child: ListTile(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              leading: ClipOval(
                                                                child: SizedBox(
                                                                  width: 50,
                                                                  height: 50,
                                                                  child: Image
                                                                      .network(
                                                                    userData[
                                                                        'avatar'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              title: Text(
                                                                userData[
                                                                        'first name'] +
                                                                    ' ' +
                                                                    userData[
                                                                        'last name'],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              subtitle: Row(
                                                                children: [
                                                                  Text(
                                                                    timestampToString(
                                                                        postData[
                                                                            'timepost']),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors.grey[
                                                                            600],
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                  postData['location'] ==
                                                                          ''
                                                                      ? Container()
                                                                      : Container(
                                                                          width:
                                                                              188,
                                                                          child:
                                                                              Text(
                                                                            ' · in ' +
                                                                                postData['location'],
                                                                            maxLines:
                                                                                1, // Giới hạn số dòng
                                                                            overflow:
                                                                                TextOverflow.ellipsis, // Hiển thị dấu ...
                                                                            style: TextStyle(
                                                                                fontSize: 15,
                                                                                color: Colors.grey[600],
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        )
                                                                ],
                                                              ),
                                                              // trailing:
                                                              //     Icon(Icons.more_horiz),
                                                            ),
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //   padding: const EdgeInsets.only(
                                                        //       left: 20.0),
                                                        //   child: IconButton(
                                                        //     icon: Icon(Icons.more_horiz),
                                                        //     onPressed: () {},
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                            ),
                                            isLoading
                                                ? const ShimmerCard()
                                                : Container(
                                                    // margin: EdgeInsets.symmetric(
                                                    //     horizontal: 20.0),
                                                    decoration: BoxDecoration(
                                                      color: isDarkMode
                                                          ? Colors.grey[800]
                                                          : Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10.0,
                                                                  right: 10.0,
                                                                  top: 10.0),
                                                          child: postData[
                                                                      'imagePost'] !=
                                                                  null
                                                              ? ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  child: Image
                                                                      .network(
                                                                    postData[
                                                                        'imagePost'],
                                                                    height: 250,
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                )
                                                              : postData['videoPost'] !=
                                                                      null
                                                                  ? FutureBuilder<
                                                                      ChewieController?>(
                                                                      future: _initializeVideoPlayer(
                                                                          postData[
                                                                              'videoPost'],
                                                                          index),
                                                                      builder:
                                                                          (context,
                                                                              snapshot26) {
                                                                        if (!snapshot26
                                                                            .hasData) {
                                                                          return Container(
                                                                            height:
                                                                                250,
                                                                            child:
                                                                                Center(
                                                                              child: CircularProgressIndicator(),
                                                                            ),
                                                                          );
                                                                        }
                                                                        return ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                          child:
                                                                              AspectRatio(
                                                                            aspectRatio:
                                                                                MediaQuery.of(context).size.width / 250,
                                                                            child:
                                                                                Chewie(
                                                                              controller: snapshot26.data!,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    )
                                                                  : Container(
                                                                      height:
                                                                          250,
                                                                      child: Center(
                                                                          child:
                                                                              CircularProgressIndicator()),
                                                                    ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      12.0),
                                                          child: Row(
                                                            // mainAxisAlignment:
                                                            //     MainAxisAlignment
                                                            //         .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  LikeAnimation(
                                                                    isAnimating:
                                                                        isLiked,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          StoreDataFavorite().like(
                                                                              like: postData['like'],
                                                                              type: 'posts',
                                                                              uid: user!.uid,
                                                                              postId: postData['postId']);
                                                                        },
                                                                        child: isLiked
                                                                            ? Image.asset(
                                                                                'lib/images/heart.png',
                                                                                height: 28,
                                                                              )
                                                                            : Image.asset(
                                                                                'lib/images/hearted.png',
                                                                                height: 28,
                                                                                color: isDarkMode ? Colors.white : Colors.black,
                                                                              )),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    postData[
                                                                            'like']
                                                                        .length
                                                                        .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                width: 40,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Row(
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            showModalBottomSheet(
                                                                                // backgroundColor: Colors.transparent,
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return StatefulBuilder(builder: (context, setModalState) {
                                                                                    return Padding(
                                                                                      padding: EdgeInsets.only(
                                                                                        bottom: MediaQuery.of(context).viewInsets.bottom,
                                                                                      ),
                                                                                      child: DraggableScrollableSheet(
                                                                                        maxChildSize: 1,
                                                                                        initialChildSize: 1,
                                                                                        minChildSize: 0.2,
                                                                                        builder: (context, scrollController) {
                                                                                          return ClipRRect(
                                                                                            borderRadius: BorderRadius.only(
                                                                                              topLeft: Radius.circular(25),
                                                                                              topRight: Radius.circular(25),
                                                                                            ),
                                                                                            child: Container(
                                                                                              color: isDarkMode ? Theme.of(context).colorScheme.background : Colors.white,
                                                                                              height: 200,
                                                                                              child: Stack(
                                                                                                children: [
                                                                                                  Positioned(
                                                                                                    top: 8,
                                                                                                    left: 155,
                                                                                                    child: Container(
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: isDarkMode ? Colors.white : Colors.black,
                                                                                                        borderRadius: BorderRadius.circular(50),
                                                                                                      ),
                                                                                                      width: 100,
                                                                                                      height: 3,
                                                                                                    ),
                                                                                                  ),
                                                                                                  StreamBuilder<QuerySnapshot>(
                                                                                                    stream: FirebaseFirestore.instance.collection('posts').doc(postData['postId']).collection('comments').orderBy('timeComment', descending: true).snapshots(),
                                                                                                    builder: (context, snapshot3) {
                                                                                                      if (!snapshot3.hasData) {
                                                                                                        return CircularProgressIndicator();
                                                                                                      }
                                                                                                      return Padding(
                                                                                                        padding: const EdgeInsets.only(top: 20, bottom: 60),
                                                                                                        child: ListView.builder(
                                                                                                          itemBuilder: (context, index2) {
                                                                                                            var commentData = snapshot3.data!.docs[index2].data() as Map<String, dynamic>;
                                                                                                            bool isLiked2 = commentData['likeComment'] != null && commentData['likeComment'].contains(user!.uid);
                                                                                                            return FutureBuilder(
                                                                                                              future: FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: commentData['uid']).get(),
                                                                                                              builder: (context, snapshot19) {
                                                                                                                if (!snapshot19.hasData) {
                                                                                                                  return Container();
                                                                                                                }
                                                                                                                final userDocuments = snapshot19.data!.docs;
                                                                                                                if (userDocuments.isEmpty) {
                                                                                                                  return Container(); // Xử lý khi không có dữ liệu
                                                                                                                }
                                                                                                                final userCurrent = userDocuments[0].data() as Map<String, dynamic>;
                                                                                                                return Padding(
                                                                                                                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                                                                                                                  child: Row(
                                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                    children: [
                                                                                                                      Padding(
                                                                                                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                                                                                                        child: InkWell(
                                                                                                                          borderRadius: BorderRadius.circular(50),
                                                                                                                          onTap: () {
                                                                                                                            Navigator.push(
                                                                                                                                context,
                                                                                                                                MaterialPageRoute(
                                                                                                                                  builder: (context) => OtherAccountsPage(uid: userCurrent['uid'], initialTabIndex: 0),
                                                                                                                                ));
                                                                                                                          },
                                                                                                                          child: ClipOval(
                                                                                                                            child: SizedBox(
                                                                                                                              width: 50,
                                                                                                                              height: 50,
                                                                                                                              child: Image.network(
                                                                                                                                userCurrent['avatar'],
                                                                                                                                fit: BoxFit.cover,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      Expanded(
                                                                                                                        child: Column(
                                                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                          children: [
                                                                                                                            GestureDetector(
                                                                                                                              onLongPress: () async {
                                                                                                                                await showDialog(
                                                                                                                                  context: context,
                                                                                                                                  builder: (context) => Dialog(
                                                                                                                                    shape: RoundedRectangleBorder(
                                                                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                                                                    ),
                                                                                                                                    child: Container(
                                                                                                                                      width: MediaQuery.of(context).size.width, // Đặt chiều rộng gần sát rìa màn hình (95%)
                                                                                                                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                                                                                                                      child: Column(
                                                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                                                        children: [
                                                                                                                                          ListTile(
                                                                                                                                            onTap: () async {
                                                                                                                                              if (translatedComments[commentData['uidComment']] == null || translatedComments[commentData['uidComment']] == originalComments[commentData['uidComment']]) {
                                                                                                                                                originalComments[commentData['uidComment']] = commentData['comment'];
                                                                                                                                                await translator.translate(commentData['comment'], to: 'hi').then((output) {
                                                                                                                                                  setModalState(() {
                                                                                                                                                    translatedComments[commentData['uidComment']] = output.text; // Lưu vào map
                                                                                                                                                    isTranslated = true;
                                                                                                                                                  });
                                                                                                                                                });
                                                                                                                                                print('Comment after translation: ${translatedComments[commentData['uidComment']]}');
                                                                                                                                              } else {
                                                                                                                                                setModalState(() {
                                                                                                                                                  translatedComments[commentData['uidComment']] = originalComments[commentData['uidComment']];
                                                                                                                                                  isTranslated = false;
                                                                                                                                                });
                                                                                                                                                print('Comment after translation: ${originalComments[commentData['uidComment']]}');
                                                                                                                                              }
                                                                                                                                              Navigator.pop(context);
                                                                                                                                            },
                                                                                                                                            title: Text(
                                                                                                                                              isTranslated ? 'Hoàn tác' : "Dịch",
                                                                                                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                                                                            ),
                                                                                                                                            contentPadding: EdgeInsets.symmetric(
                                                                                                                                              horizontal: 12,
                                                                                                                                            ),
                                                                                                                                          ),
                                                                                                                                          // Thêm các item khác nếu cần
                                                                                                                                          ListTile(
                                                                                                                                            onTap: () {
                                                                                                                                              Clipboard.setData(ClipboardData(text: translatedComments[commentData['uidComment']] ?? commentData['comment']));
                                                                                                                                              Navigator.pop(context);
                                                                                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                                                                                SnackBar(content: Text('Đã sao chép văn bản!')),
                                                                                                                                              );
                                                                                                                                            },
                                                                                                                                            title: Text(
                                                                                                                                              'Sao chép',
                                                                                                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                                                                            ),
                                                                                                                                            contentPadding: EdgeInsets.symmetric(
                                                                                                                                              horizontal: 12,
                                                                                                                                            ),
                                                                                                                                          ),
                                                                                                                                          ListTile(
                                                                                                                                            onTap: () => Navigator.pop(context),
                                                                                                                                            title: Text(
                                                                                                                                              'Báo cáo',
                                                                                                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                                                                            ),
                                                                                                                                            contentPadding: EdgeInsets.symmetric(
                                                                                                                                              horizontal: 12,
                                                                                                                                            ),
                                                                                                                                          ),
                                                                                                                                        ],
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                  ),
                                                                                                                                );
                                                                                                                              },
                                                                                                                              child: Padding(
                                                                                                                                padding: const EdgeInsets.only(right: 8.0),
                                                                                                                                child: Container(
                                                                                                                                  decoration: BoxDecoration(
                                                                                                                                    color: isDarkMode ? Colors.grey[700] : Color.fromARGB(255, 225, 229, 242),
                                                                                                                                    borderRadius: BorderRadius.circular(15),
                                                                                                                                  ),
                                                                                                                                  child: ListTile(
                                                                                                                                    title: Row(
                                                                                                                                      children: [
                                                                                                                                        Text(
                                                                                                                                          userCurrent['first name'] + ' ' + userCurrent['last name'],
                                                                                                                                          style: TextStyle(
                                                                                                                                            fontSize: 18,
                                                                                                                                            fontWeight: FontWeight.w500,
                                                                                                                                          ),
                                                                                                                                        ),
                                                                                                                                        SizedBox(
                                                                                                                                          width: 10,
                                                                                                                                        ),
                                                                                                                                        Padding(
                                                                                                                                          padding: const EdgeInsets.only(top: 2.0),
                                                                                                                                          child: Text(
                                                                                                                                            timestampToString(commentData['timeComment']),
                                                                                                                                            style: TextStyle(
                                                                                                                                              fontSize: 15,
                                                                                                                                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                                                                                                                              fontWeight: FontWeight.w400,
                                                                                                                                            ),
                                                                                                                                          ),
                                                                                                                                        ),
                                                                                                                                      ],
                                                                                                                                    ),
                                                                                                                                    subtitle: Text(
                                                                                                                                      translatedComments[commentData['uidComment']] ?? commentData['comment'],
                                                                                                                                      style: TextStyle(
                                                                                                                                        fontSize: 18,
                                                                                                                                        fontWeight: FontWeight.w400,
                                                                                                                                      ),
                                                                                                                                    ),
                                                                                                                                  ),
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            Padding(
                                                                                                                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                                                                                              child: Row(
                                                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                                children: [
                                                                                                                                  Row(
                                                                                                                                    children: [
                                                                                                                                      SizedBox(
                                                                                                                                        width: 17,
                                                                                                                                      ),
                                                                                                                                      LikeAnimation(
                                                                                                                                        isAnimating: isLiked2,
                                                                                                                                        child: InkWell(
                                                                                                                                          onTap: () {
                                                                                                                                            StoreDataFavorite().likecomment(
                                                                                                                                              like: commentData['likeComment'],
                                                                                                                                              type: 'posts',
                                                                                                                                              uid: user!.uid,
                                                                                                                                              postId: postData['postId'],
                                                                                                                                              uidComment: commentData['uidComment'],
                                                                                                                                            );
                                                                                                                                          },
                                                                                                                                          child: Text(
                                                                                                                                            'Love',
                                                                                                                                            style: TextStyle(fontSize: 14, fontWeight: isLiked2 ? FontWeight.w500 : FontWeight.w400, color: isLiked2 ? Colors.red : Colors.grey),
                                                                                                                                          ),
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                      SizedBox(
                                                                                                                                        width: 20,
                                                                                                                                      ),
                                                                                                                                      Text(
                                                                                                                                        'Reply',
                                                                                                                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                                                                      ),
                                                                                                                                      SizedBox(
                                                                                                                                        width: 20,
                                                                                                                                      ),
                                                                                                                                      user!.uid == userCurrent['uid']
                                                                                                                                          ? GestureDetector(
                                                                                                                                              onTap: () async {
                                                                                                                                                String newValue = "";
                                                                                                                                                await showDialog(
                                                                                                                                                  context: context,
                                                                                                                                                  builder: (context) => AlertDialog(
                                                                                                                                                      title: Text(
                                                                                                                                                        "Edit comment",
                                                                                                                                                      ),
                                                                                                                                                      content: TextField(
                                                                                                                                                        autofocus: true,
                                                                                                                                                        decoration: InputDecoration(
                                                                                                                                                          hintText: "Enter new comment",
                                                                                                                                                        ),
                                                                                                                                                        onChanged: (value) {
                                                                                                                                                          newValue = value.trim();
                                                                                                                                                        },
                                                                                                                                                      ),
                                                                                                                                                      actions: [
                                                                                                                                                        //cancel button
                                                                                                                                                        TextButton(
                                                                                                                                                            child: Text(
                                                                                                                                                              "Cancel",
                                                                                                                                                              style: TextStyle(
                                                                                                                                                                color: isDarkMode ? Colors.white : Colors.black,
                                                                                                                                                              ),
                                                                                                                                                            ),
                                                                                                                                                            onPressed: () {
                                                                                                                                                              Navigator.pop(context);
                                                                                                                                                            }),
                                                                                                                                                        //save button
                                                                                                                                                        TextButton(
                                                                                                                                                          child: Text(
                                                                                                                                                            "Save",
                                                                                                                                                            style: TextStyle(
                                                                                                                                                              color: Colors.green,
                                                                                                                                                            ),
                                                                                                                                                          ),
                                                                                                                                                          onPressed: () => Navigator.of(context).pop(newValue),
                                                                                                                                                        ),
                                                                                                                                                      ]),
                                                                                                                                                );
                                                                                                                                                // update in firestore
                                                                                                                                                if (newValue != null) {
                                                                                                                                                  if (newValue.trim().length > 0) {
                                                                                                                                                    //only update if there is something in the textfield
                                                                                                                                                    await FirebaseFirestore.instance.collection('posts').doc(postData['postId']).collection('comments').doc(commentData['uidComment']).update({'comment': newValue});
                                                                                                                                                  }
                                                                                                                                                }
                                                                                                                                              },
                                                                                                                                              child: Text(
                                                                                                                                                'Edit',
                                                                                                                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                                                                              ))
                                                                                                                                          : SizedBox.shrink(),
                                                                                                                                      SizedBox(
                                                                                                                                        width: 20,
                                                                                                                                      ),
                                                                                                                                      user!.uid == userCurrent['uid']
                                                                                                                                          ? GestureDetector(
                                                                                                                                              onTap: () async {
                                                                                                                                                bool confirmDelete = await showDialog(
                                                                                                                                                  context: context,
                                                                                                                                                  builder: (context) => AlertDialog(
                                                                                                                                                    title: Text('Confirm delete'),
                                                                                                                                                    content: Text('Are you sure you want to delete your comment?'),
                                                                                                                                                    actions: [
                                                                                                                                                      TextButton(
                                                                                                                                                        onPressed: () => Navigator.of(context).pop(false),
                                                                                                                                                        child: Text(
                                                                                                                                                          'Cancel',
                                                                                                                                                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                                                                                                                                        ),
                                                                                                                                                      ),
                                                                                                                                                      TextButton(
                                                                                                                                                        onPressed: () => Navigator.of(context).pop(true),
                                                                                                                                                        child: Text(
                                                                                                                                                          'Delete',
                                                                                                                                                          style: TextStyle(color: Colors.red),
                                                                                                                                                        ),
                                                                                                                                                      )
                                                                                                                                                    ],
                                                                                                                                                  ),
                                                                                                                                                );
                                                                                                                                                if (confirmDelete == true) {
                                                                                                                                                  await FirebaseFirestore.instance.collection('posts').doc(postData['postId']).collection('comments').doc(commentData['uidComment']).delete();
                                                                                                                                                }
                                                                                                                                              },
                                                                                                                                              child: Text(
                                                                                                                                                'Delete',
                                                                                                                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                                                                              ))
                                                                                                                                          : SizedBox.shrink(),
                                                                                                                                    ],
                                                                                                                                  ),
                                                                                                                                  Row(
                                                                                                                                    children: [
                                                                                                                                      Text(
                                                                                                                                        commentData['likeComment'].length.toString(),
                                                                                                                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
                                                                                                                                      ),
                                                                                                                                      SizedBox(
                                                                                                                                        width: 2,
                                                                                                                                      ),
                                                                                                                                      Image.asset(
                                                                                                                                        'lib/images/heart.png',
                                                                                                                                        height: 20,
                                                                                                                                      ),
                                                                                                                                      SizedBox(
                                                                                                                                        width: 5,
                                                                                                                                      )
                                                                                                                                    ],
                                                                                                                                  ),
                                                                                                                                ],
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                );
                                                                                                              },
                                                                                                            );
                                                                                                          },
                                                                                                          itemCount: snapshot3.data == null ? 0 : snapshot3.data!.docs.length,
                                                                                                        ),
                                                                                                      );
                                                                                                    },
                                                                                                  ),
                                                                                                  Positioned(
                                                                                                    bottom: 0,
                                                                                                    left: 0,
                                                                                                    right: 0,
                                                                                                    child: Container(
                                                                                                      decoration: BoxDecoration(color: isDarkMode ? Theme.of(context).colorScheme.background : Colors.white, boxShadow: [
                                                                                                        BoxShadow(
                                                                                                          color: Colors.grey.withOpacity(0.2), // Màu của bóng đổ với độ mờ
                                                                                                          spreadRadius: 2, // Bán kính lan tỏa của bóng đổ
                                                                                                          blurRadius: 7, // Bán kính làm mờ của bóng đổ
                                                                                                          offset: Offset(0, 3), // Độ lệch của bóng đổ
                                                                                                        )
                                                                                                      ]),
                                                                                                      height: 60,
                                                                                                      width: double.infinity,
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                        children: [
                                                                                                          SizedBox(
                                                                                                            height: 50,
                                                                                                            width: 260,
                                                                                                            child: TextField(
                                                                                                              maxLines: null,
                                                                                                              controller: comment,
                                                                                                              decoration: InputDecoration(
                                                                                                                hintText: 'Add a comment',
                                                                                                                border: InputBorder.none,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          StreamBuilder<DocumentSnapshot>(
                                                                                                              stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
                                                                                                              builder: (context, snapshot) {
                                                                                                                if (!snapshot.hasData) {
                                                                                                                  return CircularProgressIndicator();
                                                                                                                }
                                                                                                                final userCurrent = snapshot.data!.data() as Map<String, dynamic>;
                                                                                                                late final List<dynamic> likeComment = [];
                                                                                                                return GestureDetector(
                                                                                                                    onTap: () {
                                                                                                                      if (comment.text.isNotEmpty) {
                                                                                                                        Comment().comments(
                                                                                                                          comment: comment.text.trim(),
                                                                                                                          type: 'posts',
                                                                                                                          postuid: postData['postId'],
                                                                                                                          uid: userCurrent['uid'],
                                                                                                                          likeComment: likeComment,
                                                                                                                        );
                                                                                                                      }
                                                                                                                      comment.clear();
                                                                                                                      // Navigator.pop(context);
                                                                                                                    },
                                                                                                                    child: Icon(Icons.send));
                                                                                                              }),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    );
                                                                                  });
                                                                                });
                                                                          },
                                                                          child:
                                                                              Transform(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            transform:
                                                                                Matrix4.rotationY(3.14),
                                                                            child:
                                                                                Image.asset(
                                                                              'lib/images/comment!.png',
                                                                              height: 30,
                                                                              color: isDarkMode ? Colors.white : Colors.black,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          postCommentCount
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  SizedBox(
                                                                    width: 40,
                                                                  ),
                                                                  Row(children: [
                                                                    Image.asset(
                                                                      'lib/images/share3.png',
                                                                      height:
                                                                          22,
                                                                      color: isDarkMode
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      '0',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ]),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          12.0,
                                                                      right:
                                                                          12.0,
                                                                      bottom:
                                                                          15.0),
                                                              child: Text(
                                                                '"' +
                                                                    postData[
                                                                        'caption'] +
                                                                    '"',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: isDarkMode
                                                                        ? Colors.grey[
                                                                            300]
                                                                        : Colors.grey[
                                                                            700],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ]),
                                        );
                                      },
                                    );
                                  } else if (usersnapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            "Error: ${usersnapshot.error}"));
                                  } else {
                                    return Container();
                                  }
                                });
                          },
                        ),
                      );
                    },
                  );
                },
                childCount: 1
                ),
              ),
            ],
          ),
        ),
//               // Padding(
        //               //   padding: const EdgeInsets.only(left: 8.0),
        //               //   child: Text(
        //               //     '0',
        //               //     style: TextStyle(
        //               //       fontSize: 13,
        //               //       fontWeight: FontWeight.w500,
        //               //     ),
        //               //   ),
        //               // ),
        //               // Padding(
        //               //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //               //   child: Row(
        //               //     children: [
        //               //       Text(
        //               //         'username ' + '',
        //               //         style: TextStyle(
        //               //           fontSize: 13,
        //               //           fontWeight: FontWeight.w500,
        //               //         ),
        //               //       ),
        //               //       Text(
        //               //         'caption',
        //               //         style: TextStyle(
        //               //           fontSize: 13,
        //               //         ),
        //               //       ),
        //               //     ],
        //               //   ),
        //               // ),
        //               // Padding(
        //               //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //               //   child: Text(
        //               //     'dateformat',
        //               //     style: TextStyle(
        //               //       fontSize: 13,
        //               //       color: Colors.grey,
        //               //     ),
        //               //   ),
        //               // ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   );
        // // } else if (usersnapshot.hasError) {
        //   return Center(
        //     child: Text("Error: ${usersnapshot.error}"),
        //   );
        // }
        // return Center(
        //   child: CircularProgressIndicator(),
        // );
        //               }
        //               return Container();
        //             },
        //           );
        //         },
        //       );
        //     } else if (snapshot.hasError) {
        //       return Center(
        //         child: Text("Error: ${snapshot.error}"),
        //       );
        //     }
        //     return Center(
        //       child: CircularProgressIndicator(),
        //     );
        //   },
        // ),
      );
    }
    return Container();
  }
}
