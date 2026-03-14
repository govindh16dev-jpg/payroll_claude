import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_route.dart';
import '../data/repository/login_provider.dart';
import '../../splash/controller/splash_page_controller.dart';
import 'login_page_controller.dart';

class SSOController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> handleSSOLogin(String ssoToken) async {
    try {
      isLoading.value = true;

      debugPrint('🔐 Processing SSO token...');

      final loginProvider = Get.find<LoginProvider>();
      final userData = await loginProvider.loginWithSSO(ssoToken);

      isLoading.value = false;

      debugPrint('✅ SSO Authentication successful for user: ${userData.user?.email}');

      // CRITICAL: Cancel splash navigation before navigating
      if (Get.isRegistered<SplashPageController>()) {
        Get.find<SplashPageController>().cancelNavigation();
        debugPrint('🛑 Cancelled splash navigation');
      }

      // Clean up any existing LoginPageController
      if (Get.isRegistered<LoginPageController>()) {
        Get.delete<LoginPageController>(force: true);
      }

      // Navigate to home page on SUCCESS
      await Get.offAllNamed(AppRoutes.homePage);
      debugPrint('✅ Navigated to home page');

      // Show snackbar AFTER navigation completes
      await Future.delayed(const Duration(milliseconds: 300));

      if (Get.context != null) {
        Get.snackbar(
          'Success',
          'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;

      debugPrint('❌ SSO Authentication failed: $e');

      // Cancel splash navigation even on error
      if (Get.isRegistered<SplashPageController>()) {
        Get.find<SplashPageController>().cancelNavigation();
      }

      // Clean up any existing LoginPageController before navigating to login
      if (Get.isRegistered<LoginPageController>()) {
        Get.delete<LoginPageController>(force: true);
      }

      // Navigate to login page on FAILURE
      await Get.offAllNamed(AppRoutes.loginPage);

      // Show snackbar AFTER navigation completes and widget tree is ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if we have a valid context before showing snackbar
      if (Get.context != null) {
        Get.snackbar(
          'Authentication Failed',
          _formatErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  String _formatErrorMessage(dynamic error) {
    String message = error.toString();

    // Clean up common error messages
    message = message.replaceAll('Exception: ', '');
    message = message.replaceAll('ClientException with SocketException: ', '');

    // Network errors
    if (message.contains('Failed host lookup') || message.contains('No address associated')) {
      return 'Network error. Please check your internet connection.';
    }

    if (message.contains('Connection refused')) {
      return 'Cannot connect to server. Please try again later.';
    }

    if (message.contains('Connection timeout') || message.contains('timed out')) {
      return 'Connection timeout. Please try again.';
    }

    // SSO specific errors
    if (message.contains('Invalid SSO token') || message.contains('token expired')) {
      return 'SSO session expired. Please login again.';
    }

    // Default message
    if (message.length > 100) {
      return 'Authentication failed. Please try again.';
    }

    return message;
  }
}
