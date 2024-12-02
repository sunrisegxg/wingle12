import 'dart:typed_data';

import 'package:app/pages/detailed_page/other_accounts_page.dart';
import 'package:app/pages/detailed_page/yourpost.dart';
import 'package:app/pages/tabbarview/all_view.dart';
import 'package:app/pages/tabbarview/everyone_view.dart';
import 'package:app/pages/tabbarview/post_view.dart';
import 'package:app/provider/search_history_provider.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/chat/chat_service.dart';
import 'package:app/services/user/user_data.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SearchCommon extends StatefulWidget {
  const SearchCommon({super.key});

  @override
  State<SearchCommon> createState() => _SearchCommonState();
}

class _SearchCommonState extends State<SearchCommon>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchSubmit = false;
  final user = FirebaseAuth.instance.currentUser!;
  // Chat & Auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  // Update color
  late bool isDarkMode;
  List<Map<String, dynamic>> userDataList = [];
  List<Map<String, dynamic>> postDataList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.delayed(Duration.zero, () => _searchFocusNode.requestFocus());
    // L?ng nghe thay d?i c?a FocusNode
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _searchSubmit = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterUsers(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      return [];
    } else {
      return userDataList
          .where((userData) =>
              userData["first name"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              userData["last name"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
  }

  List<Map<String, dynamic>> _filterPosts(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      return [];
    } else {
      return postDataList
          .where((postData) =>
              postData["first name"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              postData["last name"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              postData["caption"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              postData["hashtag"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
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

  void _saveSearchTerm(String term) {
    if (term.trim().isNotEmpty) {
      Provider.of<SearchHistoryProvider>(context, listen: false)
          .addSearchTerm(term.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isDarkMode
                        ? Colors.grey.shade500
                        : Colors.grey.shade300,
                    width: 2.0),
              ),
              margin: const EdgeInsets.only(
                left: 20.0,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 14,
                  color: isDarkMode ? Colors.grey[500] : Colors.black,
                ),
              )),
        ),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        toolbarHeight: 65,
        title: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white
                : const Color.fromARGB(255, 218, 225, 249),
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) {
              setState(() {
                // C?p nh?t giao di?n khi n?i dung thay d?i
              });
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _saveSearchTerm(value.trim());
                setState(() {
                  _searchSubmit = true;
                });
              }
              _searchFocusNode.unfocus();
            },
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(bottom: 0, left: 10),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: _chatService.getUserStream(),
          builder: (context, snapshot) {
            // X? lý l?i
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching users'));
            }

            // Tr?ng thái dang t?i
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            userDataList = snapshot.data! as List<Map<String, dynamic>>;

            return FutureBuilder(
              future: UserData().getAllPosts(),
              builder: (context, snapshot1) {
                if (snapshot1.hasError) {
                  return const Center(child: Text('Error fetching posts'));
                }

                if (snapshot1.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                postDataList = snapshot1.data as List<Map<String, dynamic>>;

                return _searchSubmit
                    ? Column(
                        children: [
                          TabBar(
                            automaticIndicatorColorAdjustment: true,
                            indicatorColor: Colors.blue,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.blue,
                            unselectedLabelColor:
                                const Color.fromARGB(255, 201, 209, 235),
                            controller: _tabController,
                            tabs: const [
                              Tab(
                                child: Text(
                                  'All',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Posts',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Everyone',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                AllView(
                                  child: ListView(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0, left: 20.0, bottom: 5.0),
                                        child: Text(
                                          'Other users',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      ..._buildUserList(),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0, left: 20.0, bottom: 5.0),
                                        child: Text(
                                          'Other posts',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      ..._buildPostList(),
                                    ],
                                  ),
                                ),

                                PostView(
                                  child: ListView(
                                    children: [
                                      ..._buildPostList(),
                                    ],
                                  ),
                                ),
                                EveryoneView(
                                  child: ListView(
                                    children: [
                                      ..._buildUserList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _buildSearchSuggestions();
              },
            );
          },
        ),
      ),
    );
  }

  // Build search suggestions based on user input
  Widget _buildSearchSuggestions() {
    if (_searchController.text.trim().isEmpty) {
      // N?u không có t? khóa, hi?n th? l?ch s? tìm ki?m
      return _buildSearchHistory();
    } else {
      List<Map<String, dynamic>> filteredUsers =
          _filterUsers(_searchController.text.trim());
      if (filteredUsers.isEmpty) {
        // Không tìm th?y ngu?i dùng
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(_searchController.text.trim()),
          onTap: () {
            _saveSearchTerm(_searchController.text.trim());
            _searchFocusNode.unfocus();
            setState(() {
              _searchSubmit = true;
            });
          },
        );
      } else {
        // Hi?n th? danh sách ngu?i dùng tìm du?c
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(_searchController.text.trim()),
              onTap: () {
                _saveSearchTerm(_searchController.text.trim());
                _searchFocusNode.unfocus();
                setState(() {
                  _searchSubmit = true;
                });
              },
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: filteredUsers
                    .map<Widget>(
                        (userData) => _buildUserListItem(userData, context))
                    .toList(),
              ),
            ),
          ],
        );
      }
    }
  }

  // Build search history list
  Widget _buildSearchHistory() {
    return Consumer<SearchHistoryProvider>(
      builder: (context, searchHistoryProvider, child) {
        List<String> searchHistory = searchHistoryProvider.searchHistory;
        if (searchHistory.isEmpty) {
          return SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: const Center(
                child: Text(
                  "No recent searches",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              int reverseIndex = searchHistory.length - 1 - index;
              String searchTerm = searchHistory[reverseIndex];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(searchTerm),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Provider.of<SearchHistoryProvider>(context, listen: false)
                        .removeSearchTerm(searchTerm);
                  },
                ),
                onTap: () {
                  _searchController.text = searchTerm;
                  _searchFocusNode.unfocus();
                  setState(() {
                    _searchSubmit = true;
                  });
                },
              );
            },
          );
        }
      },
    );
  }

  // Build a list of users except for the current logged in user
  List<Widget> _buildUserList() {
    List<Map<String, dynamic>> filteredUsers = _filterUsers(_searchController.text.trim());

    if (filteredUsers.isEmpty) {
      return [Center(child: Text('No users found'))];
    } else {
      return filteredUsers.map<Widget>((userData) => _buildUserListItem(userData, context)).toList();
    }
  }

  // Build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Display all users except current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return Column(
        children: [
          ListTile(
            onTap: () {
              // Navigate to other user's account page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherAccountsPage(
                      uid: userData["uid"], initialTabIndex: 0),
                ),
              );
            },
            leading: Padding(
              padding: const EdgeInsets.only(
                left: 2.0,
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    userData['avatar'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                userData['first name'] + ' ' + userData['last name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // Build a list of posts except for the current logged in user
  List<Widget> _buildPostList() {
    List<Map<String, dynamic>> filteredPosts = _filterPosts(_searchController.text.trim());

    if (filteredPosts.isEmpty) {
      return [Center(child: Text('No posts found'))];
    } else {
      return filteredPosts.map<Widget>((postData) => _buildPostListItem(postData, context)).toList();
    }
  }

  // Build individual list tile for post
  Widget _buildPostListItem(
      Map<String, dynamic> postData, BuildContext context) {
    // Hi?n th? t?t c? ngu?i dùng ngo?i tr? ngu?i dùng hi?n t?i
    if (postData["uid"] != _authService.getCurrentUser()!.uid) {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => YourPost(postId: postData["postId"], uid: postData["uid"]),)),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 5),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: ClipOval(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.network(
                          postData['avatar'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    postData['first name'] + ' ' + postData['last name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        timestampToString(postData['timepost']),
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400),
                      ),
                      postData['location'] == ''
                          ? Container()
                          : Container(
                              width: 147,
                              child: Text(
                                ' · in ' + postData['location'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                    ],
                  ),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                        child: postData['imagePost'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  postData['imagePost'],
                                  height: 250,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : postData['videoPost'] != null
                                ? FutureBuilder<Uint8List?>(
                                    future: _getVideoThumbnail(postData['videoPost']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          height: 250,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      } else if (snapshot.hasError ||
                                          !snapshot.hasData ||
                                          snapshot.data == null) {
                                        return Container(
                                          height: 250,
                                          child: Center(
                                            child:
                                                Text('Cannot download thumbnail'),
                                          ),
                                        );
                                      } else {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.memory(
                                            snapshot.data!,
                                            height: 250,
                                            width: MediaQuery.of(context).size.width,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : Container(
                                    height: 250,
                                    child: Center(
                                        child: Text('Không có hình ?nh ho?c video')),
                                  ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, bottom: 15.0, top: 10.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '"' + postData['caption'] + '"',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.w400),
                              ),
                              postData['hashtag'] == ''
                                  ? TextSpan()
                                  : TextSpan(
                                      text: ' #' +
                                          postData['hashtag']
                                              .replaceAll(RegExp(r'[, ]+'), ' #'),
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: isDarkMode
                                              ? Colors.grey.shade700
                                              : Color.fromARGB(255, 162, 211, 248),
                                          fontWeight: FontWeight.w500),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

// Hàm d? l?y ?nh thumbnail c?a video
  Future<Uint8List?> _getVideoThumbnail(String videoUrl) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.PNG,
        maxHeight: 250,
        quality: 75,
      );
      return uint8list;
    } catch (e) {
      print('L?i khi t?o thumbnail: $e');
      return null;
    }
  }
}
