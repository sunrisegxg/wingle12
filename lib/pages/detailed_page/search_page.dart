import 'package:app/pages/detailed_page/chat_page.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/chat/chat_service.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _noResults = false;
  bool _noResults2 = false;
  final user = FirebaseAuth.instance.currentUser!;
  //chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  // update color
  late bool isDarkMode;
  List<Map<String, dynamic>> _foundUsers = [];
  List<Map<String, dynamic>> userDataList = [];
  @override
  void initState() {
    _foundUsers = userDataList;
    Future.delayed(Duration.zero, () => _searchFocusNode.requestFocus());
    super.initState();
  }
  @override
  void dispose() {
    // Hủy bỏ FocusNode khi Widget bị hủy
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterUsers(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty || enteredKeyword == '') {
      results = [];
      // results = List<Map<String, dynamic>>.from(userDataList);
    } else {
      results = userDataList
          .where((userData) => userData["first name"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()) || 
              userData["last name"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundUsers = results;
      _noResults = enteredKeyword.isEmpty && results.isEmpty;
      _noResults2 = enteredKeyword.isNotEmpty && results.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false, // mất nút quay về
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade300,
                width: 2.0, // Border width
              ),
              // color: Colors.blue,
            ),
            margin: EdgeInsets.only(left: 20.0,),
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Icon(Icons.arrow_back_ios, size: 14, color: isDarkMode ? Colors.grey[500] : Colors.grey[300],),
            )),
        ),
        iconTheme: IconThemeData(
          color: isDarkMode
              ? Colors.white
              : Colors.black, // Màu sắc của nút quay về
        ),
        toolbarHeight: 65,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Container(
            height: 60,
            child: TextField(
              focusNode: _searchFocusNode, // Gắn FocusNode vào TextField
              onChanged: (value) => _filterUsers(value),
              decoration: InputDecoration(
                // focusColor: Colors.blue,
                // suffixIconColor: Colors.black,
                labelText: 'Search',
                labelStyle: TextStyle(color: isDarkMode ?Colors.white : Colors.black),
                suffixIcon: Icon(
                  Icons.search,
                ),
                suffixIconConstraints: BoxConstraints(
                  maxHeight: 8,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ?Colors.white : Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  // Border mặc định
                  borderSide: BorderSide(color: isDarkMode ?Colors.white : Colors.black),
                ),
                // contentPadding: EdgeInsets.only(bottom: 0),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: (_noResults2)
        ? SingleChildScrollView(
            child: Container(
              // color: Colors.blue,
              // width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.8,
              child: Center(
                child: Text(
                  "No users found",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          )
        : 
        (_noResults) ? SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height*0.8,
              child: Center(
                child: Text(
                  "Please look for someone for chatting",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          )
        : Column(children: [
          _buildUserList(),
        ]),
      ),
    );
  }

  //build a list of users except for the current logged in user
  Widget _buildUserList() {
    return Expanded(
      child: StreamBuilder(
          stream: _chatService.getUserStream(),
          builder: (context, snapshot) {
            //error
            if (snapshot.hasError) {
              return const Text('Error');
            }

            //loading...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }

            userDataList = snapshot.data! as List<Map<String, dynamic>>;
            //return list view
            return _foundUsers.isEmpty 
              ? SingleChildScrollView(
                  child: Container(
                    // color: Colors.blue,
                    // width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height*0.8,
                    child: Center(
                      child: Text(
                        "Please look for someone for chatting",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ): ListView(
              children: _foundUsers.map<Widget>(
                      (userData) => _buildUserListItem(userData, context))
                  .toList(),
            );
          }),
    );
  }

  //build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    //display all users except current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              onTap: () {
                //tapped on a user -> go to chat page
                Navigator.push(
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 30.0, right: 20.0),
          //   child: Container(
          //     height: 0,
          //     child: Divider(
          //       thickness: 0.7,
          //       color: Colors.grey,
          //     ),
          //   ),
          // ),
        ],
      );
    } else {
      return Container();
    }
  }
}
