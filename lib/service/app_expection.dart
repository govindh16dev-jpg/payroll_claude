import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

abstract class AppException implements Exception {
  void onException(
      {Function()? onButtonClick,
      String title,
      Function()? onDismissClick,
      String buttonText,
      String dismissButtonText});
}

class NoInternetException extends AppException {
  String message;

  NoInternetException(this.message);
  @override
  void onException(
      {Function()? onButtonClick,
      String title = "",
      Function()? onDismissClick,
      String buttonText = "",
      String dismissButtonText = ""}) {
    appSnackBar(data: message, color: Colors.red);
  }
}

class CustomException extends AppException {
  String message;

  CustomException(this.message);

  @override
  void onException(
      {Function()? onButtonClick,
      String title = "Sorry",
      Function()? onDismissClick,
      String buttonText = "Ok",
      String? dismissButtonText,
      shouldShowFlushBar = true}) {
    if (shouldShowFlushBar) {
      appSnackBar(data: message, color: Colors.red);
    } else {
      debugPrint(message);
    }
  }
}

void appSnackBar({required String data, Color? color, Duration? duration}) {
  BuildContext? context = navigator?.context;
  if (data[data.length - 1] != ".") {
    data = "$data.";
  }
  if (context != null) {
    final snackBar = SnackBar(
      duration: duration ?? const Duration(milliseconds: 4000),
      content: Text(
        data,
        style: TextStyle(color: color != null ? Colors.white : Colors.black),
      ),
      backgroundColor: color ?? Colors.greenAccent,
      showCloseIcon: true,
      closeIconColor: color != null ? Colors.white : Colors.black,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
