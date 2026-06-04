import 'dart:async';
import 'package:flutter/material.dart';
import 'package:touristsaver/constants/global_colors.dart';

class OTPTimer extends StatefulWidget {
  const OTPTimer({super.key});

  @override
  State<OTPTimer> createState() => _OTPTimerState();
}

class _OTPTimerState extends State<OTPTimer> {
  Duration interval = const Duration(seconds: 1);
  late Timer _timer;
  final int timerMaxSeconds = 120;
  int currentSeconds = 0;
  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimer() {
    _timer = Timer.periodic(interval, (timer) {
      if (!mounted) return;
      setState(() {
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) timer.cancel();
      });
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.timer, color: GlobalColors.appColor),
        const SizedBox(width: 5),
        Text(timerText)
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class OTPTimer1 extends StatefulWidget {
  const OTPTimer1({super.key});

  @override
  State<OTPTimer1> createState() => _OTPTimer1State();
}

class _OTPTimer1State extends State<OTPTimer1> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.timer, color: GlobalColors.appColor),
        SizedBox(width: 5),
        Text('00:00')
      ],
    );
  }
}
