// import 'dart:html';

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:app/components/chat_bubble.dart';
import 'package:app/components/textFielduser2.dart';
import 'package:app/components/video_message.dart';
import 'package:app/pages/detailed_page/other_accounts_page.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/chat/chat_service.dart';
import 'package:app/services/chat/socket_service.dart';
import 'package:app/services/user/user_data.dart';
import 'package:app/storage/add_data_file_chat.dart';
import 'package:app/storage/add_data_image_chat.dart';
import 'package:app/storage/add_data_video_chat.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

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
  // for emoji status
  bool isEmojiVisible = false;
  //for show more
  bool isShowed = false;

  @override
  void initState() {
    super.initState();
    // add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        setState(() {
          isEmojiVisible = false; // Ẩn bàn phím emoji khi TextField được focus
        });
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  void sendCallInvitationDirectly({
    required bool isVideoCall,
    required String targetUserId,
    required String targetUserName,
    required String chatRoomID,
  }) {
    // Tạo đối tượng người dùng mục tiêu
    ZegoUIKitUser targetUser = ZegoUIKitUser(
      id: targetUserId,
      name: targetUserName,
    );
    ZegoCallUser zegoInvitee = ZegoCallUser.fromUIKit(targetUser);
    // Gửi lời mời trực tiếp
    ZegoUIKitPrebuiltCallInvitationService().send(
      // notificationTitle: 'abc',
      callID: chatRoomID,
      isVideoCall: isVideoCall,
      invitees: [zegoInvitee],
      resourceID: isVideoCall ? "video_call" : "audio_call",
    );
  }
  // void sendCallInvite(bool isVideo) {

  //   List<String> ids = [widget.receiverID, _authService.getCurrentUser()!.uid];
  //   ids.sort();
  //   String chatRoomID = ids.join('_');
  //   // Tạo danh sách người dùng từ IDs
  //   List<ZegoCallUser> invitees = ids.map((id) {
  //     return ZegoCallUser.fromUIKit(
  //       ZegoUIKitUser(
  //         id: id,
  //         name: "User: $id",
  //       ),
  //     );
  //   }).toList();
  //   // Tạo đối tượng người nhận lời mời
  //   // ZegoUIKitUser invitee = ZegoUIKitUser(
  //   //   id: widget.receiverID,
  //   //   name: "User: ${widget.receiverID}",
  //   // );

  //   // Chuyển đổi ZegoUIKitUser thành ZegoCallUser
  //   // ZegoCallUser zegoInvitee = ZegoCallUser.fromUIKit(invitee);
  //   // ZegoCallUser.fromUIKit(
  //   //   ZegoUIKitUser(id: id, name: "User: $id");
  //   // );

  //   // Gửi lời mời cho tất cả người dùng trong danh sách
  //   ZegoUIKitPrebuiltCallInvitationService().send(
  //     invitees: invitees,
  //     callID: chatRoomID,
  //     isVideoCall: isVideo,
  //     resourceID: isVideo ? "video_call" : "audio_call",
  //   );
  // }
  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    // Ensure the scroll controller has clients and the scroll position is valid
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }


  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  //send message
  void sendMessage() async {
    //if there is a message inside the textfield
    if (_messageController.text.isNotEmpty) {
      //socket client message
      SocketService().sendMessage(_messageController.text.trim());
      //send message
      await _chatService.sendMessage(
        widget.receiverID,
        message: _messageController.text.trim(),
      );
      //clear the text control
      _messageController.clear();
    }

    scrollDown();
  }

  void toggleEmojiKeyboard() {
    if (isEmojiVisible) {
      setState(() {
        isEmojiVisible = false;
      });
      myFocusNode.requestFocus();
    } else {
      setState(() {
        isEmojiVisible = true;
      });
      FocusScope.of(context).unfocus();
    }
  }

  void onEmojiSelected(Emoji emoji) {
    _messageController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
  }

  // Send video message
  Future<void> sendVideoMessage(File videoFile) async {
    String videoUrl = await StoreVideoChat().uploadVideoToStorage(videoFile);
    await _chatService.sendMessage(
      widget.receiverID,
      videoUrl: videoUrl,
    );

    scrollDown();
  }

  // Send image message
  Future<void> sendImageMessage(File imageFile) async {
    String imageUrl = await StoreImageChat().uploadImageToStorage(imageFile);
    await _chatService.sendMessage(
      widget.receiverID,
      imageUrl: imageUrl,
    );

    scrollDown();
  }

  // Send image message
  Future<void> sendFileMessage(File file) async {
    String fileUrl = await StoreFileChat().uploadFileToStorage(file);
    String fileName = path.basename(file.path);
    int fileSize = await file.length();
    String fileExtension = path.extension(file.path).replaceFirst('.', '');
    await _chatService.sendMessage(
      widget.receiverID,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      fileExtension: fileExtension,
    );

    scrollDown();
  }

  //gallery image
  Future _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    await sendImageMessage(imageFile);

    Navigator.of(context).pop(); // Close the image picker
  }

  //file
  Future _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;
    print(result);
    PlatformFile pickedFile = result.files.first;

    File file = File(pickedFile.path!);

    await sendFileMessage(file);
  }

  //camera image
  Future _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    await sendImageMessage(imageFile);

    Navigator.of(context).pop(); // Close the image picker
  }

  //video
  Future _pickVideoFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File videoFile = File(pickedFile.path);
    await sendVideoMessage(videoFile);
  }

  //getColor
  Color getColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return Colors.pinkAccent.shade700; //Màu cho các file hình ảnh jpg,jpeg
      case 'mp3':
      case 'mp4':
        return Colors.amberAccent.shade700; //Màu cho các file âm nhạc
      case 'png':
        return Colors.orange; // Màu cho các file hình ảnh png
      case 'pdf':
        return Colors.red; // Màu cho file PDF
      case 'doc':
      case 'docx':
        return Colors.blue; // Màu cho file word
      case 'xls':
      case 'xlsx':
        return Colors.green; // Màu cho file Excel
      case 'txt':
        return Colors.grey; // Màu cho file văn bản
      default:
        return Colors.black; // Màu mặc định
    }
  }

  Future<void> downloadAndOpenFile(String fileUrl, String fileName) async {
    try {
      // Lấy đường dẫn thư mục lưu trữ tệp
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = path.join(appDocDir.path, fileName);

      File file = File(filePath);

      // Kiểm tra nếu tệp đã tồn tại
      if (await file.exists()) {
        // Mở tệp
        await OpenFile.open(filePath);
      } else {
        // Tải xuống tệp
        Dio dio = Dio();
        await dio.download(fileUrl, filePath,
            onReceiveProgress: (received, total) {
          if (total != -1) {
            // Bạn có thể cập nhật tiến trình tải xuống ở đây nếu muốn
            print((received / total * 100).toStringAsFixed(0) + "%");
          }
        });

        // Mở tệp sau khi tải xuống
        await OpenFile.open(filePath);
      }
    } catch (e) {
      print("Error downloading or opening file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải hoặc mở tệp.")),
      );
    }
  }

  Widget buildFile(
      String fileUrl, String fileName, int fileSize, String fileExtension) {
    final kb = fileSize / 1024;
    final mb = kb / 1024;
    final displaySize =
        mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
    final color = getColor(fileExtension);

    return InkWell(
      onTap: () async {
        // await downloadAndOpenFile(fileUrl, fileName);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            height: 120,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '.$fileExtension',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            fileName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 0.9,
            ),
          ),
          Text(
            displaySize,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // function upload image
  void showImagePickerOption(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    showModalBottomSheet(
        // backgroundColor: Colors.blue[100],
        context: context,
        builder: (builder) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 190,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: 100,
                    height: 3,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromGallery();
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
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors
                                      .grey.shade300, // Màu nền của hình tròn
                            ),
                            child: Center(
                              child: Icon(
                                Icons.image,
                                size: 17,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Choose image from gallery',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _pickImageFromCamera();
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
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors
                                      .grey.shade300, // Màu nền của hình tròn
                            ),
                            child: Center(
                              child: Icon(
                                Icons.camera,
                                size: 17,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Take a photo',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Divider(
                    thickness: 1.2,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: InkWell(
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
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors
                                      .grey.shade300, // Màu nền của hình tròn
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
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    String senderID = _authService.getCurrentUser()!.uid;
    List<String> ids = [widget.receiverID, senderID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        toolbarHeight: 60,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.receiverID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OtherAccountsPage(
                            uid: userData['uid'],
                            initialTabIndex: 0,
                          )));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 25.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0.0,
                    ),
                    leading: ClipOval(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.network(
                          userData['avatar'],
                          fit: BoxFit.cover,
                        ),
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
                color: isDarkMode
                    ? Colors.grey.shade500
                    : Colors.grey.shade300, // Border color
                width: 2.0, // Border width
              ),
            ),
            child: InkWell(
              onTap: () async {
                String username =
                    await UserData().getUserName(widget.receiverID);
                sendCallInvitationDirectly(
                    isVideoCall: true,
                    targetUserId: widget.receiverID,
                    targetUserName: username,
                    chatRoomID: chatRoomID);
              },
              child: Center(
                child: Icon(
                  Icons.call_outlined,
                  color: isDarkMode ? Colors.grey.shade500 : Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
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
              onTap: () async {
                String username =
                    await UserData().getUserName(widget.receiverID);
                sendCallInvitationDirectly(
                    isVideoCall: true,
                    targetUserId: widget.receiverID,
                    targetUserName: username,
                    chatRoomID: chatRoomID);
              },
              child: Center(
                child: Icon(
                  Icons.videocam_outlined,
                  color: isDarkMode ? Colors.grey.shade500 : Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
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
                    context: context,
                    builder: (builder) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                                onTap: () async {
                                  bool? confirmDelete = await showDialog<bool?>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm delete'),
                                      content: Text(
                                          'Are you sure about deleting your conversation?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
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
                                    await ChatService().deleteMessages(
                                        widget.receiverID, senderID);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDarkMode
                                              ? Colors.grey.shade700
                                              : Colors.grey
                                                  .shade300, // Màu nền của hình tròn
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.backspace_outlined,
                                            size: 17,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Delete conversation',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: Divider(
                                thickness: 1.2,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDarkMode
                                              ? Colors.grey.shade700
                                              : Colors.grey
                                                  .shade300, // Màu nền của hình tròn
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.close,
                                            size: 17,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        'Cancel',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
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
                child: Icon(
                  Icons.more_horiz,
                  color: isDarkMode ? Colors.grey.shade500 : Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
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
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            isShowed = false;
          });
        },
        child: Column(
          children: [
            //display all messages
            Expanded(
              child: _buildMessageList(),
            ),
            //user input
            _buildUserInput(),
          ],
        ),
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
          //no data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No messages yet.'));
          }

          //return list view
          return Container(
            color: isDarkMode ? Colors.black38 : Colors.grey.shade100,
            child: ListView(
              controller: _scrollController,
              children: snapshot.data!.docs
                  .map((doc) => _buildMessageItem(doc))
                  .toList(),
            ),
          );
        });
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    // Align message
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(data['senderID'])
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          Map<String, dynamic>? dataUser =
              snapshot.data!.data() as Map<String, dynamic>?;
          if (dataUser == null) {
            return Container();
          }

          // Determine the content to display
          Widget messageContent;
          if (data['message'] != null &&
              data['message'].toString().isNotEmpty) {
            // It's a text message
            messageContent = ChatBubble(
              message: data["message"],
              isCurrentUser: isCurrentUser,
            );
          } else if (data['imageUrl'] != null &&
              data['imageUrl'].toString().isNotEmpty) {
            // It's an image message
            messageContent = GestureDetector(
              onTap: () {
                // Optionally, implement full-screen image view
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data['imageUrl'],
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            );
          } else if (data['videoUrl'] != null &&
              data['videoUrl'].toString().isNotEmpty) {
            // It's an image message
            messageContent = GestureDetector(
              onTap: () {
                // Optionally, implement full-screen image view
              },
              child: Container(
                height: 225,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: VideoMessage(
                    videoUrl: data['videoUrl'],
                  ),
                ),
              ),
            );
          } else if (data['fileUrl'] != null &&
              data['fileUrl'].toString().isNotEmpty) {
            String fileUrl = data['fileUrl'];
            String fileName = data['fileName'] ?? 'Unknown';
            int fileSize = data['fileSize'] ?? 0;
            String fileExtension = data['fileExtension'] ?? 'file';
            // It's an image message
            messageContent = Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5,
              ),
              child: buildFile(fileUrl, fileName, fileSize, fileExtension),
            );
          } else {
            // Handle other cases if necessary
            messageContent = SizedBox.shrink();
          }

          return Container(
            alignment: alignment,
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                isCurrentUser
                    ? messageContent
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 2.0, left: 20.0, right: 5.0),
                            child: ClipOval(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: Image.network(
                                  dataUser['avatar'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: messageContent,
                          ),
                        ],
                      ),
              ],
            ),
          );
        });
  }

  //build message input
  Widget _buildUserInput() {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Theme.of(context).colorScheme.background
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: _buildInputRow(),
        ),
        Offstage(
          offstage: !isEmojiVisible,
          child: SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                onEmojiSelected(emoji);
              },
              onBackspacePressed: () => setState(() {
                isEmojiVisible = false;
              }),
              config: const Config(
                checkPlatformCompatibility: true,
                swapCategoryAndBottomBar: false,
                emojiViewConfig: EmojiViewConfig(
                  columns: 7,
                  backgroundColor: Color(0xFFF2F2F2),
                  emojiSizeMax: 28,
                ),
                categoryViewConfig: CategoryViewConfig(
                  showBackspaceButton: true,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  enabled: false,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow() {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
      child: Row(
        children: [
          PopupMenuButton(
            // offset: const Offset(0, 0),
            icon: Icon(
              Icons.add_circle,
              color: isDarkMode
                  ? Colors.grey.shade700
                  : Color.fromARGB(255, 67, 163, 241),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _pickFile(),
                value: 'file',
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Color.fromARGB(255, 67, 163, 241),
                    ),
                    SizedBox(width: 10),
                    Text('File'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => _pickVideoFromGallery(),
                value: 'video',
                child: Row(
                  children: [
                    Icon(
                      Icons.video_collection,
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Color.fromARGB(255, 67, 163, 241),
                    ),
                    SizedBox(width: 10),
                    Text('Video'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            color: isDarkMode
                ? Colors.grey.shade700
                : Color.fromARGB(255, 67, 163, 241),
            onPressed: () {
              showImagePickerOption(context);
            },
            icon: Icon(
              Icons.image,
              color: isDarkMode
                  ? Colors.grey.shade700
                  : Color.fromARGB(255, 67, 163, 241),
            ),
          ),
          IconButton(
            color: isDarkMode
                ? Colors.grey.shade700
                : Color.fromARGB(255, 67, 163, 241),
            onPressed: () {},
            icon: Icon(
              Icons.keyboard_voice,
              color: isDarkMode
                  ? Colors.grey.shade700
                  : Color.fromARGB(255, 67, 163, 241),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                MyTextField2(
                  controller: _messageController,
                  hintText: "Type message",
                  obscureText: false,
                  focusNode: myFocusNode,
                ),
                Positioned(
                  right: 20,
                  top: 13,
                  child: GestureDetector(
                    onTap: () {
                      toggleEmojiKeyboard();
                    },
                    child: Icon(
                      Icons.emoji_emotions_outlined,
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Color.fromARGB(255, 133, 196, 247),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
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
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
