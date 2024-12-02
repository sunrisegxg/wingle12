import 'dart:io';

import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:translator/translator.dart';
import 'package:voice_message_package/voice_message_package.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  String? recordingPath;
  bool isRecording = false, isPlaying = false;
  final translator = GoogleTranslator();
  var text = "Language";
  bool isPlayed = false;
  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Language and region',
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
      floatingActionButton: _recordingButton(),
      body: _buildUI(),
      // body: Center(
      //   child: Column(
      //     children: [
      //       Text(text),
      //       TextButton(
      //         onPressed: () async {
      //           await translator.translate(text, to: 'hi').then((output) {
      //             setState(() {
      //               text = output.text;
      //             });
      //           });
      //         },
      //         child: Text("Dịch"),
      //       )
      //     ],
      //   ),
      // ),
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (recordingPath != null)
            MaterialButton(
              onPressed: () async {
                if(audioPlayer.playing) {
                  audioPlayer.stop();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  await audioPlayer.setFilePath(recordingPath!);
                  audioPlayer.play();
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              color: Theme.of(context).colorScheme.primary,
              child: Text(isPlaying ? "Stop playing record" : "Start playing record", style: TextStyle(color: Colors.black),),
            ),
          if (recordingPath == null) const Text('No recording found'),
        ],
      ),
    );
  }

  Widget _recordingButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isRecording) {
          String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filePath;
            });
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocumentsDir =
                await getApplicationDocumentsDirectory();
            final String filePath =
                p.join(appDocumentsDir.path, 'recording.wav');
            await audioRecorder.start(
              const RecordConfig(),
              path: filePath,
            );
            setState(() {
              isRecording = true;
              recordingPath = null;
            });
          }
        }
      },
      child: isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
    );
  }
}
