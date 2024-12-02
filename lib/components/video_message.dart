import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoMessage extends StatefulWidget {
  final String videoUrl;

  const VideoMessage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoPlayerController.initialize();
      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: false,
            looping: false,
          );
          _isInitialized = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // Đảm bảo giải phóng tài nguyên một cách an toàn
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    _chewieController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: Center(
          child: Icon(Icons.error, color: Colors.red),
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Chewie(
      controller: _chewieController!,
    );
  }
}
