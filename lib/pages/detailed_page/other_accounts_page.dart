import 'package:app/storage/follow_like.dart';
import 'package:app/storage/like_animation.dart';
import 'package:app/pages/detailed_page/chat_page.dart';
import 'package:app/pages/detailed_page/follow_page.dart';
import 'package:app/tabs/image_view2.dart';
import 'package:app/tabs/loved_view2.dart';
import 'package:app/tabs/video_view2.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtherAccountsPage extends StatefulWidget {
  final String uid;
  final int initialTabIndex;
  const OtherAccountsPage({super.key, required this.uid, required this.initialTabIndex});
  @override
  State<OtherAccountsPage> createState() => _OtherAccountsPageState();
}

class _OtherAccountsPageState extends State<OtherAccountsPage> with SingleTickerProviderStateMixin {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    //tab bar views
    final List<Widget> tabBarViews = [
      // // image post view
      ImageView2(uid: widget.uid),
      // video post view
      VideoView2(uid: widget.uid),
      // loved post or video view
      LovedView2(uid: widget.uid),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            'Detailed profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
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
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade300,
                width: 2.0
              ),
              // color: Colors.blue,
            ),
            margin: EdgeInsets.only(left: 20.0,),
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Icon(Icons.arrow_back_ios, size: 14, color: isDarkMode ? Colors.grey.shade500 : Colors.black,),
            )),
        ),
        iconTheme: IconThemeData(
          color: isDarkMode
              ? Colors.white
              : Colors.black, // Màu sắc của nút quay về
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            bool isFollowed = userData['followers'] != null &&
                                userData['followers'].contains(currentUser.uid);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //following
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FollowPage(uid: userData['uid'], countFollower: userData['followers'].length.toString(), countFollowing: userData['following'].length.toString(), initialTabIndex: 0,),));
                        },
                        child: Column(
                          children: [
                            Text(
                              userData['following'].length.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              ),
                            ),
                            Text(
                              'Following',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      //profile details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ClipOval(
                          child: Container(
                            height: 100,
                            width: 100,
                            child: userData['avatar'] != null
                                ? Image.network(
                                    userData['avatar'],
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    'https://cdn-icons-png.flaticon.com/512/3177/3177440.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      //followers
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FollowPage(uid: userData['uid'], countFollower: userData['followers'].length.toString(), countFollowing: userData['following'].length.toString(), initialTabIndex: 1),));
                        },
                        child: Column(
                          children: [
                            Text(
                              userData['followers'].length.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              ),
                            ),
                            Text(
                              'Followers',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userData['first name'] + ' ' + userData['last name'],
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                      userData['job'] != '' ? Text(" | ", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),) : SizedBox.shrink(),
                      userData['job'] != '' ? Text(userData['job'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),) : SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  //bio ·
                  userData['bio'] != '' ? Text(userData['bio'].replaceAll(RegExp(r'[, ]+'), ' · '), style: const TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center, ) : SizedBox.shrink(),
                  const SizedBox(
                    height: 5,
                  ),
                  //email
                  Text(
                    userData['email'],
                    style: TextStyle(
                        color: Colors.blue[500],
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  //buttons
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        //follow
                        Expanded(
                          child: LikeAnimation(
                            isAnimating: isFollowed,
                            child: GestureDetector(
                              onTap: () {
                                StoreDataFavorite().follow(uid: widget.uid);
                                setState(() {
                                  isFollowed = isFollowed;
                                });
                              },
                              child: isFollowed ? Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                child: Center(
                                  child: Text(
                                    "Unfollow",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ) : Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isDarkMode ? Color.fromARGB(255, 116, 211, 119) : Colors.green[500],
                                ),
                                child: Center(
                                  child: Text(
                                    "Follow",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       StoreDataFavorite().follow(uid: widget.uid);
                        //       setState(() {
                        //         isFollow = true;
                        //       });
                        //     },
                        //     child: Container(
                        //       padding: const EdgeInsets.all(15),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(8),
                        //         color: Theme.of(context).colorScheme.secondary,
                        //       ),
                        //       child: Center(
                        //         child: Text(
                        //           "Follow",
                        //           style: TextStyle(
                        //               fontSize: 16,
                        //               fontWeight: FontWeight.bold,
                        //               color: isDarkMode
                        //                   ? Colors.green[300]
                        //                   : Colors.green[500]),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(
                          width: 20,
                        ),
                        // contact
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(receiverEmail: userData['email'], receiverID: userData['uid']),)),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              child: Center(
                                child: Text(
                                  "Message",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: isDarkMode ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //tab bar
                  Container(
                    height: MediaQuery.of(context).size.height - 105, // Adjust this value as needed
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.blue,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Color.fromARGB(255, 201, 209, 235),
                          tabs: const [
                            Tab(icon: Icon(Icons.collections)),
                            Tab(icon: Icon(Icons.video_collection)),
                            Tab(icon: Icon(Icons.favorite)),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: tabBarViews
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error${snapshot.error}"),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
