import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:new_piiink/constants/global_colors.dart';

class VideoIntroScreen extends StatefulWidget {
  const VideoIntroScreen({super.key});

  @override
  State<VideoIntroScreen> createState() => _VideoIntroScreenState();
}

class _VideoIntroScreenState extends State<VideoIntroScreen> {
  late VideoPlayerController _controller;
  bool _isVideoEnded = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          "https://touristsaver.org/wp-content/uploads/2025/10/TouristSaver3.0.mp4"),
    );

    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
      _controller.setLooping(false);
    });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        // Video ended → navigate immediately
        context.goNamed("intro-screen");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void goNext() {
    context.pushReplacementNamed('intro-screen');
  }

  @override
  Widget build(BuildContext context) {
    void showIntro() {
      context.pushReplacementNamed(
        'intro-screen',
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: _controller.value.isInitialized
                ? SizedBox.expand(
                    // makes video fill the entire screen
                    child: FittedBox(
                      fit: BoxFit
                          .cover, // cover keeps aspect ratio but fills screen
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : Center(
                    child: Image.asset(
                      "assets/images/tourist.png", // placeholder thumbnail
                      width: 100,
                      height: 100,
                    ),
                  ),
          ),

          // Skip button
          if (!_isVideoEnded)
            Positioned(
              top: 40.h,
              right: 20.w,
              child: TextButton(
                onPressed: showIntro,
                child: AutoSizeText(
                  "Skip",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
