import 'dart:io';
import 'dart:typed_data';
import 'package:app/storage/add_data_image.dart';
import 'package:app/components/button_save_image.dart';
import 'package:app/components/text_box.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _isLoading = false;
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  //all users
  final usersCollection = FirebaseFirestore.instance.collection("users");
  //edit field
  Future<void> editField(String field) async {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(
            "Edit " + field,
          ),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter new $field",
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
        await usersCollection.doc(currentUser.uid).update({field: newValue});
      }
    }
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

  // save image profile
  void saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    if (_image != null) {
      try {
        // Lưu ảnh vào Firebase Storage và lấy URL ảnh
        String imageUrl = await StoreDataImage()
            .uploadImageToStorage(currentUser.uid, _image!);

        // Lưu thông tin người dùng vào bảng 'userProfile'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'avatar': imageUrl,
        });
        setState(() {
          _isLoading = false;
        });
        // Hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile image saved successfully'),
          ),
        );
        // setState(() {
        //   fetchImageURL()
        // });
      } catch (e) {
        // Xử lý lỗi
        print('Error: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchImageURL();
  }

  Future<Uint8List?> getImageDataFromUrl(String url) async {
    try {
      // Tải dữ liệu từ URL
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to load image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  Future<void> fetchImageURL() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();
      if (snapshot.exists) {
        dynamic data = snapshot['avatar'];
        if (data is String) {
          // Chuyển chuỗi thành Uint8List
          Uint8List? imageData = await getImageDataFromUrl(data);
          // Giờ bạn đã có imageData là Uint8List
          setState(() {
            _image = imageData;
          });
        } else if (data is Uint8List) {
          // Dữ liệu đã là Uint8List, sử dụng trực tiếp
          setState(() {
            _image = data;
          });
        }
      }
    } catch (e) {
      print('Error fetching image data: $e');
    }
  }

  //gallery
  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }

  //camera
  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }

  Uint8List? _image;
  File? selectedImage;
  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Edit my profile',
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
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return ListView(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //profile pic
                      Stack(
                        children: [
                          _image != null
                              ? Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(500),
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      // color: Colors.amber,
                                      child: Image.memory(_image!,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(500),
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      // color: Colors.amber,
                                      child: Image.network(
                                          'https://cdn-icons-png.flaticon.com/512/3177/3177440.png',
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: isDarkMode
                                      ? Colors.green[500]
                                      : Colors.green[300]),
                              child: IconButton(
                                  onPressed: () {
                                    showImagePickerOption(context);
                                  },
                                  icon: const Icon(Icons.add_a_photo)),
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(width: 10),
                      BtnSaveImage(onTap: saveProfile),
                    ],
                  ),
                  const SizedBox(height: 40),
                  //user details
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "My details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  //fullname
                  MyTextBox(
                    text: userData["first name"],
                    sectionName: 'First name',
                    onPressed: () => editField("first name"),
                  ),
                  SizedBox(height: 20),
                  MyTextBox(
                    text: userData["last name"],
                    sectionName: 'Last name',
                    onPressed: () => editField("last name"),
                  ),
                  //age
                  SizedBox(height: 20),
                  MyTextBox(
                    text: userData["age"],
                    sectionName: 'Age',
                    onPressed: () => editField("age"),
                  ),
                  //email address
                  SizedBox(height: 20),
                  MyTextBox(
                    text: userData["email"],
                    sectionName: 'Email address',
                    onPressed: () => editField("email"),
                  ),
                  // phone number
                  SizedBox(height: 20),
                  MyTextBox(
                    text: userData["phone number"],
                    sectionName: 'Phone number',
                    onPressed: () => editField("phone number"),
                  ),
                  const SizedBox(height: 20),
                  // job
                  MyTextBox(
                    text: userData["job"],
                    sectionName: 'Job',
                    onPressed: () => editField("job"),
                  ),
                  const SizedBox(height: 20),
                  MyTextBox(
                    text: userData["bio"],
                    sectionName: 'Bio',
                    onPressed: () => editField("bio"),
                  ),
                  const SizedBox(height: 20),
                ],
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
      if (_isLoading)
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black87,
            child: Center(child: CircularProgressIndicator())),
    ]);
  }
}
