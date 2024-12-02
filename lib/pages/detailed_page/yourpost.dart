import 'package:app/components/comment.dart';
import 'package:app/components/other_image_post.dart';
import 'package:app/components/other_loved_post.dart';
import 'package:app/components/other_video_post.dart';
import 'package:app/storage/follow_like.dart';
import 'package:app/storage/like_animation.dart';
import 'package:app/pages/detailed_page/other_accounts_page.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class YourPost extends StatefulWidget {
  final String postId; // Biến để lưu trữ ID của bài viết
  final String uid;
  const YourPost({super.key, required this.postId, required this.uid});

  @override
  State<YourPost> createState() => _YourPostState();
}

class _YourPostState extends State<YourPost> {
  bool isLoading = true;
  bool _isDisposed = false;
  Map<String, dynamic>? userPost1;
  final comment = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  @override
  void initState() {
    super.initState();
    _fetchUserPostData();
    loadData();
  }

  loadData() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchUserPostData() async {
    // Fetch userPost data from Firestore or wherever you store it
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .get();

    if (snapshot.exists) {
      setState(() {
        userPost1 = snapshot.data() as Map<String, dynamic>;
      });
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (userPost1 != null && userPost1!['videoPost'] != null) {
      String videoUrl = userPost1!['videoPost'];
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController!.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: true,
        );
      });
    }
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
      _chewieController!.dispose();
    }
    _isDisposed = true;
    super.dispose();
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

  //edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Edit " + field,
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            maxLines: null,
            autofocus: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: TextStyle(color: Colors.grey),
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
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  // setState(() {
                  //   newValue = "";
                  // });
                  Navigator.pop(context);
                }),
            //save button
            TextButton(
              child: Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(newValue),
            ),
          ]),
    );
    // update in firestore
    if (newValue.trim().length > 0) {
      //only update if there is something in the textfield
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Detailed post',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        leadingWidth: 60,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
              // width: 40.0,
              // height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isDarkMode
                        ? Colors.grey.shade500
                        : Colors.grey.shade300,
                    width: 2.0),
                // color: Colors.blue,
              ),
              margin: EdgeInsets.only(
                left: 20.0,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 14,
                  color: isDarkMode ? Colors.grey.shade500 : Colors.black,
                ),
              )),
        ),
        iconTheme: IconThemeData(
          color: isDarkMode
              ? Colors.white
              : Colors.black, // Màu sắc của nút quay về
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .doc(widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final userPost =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.uid)
                        .get(),
                    builder: (context, usersnapshot) {
                      if (usersnapshot.hasData && usersnapshot.data!.exists) {
                        final userData =
                            usersnapshot.data!.data() as Map<String, dynamic>;
                        bool isLiked = userPost['like'] != null &&
                            userPost['like'].contains(currentUser.uid);
                        return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(userPost['postId'])
                                .collection('comments')
                                .snapshots(),
                            builder: (context, snapshot7) {
                              if (!snapshot7.hasData) {
                                return Container();
                              }
                              final int postCommentCount =
                                  snapshot7.data!.docs.length;
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    child: Column(children: [
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                // borderRadius: BorderRadius.circular(50),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            OtherAccountsPage(
                                                          uid: userData['uid'],
                                                          initialTabIndex: 0,
                                                        ),
                                                      ));
                                                },
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.all(0),
                                                  leading: ClipOval(
                                                    child: SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: Image.network(
                                                        userData['avatar'],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    userData['first name'] +
                                                        ' ' +
                                                        userData['last name'],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Row(
                                                    children: [
                                                      Text(
                                                        timestampToString(
                                                            userPost[
                                                                'timepost']),
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors
                                                                .grey[600],
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      userPost['location'] == ''
                                                          ? Container()
                                                          : Container(
                                                              width: 147,
                                                              child: Text(
                                                                ' · in ' +
                                                                    userPost[
                                                                        'location'],
                                                                maxLines:
                                                                    1, // Giới hạn số dòng
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis, // Hiển thị dấu ...
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                            .grey[
                                                                        600],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            )
                                                    ],
                                                  ),
                                                  // trailing:
                                                  //     Icon(Icons.more_horiz),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0),
                                              child: IconButton(
                                                icon: Icon(Icons.more_horiz),
                                                onPressed: () {},
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        // margin: EdgeInsets.symmetric(
                                        //     horizontal: 20.0),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 10.0,
                                                  right: 10.0,
                                                  top: 10.0),
                                              child: userPost['imagePost'] !=
                                                      null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: FadeInImage(
                                                        placeholder: AssetImage(
                                                            'assets/shimmer_placeholder.png'),
                                                        image: NetworkImage(
                                                            userPost[
                                                                'imagePost']),
                                                        fit: BoxFit.cover,
                                                        height: 250,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        fadeInDuration:
                                                            Duration(
                                                                milliseconds:
                                                                    500),
                                                        placeholderErrorBuilder:
                                                            (context, error,
                                                                stackTrace) {
                                                          return Shimmer
                                                              .fromColors(
                                                            baseColor: isDarkMode
                                                                ? Colors.black54
                                                                : Colors
                                                                    .black26,
                                                            highlightColor:
                                                                isDarkMode
                                                                    ? Colors
                                                                        .white30
                                                                    : Colors
                                                                        .white38,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              height: 250,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : userPost['videoPost'] !=
                                                          null
                                                      ? _chewieController !=
                                                                  null &&
                                                              _chewieController!
                                                                  .videoPlayerController
                                                                  .value
                                                                  .isInitialized
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        300,
                                                                child: Chewie(
                                                                  controller:
                                                                      _chewieController!,
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 300,
                                                              child: Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ))
                                                      : Container(),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 12.0),
                                              child: Row(
                                                // mainAxisAlignment:
                                                //     MainAxisAlignment
                                                //         .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      LikeAnimation(
                                                        isAnimating: isLiked,
                                                        child: InkWell(
                                                            onTap: () {
                                                              StoreDataFavorite().like(
                                                                  like: userPost[
                                                                      'like'],
                                                                  type: 'posts',
                                                                  uid:
                                                                      currentUser
                                                                          .uid,
                                                                  postId: userPost[
                                                                      'postId']);
                                                            },
                                                            child: isLiked
                                                                ? Image.asset(
                                                                    'lib/images/heart.png',
                                                                    height: 28,
                                                                  )
                                                                : Image.asset(
                                                                    'lib/images/hearted.png',
                                                                    height: 28,
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                  )),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        userPost['like']
                                                            .length
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 40,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Row(children: [
                                                        InkWell(
                                                          onTap: () {
                                                            showModalBottomSheet(
                                                                // backgroundColor: Colors.transparent,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      bottom: MediaQuery.of(
                                                                              context)
                                                                          .viewInsets
                                                                          .bottom,
                                                                    ),
                                                                    child:
                                                                        DraggableScrollableSheet(
                                                                      maxChildSize:
                                                                          1,
                                                                      initialChildSize:
                                                                          1,
                                                                      minChildSize:
                                                                          0.2,
                                                                      builder:
                                                                          (context,
                                                                              scrollController) {
                                                                        return ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(25),
                                                                            topRight:
                                                                                Radius.circular(25),
                                                                          ),
                                                                          child:
                                                                              Container(
                                                                            color: isDarkMode
                                                                                ? Theme.of(context).colorScheme.background
                                                                                : Colors.white,
                                                                            height:
                                                                                200,
                                                                            child:
                                                                                Stack(
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
                                                                                  stream: FirebaseFirestore.instance.collection('posts').doc(userPost['postId']).collection('comments').orderBy('timeComment', descending: true).snapshots(),
                                                                                  builder: (context, snapshot3) {
                                                                                    if (!snapshot3.hasData) {
                                                                                      return CircularProgressIndicator();
                                                                                    }
                                                                                    return Padding(
                                                                                      padding: const EdgeInsets.only(top: 20, bottom: 60),
                                                                                      child: ListView.builder(
                                                                                        itemBuilder: (context, index2) {
                                                                                          var commentData = snapshot3.data!.docs[index2].data() as Map<String, dynamic>;
                                                                                          bool isLiked2 = commentData['likeComment'] != null && commentData['likeComment'].contains(currentUser.uid);
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
                                                                                                                builder: (context) => OtherAccountsPage(
                                                                                                                  uid: userCurrent['uid'],
                                                                                                                  initialTabIndex: 0,
                                                                                                                ),
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
                                                                                                          Padding(
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
                                                                                                                  commentData['comment'],
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 18,
                                                                                                                    fontWeight: FontWeight.w400,
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
                                                                                                                            uid: currentUser.uid,
                                                                                                                            postId: userPost['postId'],
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
                                                                                                                    currentUser.uid == userCurrent['uid']
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
                                                                                                                                            setState(() {
                                                                                                                                              newValue = "";
                                                                                                                                            });
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
                                                                                                                                  await FirebaseFirestore.instance.collection('posts').doc(userPost['postId']).collection('comments').doc(commentData['uidComment']).update({'comment': newValue});
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
                                                                                                                    currentUser.uid == userCurrent['uid']
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
                                                                                                                                await FirebaseFirestore.instance.collection('posts').doc(userPost['postId']).collection('comments').doc(commentData['uidComment']).delete();
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
                                                                                            stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
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
                                                                                                        postuid: userPost['postId'],
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
                                                          },
                                                          child: Transform(
                                                            alignment: Alignment
                                                                .center,
                                                            transform: Matrix4
                                                                .rotationY(
                                                                    3.14),
                                                            child: Image.asset(
                                                              'lib/images/comment!.png',
                                                              height: 30,
                                                              color: isDarkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          postCommentCount
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 15,
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
                                                          height: 22,
                                                          color: isDarkMode
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          '0',
                                                          style: TextStyle(
                                                            fontSize: 15,
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
                                            Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 12.0,
                                                          right: 12.0,
                                                          bottom: 15.0),
                                                  child: RichText(
                                                    text : TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '"' +
                                                            userPost[
                                                                'caption'] +
                                                            '"',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: isDarkMode
                                                                ? Colors
                                                                    .grey[300]
                                                                : Colors
                                                                    .grey[700],
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      userPost['hashtag'] == ''
                                                          ? TextSpan()
                                                          : TextSpan(
                                                            text: '#' + userPost['hashtag'].replaceAll(RegExp(r'[, ]+'), ' #'),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    15,
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .grey
                                                                        .shade700
                                                                    : Color.fromARGB(
                                                                        255,
                                                                        162,
                                                                        211,
                                                                        248),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                    ],
                                                    ),
                                                  ),
                                                ),
                                          ],
                                        ),
                                      ),
                                      // OtherImageSection(postId: widget.postId, uid: widget.uid,),
                                      // OtherVideoSection(postId: widget.postId, uid: widget.uid,),
                                      // OtherLovedSection(postId: widget.postId, uid: widget.uid,),
                                    ]),
                                  ),
                                ],
                              );
                            });
                      } else if (usersnapshot.hasError) {
                        return Center(
                          child: Text("Error${usersnapshot.error}"),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error${snapshot.error}"),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
    );
  }
}
