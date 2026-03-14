// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../theme/appTheme.dart';

RichText getGreeting() {
  DateTime now = DateTime.now();
  int hour = now.hour;

  String greeting;
  if (hour >= 5 && hour < 12) {
    greeting = 'Good Morning';
  } else if (hour >= 12 && hour < 17) {
    greeting = 'Good Afternoon';
  } else {
    greeting = 'Good Evening';
  }

  // Create a TextSpan with different styles for the name and the greeting
  TextSpan textSpan = TextSpan(
    text: greeting, // Include only the greeting
    style:   TextStyle(
        fontSize: 14.sp,
        color: AppTheme.darkGreyGreet, ),
    children: const [],
  );

  // Wrap the TextSpan in a RichText widget
  return RichText(
    text: textSpan,
  );
}
