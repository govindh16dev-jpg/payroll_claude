import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sizer/sizer.dart';

import '../theme/theme_controller.dart';

class NetworkService extends GetxController {
  late bool connectivityResult;

  @override
  void onInit() async {
    super.onInit();
    connectivityResult = true; // Optimistic default
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      connectivityResult = await InternetConnectionChecker.instance.hasConnection;
      if (kDebugMode) print("Network status: $connectivityResult");
      if (!connectivityResult) {
        _showNoInternetSnackbar();
      }
    } catch (e) {
      if (kDebugMode) print("Connectivity check error: $e");
      connectivityResult = true; // Assume connected on error
    }
  }

  /// Call this on-demand before critical operations if needed
  Future<bool> checkConnectivity() async {
    try {
      connectivityResult = await InternetConnectionChecker.instance.hasConnection;
      if (!connectivityResult) {
        _showNoInternetSnackbar();
      } else {
        _dismissNoInternetSnackbar();
      }
    } catch (e) {
      if (kDebugMode) print("Connectivity check error: $e");
    }
    return connectivityResult;
  }

  void _showNoInternetSnackbar() {
    var appTheme = Get.find<ThemeController>().currentTheme;
    Get.rawSnackbar(
        messageText: Text('PLEASE CONNECT TO THE INTERNET',
            style: TextStyle(color: appTheme.white, fontSize: 14.sp)),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: Colors.red[400]!,
        icon: Icon(
          Icons.wifi_off,
          color: appTheme.white,
          size: 35,
        ),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED);
  }

  void _dismissNoInternetSnackbar() {
    if (Get.isSnackbarOpen) {
      try {
        Get.closeCurrentSnackbar();
      } catch (e) {
        debugPrint("Error closing snackbar: $e");
      }
    }
  }
}
