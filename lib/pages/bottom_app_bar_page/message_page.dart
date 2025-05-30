import 'dart:math';

import 'package:app/components/navigationprovider.dart';
import 'package:app/components/page_common.dart';
import 'package:app/components/search.dart';
import 'package:app/pages/bottom_app_bar_page/account_page.dart';
import 'package:app/pages/bottom_app_bar_page/home_page.dart';
import 'package:app/pages/detailed_page/chat_page.dart';
import 'package:app/pages/detailed_page/search_page.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/auth/main_page.dart';
import 'package:app/services/chat/chat_service.dart';
import 'package:app/shimmer/shimmer_user.dart';
import 'package:app/shimmer/shimmer_user_column.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ChatPageActiveProvider with ChangeNotifier {
  Map<String, bool> _userChatPageActiveMap = {};

  bool isChatPageActive(String userId) {
    return _userChatPageActiveMap[userId] ?? false;
  }

  void updateUserChatPageActive(String userId, bool value) {
    _userChatPageActiveMap[userId] = value;
    notifyListeners();
  }
}

class MyMessagePage extends StatefulWidget {
  const MyMessagePage({super.key});

  @override
  State<MyMessagePage> createState() => _MyMessagePageState();
}

class _MyMessagePageState extends State<MyMessagePage> {
  bool isLoading = true;
  bool _isDisposed = false;
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
    loadData();

    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  final user = FirebaseAuth.instance.currentUser!;
  //chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  // update color
  late bool isDarkMode;
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

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return FirebaseFirestore.instance
        .collection("users")
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) => doc.data()).toList();
      users.shuffle(); // Shuffle the list
      return users;
    });
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    // String senderID = _authService.getCurrentUser()!.uid;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Thông tin người dùng
          SliverAppBar(
            floating: true, // AppBar sẽ hiện ra ngay khi cuộn xuống
            snap:
                true, // AppBar xuất hiện ngay lập tức mà không cần cuộn đến hết chiều dài
            pinned: true, // AppBar sẽ được cố định trên cùng
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent, // màu header ban đầu
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context)
                    .colorScheme
                    .background, // Giữ cùng màu với body
              ),
            ),
            toolbarHeight: 65,
            title: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  return InkWell(
                    onTap: () {
                      Provider.of<NavigationProvider>(context, listen: false)
                          .updateIndex(3);
                    },
                    child: isLoading
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, top: 15.0),
                            child: ShimmerUser(),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(0),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    userData['email'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDarkMode
                                          ? Colors.grey[500]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
          ),
          // Thanh tìm kiếm
          SliverToBoxAdapter(
            child: isLoading
                ? Shimmer.fromColors(
                    baseColor: isDarkMode ? Colors.black54 : Colors.black26,
                    highlightColor:
                        isDarkMode ? Colors.white30 : Colors.white38,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 15.0, top: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        height: 45,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 20.0, right: 20.0, bottom: 15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SearchPage(),
                        ));
                      },
                      child: Search(
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
          ),
          // Danh sách người dùng ngang
          SliverToBoxAdapter(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getUserStream(),
              builder: (context, snapshot2) {
                if (snapshot2.hasError) {
                  return const Text('Error');
                }
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                final users = snapshot2.data!;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Row(
                      children: users.map((userData) {
                        if (userData["email"] ==
                            _authService.getCurrentUser()!.email) {
                          return SizedBox(); // Bỏ qua người dùng hiện tại
                        }
                        return _buildUserItem(userData, context);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          // Danh sách tin nhắn
          StreamBuilder(
            stream: _chatService.getUserStreamSorted(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Text('Error'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: Text('Loading...'));
              }
              final users = snapshot.data!;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildUserListItem(users[index], context);
                  },
                  childCount: users.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      String senderID = _authService.getCurrentUser()!.uid;
      return StreamBuilder(
          stream: _chatService.getMessages3(userData["uid"], senderID),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                          receiverEmail: userData['email'],
                          receiverID: userData['uid']),
                    ));
              },
              child: isLoading
                  ? const ShimmerColumn()
                  : Padding(
                      padding:
                          const EdgeInsets.only(right: 20.0, top: 0, bottom: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.network(
                                userData['avatar'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            child: Center(
                                child: Text(
                              userData['first name'],
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            )),
                          ),
                        ],
                      ),
                    ),
            );
          });
    } else {
      return Container();
    }
  }

  //build a list of users except for the current logged in user
  Widget _buildUserList() {
    return Expanded(
      flex: 5,
      child: StreamBuilder(
          stream: _chatService.getUserStreamSorted(),
          builder: (context, snapshot) {
            //error
            if (snapshot.hasError) {
              return const Text('Error');
            }

            //loading...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }

            //return list view //thêm expanded hay không thì tùy
            return ListView(
              physics: BouncingScrollPhysics(),
              // shrinkWrap: true,
              children: [
                Column(
                  children: snapshot.data!
                      .map<Widget>(
                          (userData) => _buildUserListItem(userData, context))
                      .toList(),
                ),
              ],
            );
          }),
    );
  }

  //build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    final userId = userData["uid"];
    final isChatPageActive2 =
        Provider.of<ChatPageActiveProvider>(context).isChatPageActive(userId);
    final senderID = _authService.getCurrentUser()!.uid;
    final senderName = userData['first name'] + ' ' + userData['last name'];
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    // Display all users except current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return StreamBuilder(
        stream: _chatService.getMessages3(userData["uid"], senderID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          // Store messages in a list
          List<Map<String, dynamic>> messages = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          // Get the latest message
          final latestMessage = messages.isNotEmpty ? messages.first : null;
          final lastTime =
              latestMessage != null && latestMessage['timestamp'] != null
                  ? timestampToString(latestMessage['timestamp'])
                  : '';

          // Determine the last message text
          String lastMessageText;
          if (latestMessage != null) {
            if (latestMessage['imageUrl'] != null &&
                latestMessage['imageUrl'].toString().isNotEmpty) {
              // The last message is an image
              if (latestMessage['senderID'] == senderID) {
                // Current user sent the image
                lastMessageText = 'You have sent a photo';
              } else {
                // Other user sent the image
                lastMessageText = '$senderName has sent a photo';
              }
            } else if (latestMessage['videoUrl'] != null &&
                latestMessage['videoUrl'].toString().isNotEmpty) {
              // The last message is an video
              if (latestMessage['senderID'] == senderID) {
                // Current user sent the video
                lastMessageText = 'You have sent a video';
              } else {
                // Other user sent the video
                lastMessageText = '$senderName has sent a video';
              }
            } else if (latestMessage['fileUrl'] != null &&
                latestMessage['fileUrl'].toString().isNotEmpty) {
              // The last message is an file
              if (latestMessage['senderID'] == senderID) {
                // Current user sent the file
                lastMessageText = 'You have sent a file';
              } else {
                // Other user sent the file
                lastMessageText = '$senderName has sent a file';
              }
            } else if (latestMessage['message'] != null &&
                latestMessage['message'].toString().isNotEmpty) {
              // The last message is a text message
              lastMessageText = latestMessage['message'];
            } else {
              lastMessageText = '';
            }
          } else {
            lastMessageText = '';
          }

          // Get the sender of the last message
          final lastMessageSender =
              latestMessage != null ? latestMessage['senderID'] : '';

          // Calculate unread message count
          int messageCount =
              0; // Number of unread messages from userData['uid']
          DateTime? lastMessageTime;

          // Iterate through the list of messages
          for (var message in messages) {
            DateTime messageTime = (message['timestamp'] as Timestamp).toDate();
            if (message['senderID'] == userData['uid']) {
              if (lastMessageTime == null ||
                  messageTime.isAfter(lastMessageTime)) {
                messageCount++;
              }
            } else if (message['senderID'] == senderID) {
              lastMessageTime = messageTime;
            }
          }

          return isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ShimmerUser(),
                )
              : Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: ListTile(
                          onTap: () async {
                            Provider.of<ChatPageActiveProvider>(context,
                                    listen: false)
                                .updateUserChatPageActive(userId, true);
                            // Tapped on a user -> go to chat page
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  receiverEmail: userData["email"],
                                  receiverID: userData["uid"],
                                ),
                              ),
                            );
                          },
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
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
                          title: Text(
                            userData['first name'] +
                                ' ' +
                                userData['last name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            lastMessageText,
                            maxLines: 1, // Limit to one line
                            overflow: TextOverflow.ellipsis, // Show ellipsis
                            style: lastMessageSender == senderID
                                ? TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  )
                                : isChatPageActive2
                                    ? TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      )
                                    : TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  lastTime,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                messageCount == 0
                                    ? Icon(Icons.done_all,
                                        size: 14,
                                        color: lastMessageSender == senderID
                                            ? Colors.grey
                                            : isChatPageActive2
                                                ? Colors.blue
                                                : isDarkMode
                                                    ? Colors.white
                                                    : Colors.black)
                                    : isChatPageActive2
                                        ? Icon(Icons.done_all,
                                            size: 14,
                                            color: lastMessageSender == senderID
                                                ? Colors.grey
                                                : isChatPageActive2
                                                    ? Colors.blue
                                                    : isDarkMode
                                                        ? Colors.white
                                                        : Colors.black)
                                        : Container(
                                            width: 15,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors
                                                  .blue, // Background color
                                            ),
                                            child: Center(
                                              child: Text(
                                                '$messageCount',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors
                                                      .white, // Text color
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
      );
    } else {
      return Container();
    }
  }
}
