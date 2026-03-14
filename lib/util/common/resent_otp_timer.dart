import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  AnimationController? _controller;
  int otpTimer = 90;

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: otpTimer));

    _controller!.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Countdown(
          animation: StepTween(
            begin: otpTimer, // THIS IS A USER ENTERED NUMBER
            end: 0,
          ).animate(_controller!),
        ),
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  final Animation<int>? animation;

  Countdown({
    super.key,
    this.animation,
  }) : super(listenable: animation!);

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation!.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Resend OTP after ",
          style: TextStyle(fontSize: 30.sp, color: Colors.black),
        ),
        Text(
          timerText,
          style: TextStyle(fontSize: 30.sp, color: Colors.black),
        ),
        Text(
          "Minutes",
          style: TextStyle(fontSize: 30.sp, color: Colors.black),
        ),
      ],
    );
  }
}