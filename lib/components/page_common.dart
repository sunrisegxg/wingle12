import 'package:app/components/navigationprovider.dart';
import 'package:app/pages/bottom_app_bar_page/account_page.dart';
import 'package:app/pages/bottom_app_bar_page/home_page.dart';
import 'package:app/pages/bottom_app_bar_page/message_page.dart';
import 'package:app/pages/bottom_app_bar_page/settings_page.dart';
import 'package:app/pages/bottom_app_bar_page/upload_post_page.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/chat/socket_service.dart';
import 'package:app/services/user/user_data.dart';
import 'package:app/themes/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class CommonPage extends StatefulWidget {
  const CommonPage({super.key,});
  @override
  State<CommonPage> createState() => CommonPageState();
}

class CommonPageState extends State<CommonPage> {
  final user = FirebaseAuth.instance.currentUser;
  //socket client
  @override
  void initState() {
    SocketService().initialize("http://localhost:4000");
    initializeCallInvitationService();
    super.initState();
  }
  Widget _buildAvatarForOtherUser(BuildContext context, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage('https://i.pinimg.com/736x/c2/e9/02/c2e902e031e1d9d932411dd0b8ab5eef.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  Widget _buildAvatar(BuildContext context, Size size) {
    return FutureBuilder(
      future: UserData().getUserData(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('No user data found');
        }
        Map<String, dynamic> userData = snapshot.data!;
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(userData['avatar']),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    );
  }
  void initializeCallInvitationService() async {
    String username = await UserData().getUserName(user!.uid);
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 1007293522,
      appSign: '20962baf250e829a7e9b17ddc9a03f4d5345db7bd344079264bb0e80a47d7d55',
      userID: user!.uid,
      userName: username,
      plugins: [ZegoUIKitSignalingPlugin()],
      config: ZegoCallInvitationConfig(
        permissions: [
          ZegoCallInvitationPermission.microphone,
          ZegoCallInvitationPermission.camera,
        ],
      ),
      
      // uiConfig: ZegoCallInvitationUIConfig(
      //   callingBackgroundBuilder: (context, size, info) {
      //     return const SizedBox.shrink();
      //   },
      // ),
      // notificationConfig: ZegoCallInvitationNotificationConfig(
      //   androidNotificationConfig: ZegoCallAndroidNotificationConfig(
      //     showFullScreen: true,
      //   ),
      // ),
      requireConfig: (ZegoCallInvitationData data) {
        if (data.type == ZegoCallType.videoCall) {
          return ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..turnOnCameraWhenJoining = false
            ..turnOnMicrophoneWhenJoining = true
            ..useSpeakerWhenJoining = false
            ..avatarBuilder =(context, size, user, userInfo) {
              // Kiểm tra xem `userID` có phải là của người dùng hiện tại hay của người khác
              if (user!.id == FirebaseAuth.instance.currentUser?.uid) {
                // Avatar của người dùng hiện tại
                return _buildAvatar(context, size);
              } else {
                // Avatar của người được gọi đến hoặc người tham gia khác
                return _buildAvatarForOtherUser(context, size);
              }
            };
            // ..background = const SizedBox.shrink();
        } else if (data.type == ZegoCallType.voiceCall) {
          return ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
            ..turnOnMicrophoneWhenJoining = true
            ..useSpeakerWhenJoining = false;
        } else {
          // Trả về cấu hình mặc định hoặc null
          return ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
            ..turnOnMicrophoneWhenJoining = true
            ..useSpeakerWhenJoining = false;
        }
      },
    );
  }
  final List<Widget> _pages = [
    HomePage(),
    MyMessagePage(),
    UploadPage(),
    MyAccountPage(initialTabIndex: 0),
    MySettingsPage(),
  ];
  @override
  void dispose() {
    // Nếu cần thiết, hủy đăng ký dịch vụ khi widget bị hủy
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Consumer<NavigationProvider>(
      builder: (BuildContext context, navigationProvider, child) {
        return Scaffold(
          body: _pages[navigationProvider.selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                // color: isDarkMode
                //     ? Theme.of(context).colorScheme.background
                //     : Colors.white,
                color: Theme.of(context).colorScheme.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // Màu của đổ bóng
                    spreadRadius: 2, // Bán kính phân tán của đổ bóng
                    blurRadius: 7, // Độ mờ của đổ bóng
                    offset: Offset(0, 3), // Độ dịch chuyển của đổ bóng
                  ),
                ]),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: GNav(
                selectedIndex: navigationProvider.selectedIndex, // thì ra là ở đây chọn tab
                // backgroundColor: isDarkMode
                //     ? Theme.of(context).colorScheme.background
                //     : Colors.white,
                backgroundColor : Theme.of(context).colorScheme.background,
                color: isDarkMode ? Colors.white : Colors.black,
                tabBackgroundColor:
                    Theme.of(context).colorScheme.secondary,
                gap: 8,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
                 onTabChange: (index) {
                  navigationProvider.updateIndex(index);
                },
                activeColor: Colors.blueAccent,
                tabs: const [
                  GButton(
                      icon: Icons.home,
                      text: 'Home',
                      iconColor: Color(0xFFCED5EB)),
                  GButton(
                      icon: Icons.chat_bubble,
                      text: 'Message',
                      iconColor: Color(0xFFCED5EB)),
                  GButton(
                    icon: Icons.add_circle,
                    iconSize: 35,
                    iconColor: Colors.blueAccent,
                  ),
                  GButton(
                      icon: Icons.person,
                      text: 'Account',
                      iconColor: Color(0xFFCED5EB)),
                  GButton(
                      icon: Icons.settings,
                      text: 'Settings',
                      iconColor: Color(0xFFCED5EB)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
