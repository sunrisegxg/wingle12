import 'package:app/pages/detailed_page/other_accounts_page.dart';
import 'package:app/shimmer/shimmer_user.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowingView extends StatefulWidget {
  final String uid;
  const FollowingView({super.key, required this.uid});

  @override
  State<FollowingView> createState() => _FollowingViewState();
}

class _FollowingViewState extends State<FollowingView> {
  bool isLoading = true;
  bool _isDisposed = false;
  loadData() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('followers', arrayContains: widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          List<DocumentSnapshot> documents = snapshot.data!.docs;
          documents.shuffle();
          if (documents.isEmpty) {
            return Center(
                child: Text(
              "Haven't followed any users yet",
              style: TextStyle(
                fontSize: 16,
              ),
            ));
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final userData =
                    documents[index].data() as Map<String, dynamic>;
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OtherAccountsPage(
                              uid: userData['uid'], initialTabIndex: 0,
                            )));
                  },
                  child: isLoading
                      ? const ShimmerUser()
                      : ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 0.0),
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
