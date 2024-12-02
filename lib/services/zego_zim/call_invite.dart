import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallInvite extends StatefulWidget {
  // final String callid;
  final String userid;
  final bool isVideo;
  const CallInvite({super.key, required this.userid, required this.isVideo});

  @override
  State<CallInvite> createState() => _CallInviteState();
}

class _CallInviteState extends State<CallInvite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center (
        child: ZegoSendCallInvitationButton(
          invitees: [
            ZegoUIKitUser(
              id: widget.userid,
              name: "User: ${widget.userid}",
            ),
          ],
          isVideoCall: widget.isVideo,
          // callID: widget.callid,
          resourceID: widget.isVideo ? "video_call" : "audio_call",
        ),
      ),
    );
  }
}
