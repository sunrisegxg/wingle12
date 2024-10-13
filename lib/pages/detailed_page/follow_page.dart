import 'package:app/tabs/follower_view.dart';
import 'package:app/tabs/following_view.dart';
import 'package:app/tabs/proposed_view.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowPage extends StatefulWidget {
  final String uid;
  final String countFollowing;
  final String countFollower;
  final int initialTabIndex;
  const FollowPage({
    Key? key, // Fixed super.key issue
    required this.uid, required this.countFollowing, required this.countFollower, required this.initialTabIndex,
  }) : super(key: key);

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> with SingleTickerProviderStateMixin {
  late TabController _tabController; // Added TabController

  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex); // Initialized TabController
  }
  @override
  void dispose() {
    _tabController.dispose(); // Dispose of the TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    //tab bar views
    final List<Widget> tabBarViews = [
      // following view
      FollowingView(uid: widget.uid,),
      // follower view
      FollowerView(uid: widget.uid),
      // proposed view
      ProposedView(uid: widget.uid),
    ];
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 65,
        centerTitle: true,
        title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.data() == null) {
                return Center(child: Text('User data not found.'));
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  userData['first name'] + ' ' + userData['last name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }),
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
              child: Icon(Icons.arrow_back_ios, size: 14, color: isDarkMode ? Colors.grey[500] : Colors.black,),
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
        bottom: TabBar(
              controller: _tabController,
              automaticIndicatorColorAdjustment: true,
              indicatorColor: Colors.blue,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.blue,
              unselectedLabelColor: Color.fromARGB(255, 201, 209, 235),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Following', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                      Text(widget.countFollowing, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Follower', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                      Text(widget.countFollower, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                    ],
                  ),
                ),
                Tab(
                  child: Text('Proposed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                ),
              ],
            ),
      ),
      body: TabBarView(
        controller: _tabController, // Added TabController
        children: tabBarViews,
      ),
    );
  }
}
