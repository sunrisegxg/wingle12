// import 'dart:html';

import 'package:app/components/chat_bubble.dart';
import 'package:app/components/textFielduser2.dart';
import 'package:app/pages/detailed_page/other_accounts_page.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/chat/chat_service.dart';
import 'package:app/services/zego_zim/zim_audiocall.dart';
import 'package:app/services/zego_zim/call_invite.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  ChatPage({super.key, required this.receiverEmail, required this.receiverID});
  // static const String routeName = '/chat';


  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  //chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  //for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override void initState() {
    super.initState();
    // add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // cause a delay so that the keyboard has time to show up
        //then the amount of remaining space will be calculated
        // then scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
        // WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());
      }
    });

    // wait a bit for listview to be built, then scroll to bottom
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
    // WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());
  }

  void sendCallInvite(bool isVideo) {
    List<String> ids = [widget.receiverID, _authService.getCurrentUser()!.uid];
    ids.sort();
    String chatRoomID = ids.join('_');
    // Tạo danh sách người dùng từ IDs
    List<ZegoCallUser> invitees = ids.map((id) {
      return ZegoCallUser.fromUIKit(
        ZegoUIKitUser(
          id: id,
          name: "User: $id",
        ),
      );
    }).toList();

    // Gửi lời mời cho tất cả người dùng trong danh sách
    ZegoUIKitPrebuiltCallInvitationService().send(
      invitees: invitees,
      callID: chatRoomID,
      isVideoCall: isVideo,
      resourceID: "zegouikit_call",
    );
  }
  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  //send message
  void sendMessage() async {
    //if there is a message inside the textfield
    if (_messageController.text.isNotEmpty) {
      //send message
      await _chatService.sendMessage(widget.receiverID, _messageController.text);
      //clear the text control
      _messageController.clear();
    }

    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    String senderID = _authService.getCurrentUser()!.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        toolbarHeight: 60,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(widget.receiverID).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => OtherAccountsPage(uid: userData['uid'], initialTabIndex: 0,)));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 25.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0,),
                    leading: ClipOval(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.network(userData['avatar'], fit: BoxFit.cover,),
                      ),
                    ),
                    title: Text(
                      userData['first name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
        actions: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
               border: Border.all(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade300, // Border color
                width: 2.0, // Border width
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CallInvite(userid: widget.receiverID, isVideo: false),));
              },
              child: Center(
                child: Icon(Icons.call_outlined, color: isDarkMode ? Colors.grey.shade500 : Colors.black,),
              ),
            ),
          ),
          SizedBox(width: 20,),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
               border: Border.all(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade300,
                width: 2.0, // Border width
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CallInvite(userid: widget.receiverID, isVideo: true),));
              },
              child: Center(
                child: Icon(Icons.videocam_outlined, color: isDarkMode ? Colors.grey.shade500 : Colors.black,),
              ),
            ),
          ),
          SizedBox(width: 20,),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade300,
                width: 2.0, // Border width
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () async {
                showModalBottomSheet(
                context:
                    context,
                builder:
                    (builder) {
                  return SizedBox(
                    width: MediaQuery.of(
                            context)
                        .size
                        .width,
                    height:
                        120,
                    child:
                        Column(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child:
                              InkWell(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                            onTap: () async {
                              bool? confirmDelete = await showDialog<bool?>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirm delete'),
                                  content: Text('Are you sure about deleting your conversation?'),
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
                                Navigator.pop(context);
                                Navigator.pop(context);
                                await ChatService().deleteMessages(widget.receiverID, senderID);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300, // Màu nền của hình tròn
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.backspace_outlined,
                                        size: 17,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Delete conversation',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 15.0,
                          ),
                          child:
                              Divider(
                            thickness: 1.2,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child:
                              InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300, // Màu nền của hình tròn
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.close,
                                        size: 17,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Cancel',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w500),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              },
              child: Center(
                child: Icon(Icons.more_horiz, color: isDarkMode ? Colors.grey.shade500 : Colors.black,),
              ),
            ),
          ),
          SizedBox(width: 20,),
        ],
        titleSpacing: 10.0,
        leadingWidth: 60,
        automaticallyImplyLeading: false,
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
      ),
      body: Column(
        children: [
          //display all messages
          Expanded(child: _buildMessageList(),),
          //user input
          _buildUserInput(),
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        //errors
        if (snapshot.hasError) {
          return const Text('Error');
        }
        //loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        //return list view
        return Container(
          color: isDarkMode ? Colors.black38: Colors.grey.shade100,
          child: ListView(
            controller: _scrollController,
            children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
          ),
        );
      }
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    // align message to the right if sender is the current user, otherwise left
    var alignment =
     isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(data['senderID']).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        Map<String, dynamic>? dataUser = snapshot.data!.data() as Map<String, dynamic>?;
        if (dataUser == null) {
          return Container();
        }
        return Container(
          alignment: alignment,
          child: Column(
            crossAxisAlignment: 
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              isCurrentUser ? ChatBubble(
                message: data["message"],
                isCurrentUser: isCurrentUser,
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0, left: 20.0, right: 5.0),
                    child: ClipOval(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.network(dataUser['avatar'], fit: BoxFit.cover,),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ChatBubble(
                      message: data["message"],
                      isCurrentUser: isCurrentUser,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  //build message input
  Widget _buildUserInput() {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).colorScheme.background : Colors.white,
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.2), // Màu của đổ bóng
            spreadRadius: 2, // Bán kính phân tán của đổ bóng
            blurRadius: 7, // Độ mờ của đổ bóng
            offset: Offset(0, 3), // Độ dịch chuyển của đổ bóng
          ),]
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            children: [
              //add file
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade300, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                child: Center(
                child: Icon(Icons.add, color: isDarkMode ? Colors.grey.shade500 : Colors.black,),
              ),
              ),
              //textfield should take up most of the space
              SizedBox(
                width: 272,
                child: MyTextField2(
                  controller: _messageController,
                  hintText: "Type a message",
                  obscureText: false,
                  focusNode: myFocusNode,
                ),
              ),
          
              //send button
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: sendMessage,
                  icon: Icon(
                    Icons.arrow_forward,
                    color: isDarkMode ? Colors.white : Colors.black ,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}