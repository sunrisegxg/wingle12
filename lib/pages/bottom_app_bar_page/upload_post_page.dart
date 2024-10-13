import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/components/button_upload.dart';
import 'package:app/components/textFieldlocation.dart';
import 'package:app/components/textarea.dart';
import 'package:app/storage/add_data_image_post.dart';
import 'package:app/storage/add_data_video.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class UploadPage extends StatefulWidget {
  const UploadPage({
    super.key,
  });

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _isLoading = false;
  var uuid = Uuid().v4();
  List<dynamic> listOfLocation = [];
  final _caption = TextEditingController();
  final _location = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  final String token = '1234567890';
  Uint8List? _image;
  File? selectedImage;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  File? _videoFile;
  bool _isButtonEnabled = false;
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _caption.addListener(_checkInput);
    _location.addListener(_onChange);
  }

  @override
  void dispose() {
    _caption.dispose();
    _location.dispose();
    if (_videoFile != null) {
      _videoPlayerController!.dispose();
      _chewieController!.dispose();
    }
    _caption
        .removeListener(_checkInput); // Loại bỏ lắng nghe khi widget bị dispose
    super.dispose();
  }

  void _checkInput() {
    setState(() {
      _isButtonEnabled =
          _caption.text.isNotEmpty; // Nếu TextArea có nội dung, kích hoạt nút
    });
  }

  _onChange() {
    placeSuggestion(_location.text);
  }

  void placeSuggestion(String input) async {
    try {
      String request = "https://countriesnow.space/api/v0.1/countries/capital";
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = data['data']
              .where((item) =>
                  item['capital']
                      .toString()
                      .toLowerCase()
                      .contains(input.toLowerCase()) ||
                  item['name']
                      .toString()
                      .toLowerCase()
                      .contains(input.toLowerCase()))
              .toList();
        });
      } else {
        throw Exception("Fail to load");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_videoPlayerController != null) {
      await _videoPlayerController!.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: true,
        );
      });
    }
  }

  Future addPhotowithDataUser() async {
    if (_image != null) {
      try {
        late final List<dynamic> like = [];
        var uid = Uuid().v4();
        Timestamp timepost = Timestamp.now();
        String imageUrl = await StoreDataImagePost()
            .uploadImagePostToStorage(user.uid, _image!);
        await FirebaseFirestore.instance.collection('posts').doc(uid).set({
          'uid': user.uid,
          'email': user.email,
          'imagePost': imageUrl,
          'caption': _caption.text.trim(),
          'timepost': timepost,
          'postId': uid,
          'like': like,
          'location': _location.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post uploaded successfully'),
          ),
        );
      } catch (e) {
        // Xử lý lỗi
        print('Failed to add post: $e');
      }
    }
  }

  Future addVideowithDataUser() async {
    if (_videoFile != null) {
      try {
        late final List<dynamic> like = [];
        var uid = Uuid().v4();
        Timestamp timepost = Timestamp.now();
        String videoUrl = await StoreDataVideoPost()
            .uploadVideoPostToStorage(user.uid, _videoFile!);
        await FirebaseFirestore.instance.collection('posts').doc(uid).set({
          'uid': user.uid,
          'email': user.email,
          'videoPost': videoUrl,
          'caption': _caption.text.trim(),
          'timepost': timepost,
          'postId': uid,
          'like': like,
          'location': _location.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post uploaded successfully'),
          ),
        );
      } catch (e) {
        // Xử lý lỗi
        print('Failed to add post: $e');
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (_image != null) {
        setState(() {
          _image = null;
          selectedImage = null;
        });
      }
      setState(() {
        _videoFile = File(pickedFile.path);
      });
      if (_videoPlayerController != null) {
        await _videoPlayerController!.dispose();
        setState(() {
          _videoPlayerController = null;
          _chewieController = null;
        });
      }
      setState(() {
        _videoPlayerController = VideoPlayerController.file(_videoFile!);
      });
      await _initializeVideoPlayer();
    }
  }

  Future<void> resetVideoSelection() async {
    setState(() {
      if (_videoPlayerController != null) {
        _videoPlayerController!.pause(); // Dừng video nếu đang chạy
        _videoPlayerController!.dispose(); // Giải phóng bộ nhớ
        _videoPlayerController = null; // Đặt _videoPlayerController về null
      }
      if (_chewieController != null) {
        _chewieController!.dispose(); // Giải phóng bộ nhớ
        _chewieController = null; // Đặt _chewieController về null
      }
      _videoFile = null; // Đặt _videoFile về null
    });
  }

  //gallery image
  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    if (_videoFile != null) {
      setState(() {
        if (_videoPlayerController != null) {
          _videoPlayerController!.pause(); // Dừng video nếu đang chạy
          _videoPlayerController!.dispose(); // Giải phóng bộ nhớ
          _videoPlayerController = null; // Đặt _videoPlayerController về null
        }
        if (_chewieController != null) {
          _chewieController!.dispose(); // Giải phóng bộ nhớ
          _chewieController = null; // Đặt _chewieController về null
        }
        _videoFile = null;
      });
    }
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }

  //camera image
  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    if (_videoFile != null) {
      setState(() {
        if (_videoPlayerController != null) {
          _videoPlayerController!.pause(); // Dừng video nếu đang chạy
          _videoPlayerController!.dispose(); // Giải phóng bộ nhớ
          _videoPlayerController = null; // Đặt _videoPlayerController về null
        }
        if (_chewieController != null) {
          _chewieController!.dispose(); // Giải phóng bộ nhớ
          _chewieController = null; // Đặt _chewieController về null
        }
        _videoFile = null;
      });
    }
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }

  Future<void> resetImageSelection() async {
    setState(() {
      _image = null;
      selectedImage = null;
    });
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
                              color:
                                isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300, // Màu nền của hình tròn
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
                              color:
                                isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300, // Màu nền của hình tròn
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
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            listOfLocation = [];
          });
        },
        child: Stack(children: [
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Create Post",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25),
                          ),
                          Icon(Icons.star)
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            '*Please select photo or video to upload',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // upload image or video
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //upload image
                          GestureDetector(
                            onTap: () {
                              showImagePickerOption(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 40),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: isDarkMode
                                          ? Colors.pink.shade400
                                          : Colors.pink,
                                      size: 25,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Photo",
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.pink.shade400
                                              : Colors.pink,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ]),
                            ),
                          ),
                          //upload video
                          GestureDetector(
                            onTap: () {
                              _pickVideoFromGallery();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 42),
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.videocam,
                                      color: Colors.blue,
                                      size: 25,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Video",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //upload and display
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          // height: 250,
                          color: isDarkMode
                              ? Theme.of(context).colorScheme.secondary
                              : Color.fromARGB(255, 188, 218, 243),
                          padding: const EdgeInsets.all(10.0),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            color: isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                            padding: EdgeInsets.zero,
                            strokeWidth: 2,
                            dashPattern: [8, 4],
                            radius: Radius.circular(10),
                            child: _image != null
                                ? Stack(
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width, // Chiều rộng của container
                                        height: 225, // Chiều cao của container
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.memory(
                                            _image!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: GestureDetector(
                                          onTap: () => resetImageSelection(),
                                          child: Container(
                                              width: 30.0,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 2.0),
                                                // color: Colors.blue,
                                              ),
                                              // margin: EdgeInsets.only(left: 0.0,),
                                              child: Center(
                                                  child: Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.grey.shade500,
                                              ))),
                                        ),
                                      ),
                                    ],
                                  )
                                : _videoFile != null
                                    ? Stack(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width, // Chiều rộng của container
                                            height:
                                                225, // Chiều cao của container
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: _chewieController !=
                                                          null &&
                                                      _chewieController!
                                                          .videoPlayerController
                                                          .value
                                                          .isInitialized
                                                  ? AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: Chewie(
                                                        controller:
                                                            _chewieController!,
                                                      ),
                                                    )
                                                  : Container(),
                                            ),
                                          ),
                                          Positioned(
                                            right: 10,
                                            top: 10,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  resetVideoSelection(),
                                              child: Container(
                                                  width: 30.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300,
                                                        width: 2.0),
                                                    // color: Colors.blue,
                                                  ),
                                                  // margin: EdgeInsets.only(left: 0.0,),
                                                  child: Center(
                                                      child: Icon(
                                                    Icons.close,
                                                    size: 14,
                                                    color: Colors.grey.shade500,
                                                  ))),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width, // Chiều rộng của container
                                        height: 225, // Chiều cao của container
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload,
                                                size: 30,
                                                color: isDarkMode
                                                    ? Colors.grey[700]
                                                    : Colors.grey[200],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Caption",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            '*Required field',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyTextArea(
                        controller: _caption,
                        hintText: "Type something here",
                      ),
                      const SizedBox(height: 20),
                      TextFieldLocation(
                        controller: _location,
                        hintText: 'Add a location',
                        // onChanged: ,
                      ),
                      const SizedBox(height: 20),
                      BtnUpload(
                          onTap: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            if (_caption.text.isNotEmpty &&
                                (_image != null || _videoFile != null)) {
                              // Kiểm tra nếu có cả caption và ảnh hoặc video được chọn
                              if (_image != null) {
                                await addPhotowithDataUser();
                                await resetImageSelection();
                                setState(() {
                                  _isLoading = false;
                                });
                              } else if (_videoFile != null) {
                                await addVideowithDataUser();
                                await resetVideoSelection();
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                              _caption.clear();
                              _location.clear();
                            } else if (_caption.text.isEmpty &&
                                (_image != null || _videoFile != null)) {
                              setState(() {
                                _isLoading = false;
                              });
                              // Hiển thị thông báo nếu chưa có caption
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Please fill in caption'),
                                ),
                              );
                            } else {
                              setState(() {
                                _isLoading = false;
                              });
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Please upload image or video'),
                                ),
                              );
                            }
                            FocusScope.of(context).unfocus();
                          },
                          isButtonEnabled: _isButtonEnabled),
                    ],
                  ),
                  Visibility(
                    visible: listOfLocation.isNotEmpty,
                    child: Positioned(
                      top: 410,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        height: 200,
                        width: 300,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: listOfLocation.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    setState(() {
                                      _location.text = listOfLocation[index]
                                              ['capital'] +
                                          ', ' +
                                          listOfLocation[index]['name'];
                                      listOfLocation = [];
                                    });
                                  },
                                  child: ListTile(
                                    title: Text(
                                      listOfLocation[index]['capital'] +
                                          ', ' +
                                          listOfLocation[index]['name'],
                                    ),
                                  ),
                                ),
                                if (index != listOfLocation.length - 1)
                                  Divider(color: Colors.grey, height: 1),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) 
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black87,
              child: Center(child: CircularProgressIndicator())
            ),
        ]),
      ),
    );
  }
}
