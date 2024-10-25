import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZimAudioCall extends StatefulWidget {
  final String callid;
  final String userid;
  const ZimAudioCall({super.key, required this.callid, required this.userid});

  @override
  State<ZimAudioCall> createState() => _ZimAudioCallState();
}

class _ZimAudioCallState extends State<ZimAudioCall> {
  @override
  Widget build(BuildContext context) {
    return Text('hi');
    // return ZegoUIKitPrebuiltCall(
    //   appID: 1007293522,
    //   appSign: '20962baf250e829a7e9b17ddc9a03f4d5345db7bd344079264bb0e80a47d7d55',
    //   callID: widget.callid,
    //   userID: widget.userid,
    //   userName: "User : ${widget.userid}",
    //   config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
    //   ..turnOnMicrophoneWhenJoining = false
    //   ..useSpeakerWhenJoining = true,
    // );
  }
}
