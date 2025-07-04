import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class AdVideoPage extends StatefulWidget {
  final VoidCallback onAdCompleted;

  const AdVideoPage({super.key, required this.onAdCompleted});

  @override
  State<AdVideoPage> createState() => _AdVideoPageState();
}

class _AdVideoPageState extends State<AdVideoPage> {
  VideoPlayerController? _controller;
  bool _canClose = false;
  String videoPath = 'assets/videos/ads_video.MP4';

  @override
  void initState() {
    super.initState();
    _loadAdCounterAndSetVideo();
  }

  Future<void> _loadAdCounterAndSetVideo() async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('ad_counter') ?? 0;

    videoPath =
        (counter % 2 == 0)
            ? 'assets/videos/ads1.MP4'
            : 'assets/videos/ads_video.MP4';
    _controller = VideoPlayerController.asset(videoPath);

    try {
      await _controller!.initialize();
      setState(() {});
      _controller!.play();

      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) {
          setState(() {
            _canClose = true;
          });
        }
      });

      await prefs.setInt('ad_counter', counter + 1);
    } catch (e) {
      print("🔴 Error initializing video: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _closeAd() {
    if (_canClose) {
      widget.onAdCompleted();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child:
                _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                    : const CircularProgressIndicator(),
          ),
          if (_canClose)
            Positioned(
              top: 30,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: _closeAd,
              ),
            ),
        ],
      ),
    );
  }
}
