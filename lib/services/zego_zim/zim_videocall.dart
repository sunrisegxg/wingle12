import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZimVideoCall extends StatefulWidget {
  final String callid;
  final String userid;
  const ZimVideoCall({super.key, required this.callid, required this.userid});

  @override
  State<ZimVideoCall> createState() => _ZimVideoCallState();
}

class _ZimVideoCallState extends State<ZimVideoCall> {
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 1007293522,
      appSign: '20962baf250e829a7e9b17ddc9a03f4d5345db7bd344079264bb0e80a47d7d55',
      callID: widget.callid,
      userID: widget.userid,
      userName: "User : ${widget.userid}",
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
      ..turnOnCameraWhenJoining = false
      ..turnOnMicrophoneWhenJoining = false
      ..useSpeakerWhenJoining = true,
    );
  }
}
