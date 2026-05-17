import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class VideoIntroScreen extends StatefulWidget {
  const VideoIntroScreen({
    super.key,
    this.returnRouteName,
  });

  final String? returnRouteName;

  @override
  State<VideoIntroScreen> createState() => _VideoIntroScreenState();
}

class _VideoIntroScreenState extends State<VideoIntroScreen> {
  late VideoPlayerController _controller;
  bool _isVideoEnded = false;

  @override
  void initState() {
    super.initState();

    // 1. FIRST, assign the controller
    _controller = VideoPlayerController.asset(
      'assets/videos/welcome_intro_au.mp4',
    );

    // 2. THEN set the volume (this helps iOS recognize the audio session)
    _controller.setVolume(1.0);

    // 3. Initialize and play
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller.play();
      _controller.setLooping(false);
    });

    // 4. Attach your perfectly updated listener
    _controller.addListener(() {
      final value = _controller.value;

      if (value.isInitialized && value.duration > Duration.zero) {
        if (value.position >= value.duration) {
          if (!_isVideoEnded) {
            setState(() {
              _isVideoEnded = true;
            });
            _closeVideo();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeVideo() {
    final returnRouteName = widget.returnRouteName;

    if (returnRouteName != null && returnRouteName.isNotEmpty) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(returnRouteName);
      }
      return;
    }

    context.pushReplacementNamed('intro-screen');
  }

  @override
  Widget build(BuildContext context) {
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
                    child: SizedBox(
                      width: 28.w,
                      height: 28.w,
                      child: const CircularProgressIndicator(
                        color: Color(0xFF009FE3),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
          ),

          // Skip button
          if (!_isVideoEnded)
            Positioned(
              top: 40.h,
              right: 20.w,
              child: TextButton(
                onPressed: _closeVideo,
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
