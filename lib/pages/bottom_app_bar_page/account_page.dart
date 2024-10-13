import 'package:app/pages/detailed_page/edit_profile_page.dart';
import 'package:app/pages/detailed_page/follow_page.dart';
import 'package:app/tabs/image_view.dart';
import 'package:app/tabs/loved_view.dart';
import 'package:app/tabs/video_view.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAccountPage extends StatefulWidget {
  final int initialTabIndex;
  const MyAccountPage({Key? key, required this.initialTabIndex})
      : super(key: key);

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.data() != null) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Following
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FollowPage(
                                                uid: userData['uid'],
                                                countFollower: userData['followers']
                                                    .length
                                                    .toString(),
                                                countFollowing: userData['following']
                                                    .length
                                                    .toString(),
                                                initialTabIndex: 0,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      userData['following'].length.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    const Text(
                                      'Following',
                                      style:
                                          TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              // Profile details
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: ClipOval(
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    child: userData['avatar'] != null
                                        ? Image.network(userData['avatar'],
                                            fit: BoxFit.cover)
                                        : Image.network(
                                            'https://cdn-icons-png.flaticon.com/512/3177/3177440.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                              // Followers
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FollowPage(
                                                uid: userData['uid'],
                                                countFollower: userData['followers']
                                                    .length
                                                    .toString(),
                                                countFollowing: userData['following']
                                                    .length
                                                    .toString(),
                                                initialTabIndex: 1,
                                              )));
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      userData['followers'].length.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    const Text(
                                      'Followers',
                                      style:
                                          TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userData['first name'] + ' ' + userData['last name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              ),
                              userData['job'] != ''
                                  ? Text(
                                      " | ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500, fontSize: 18),
                                    )
                                  : SizedBox.shrink(),
                              userData['job'] != ''
                                  ? Text(
                                      userData['job'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500, fontSize: 18),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          // Bio
                          userData['bio'] != ''
                              ? Text(
                                  userData['bio']
                                      .replaceAll(RegExp(r'[, ]+'), ' · '),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                  textAlign: TextAlign.center,
                                )
                              : SizedBox.shrink(),
                          const SizedBox(
                            height: 5,
                          ),
                          // Email
                          Text(
                            userData['email'],
                            style: TextStyle(
                                color: Colors.blue[500],
                                fontWeight: FontWeight.w500,
                                fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          // Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Row(
                              children: [
                                // Edit profile
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const EditProfile(),
                                          ));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Edit profile",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                // Share account
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Share account",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: isDarkMode
                                                ? Colors.black
                                                : Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                    // Tab bar
                    Container(
                      height: MediaQuery.of(context).size.height - 120, // Adjust this value as needed
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
                              children: const [
                                ImageView(),
                                VideoView(),
                                LovedView(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error${snapshot.error}"));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
