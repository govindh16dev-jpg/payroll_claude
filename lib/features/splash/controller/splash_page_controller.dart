import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../config/constants.dart';
import '../../../routes/app_route.dart';
import '../../../service/api_service.dart';
import '../../../service/network_service.dart';
import '../../../theme/theme_controller.dart';
import '../../login/data/repository/login_provider.dart';

class SplashPageController extends GetxController {
  bool _hasNavigated = false; // Track if navigation already happened

  Future<bool> _initializeServices() async {
    bool isLoggedIn = false;

    // Initialize ONLY essential services here (if not already initialized)
    if (!Get.isRegistered<NetworkService>()) {
      Get.put(NetworkService(), permanent: true);
      print('✅ NetworkService initialized');
    }

    if (!Get.isRegistered<ProgressService>()) {
      Get.put(ProgressService());
      print('✅ ProgressService initialized');
    }

    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController());
      print('✅ ThemeController initialized');
    }

    // Initialize LoginProvider for SSO and regular login
    if (!Get.isRegistered<LoginProvider>()) {
      Get.put(LoginProvider(), permanent: true);
      print('✅ LoginProvider initialized');
    }

    const storage = FlutterSecureStorage();
    isLoggedIn = await storage.read(key: PrefStrings.accessToken) != null;

    return isLoggedIn;
  }

  /// Check if SSO token is still valid
  Future<bool> _isSSOTokenValid() async {
    try {
      const storage = FlutterSecureStorage();

      // Check if user logged in via SSO
      final isSSOLogin = await storage.read(key: PrefStrings.isSSOLogin);

      if (isSSOLogin != 'true') {
        print('❌ Not an SSO login');
        return false;
      }

      // Get token received time
      final tokenReceivedTimeStr = await storage.read(key: PrefStrings.ssoTokenReceivedTime);
      if (tokenReceivedTimeStr == null) {
        print('❌ No SSO token received time found');
        return false;
      }

      // Get token expiry duration (in seconds)
      final expiresInStr = await storage.read(key: PrefStrings.ssoTokenExpiresIn);
      if (expiresInStr == null) {
        print('❌ No SSO token expiry time found');
        return false;
      }

      // Parse values
      final tokenReceivedTime = DateTime.parse(tokenReceivedTimeStr);
      final expiresInSeconds = int.parse(expiresInStr);

      // Calculate expiry time
      final expiryTime = tokenReceivedTime.add(Duration(seconds: expiresInSeconds));
      final now = DateTime.now();

      // Check if token is still valid (with 5 minute buffer before actual expiry)
      final bufferTime = expiryTime.subtract(const Duration(minutes: 5));
      final isValid = now.isBefore(bufferTime);

      if (isValid) {
        final remainingTime = bufferTime.difference(now);
        print('✅ SSO token is valid. Expires in: ${remainingTime.inMinutes} minutes');
      } else {
        print('❌ SSO token expired or about to expire');
      }

      return isValid;

    } catch (e) {
      print('❌ Error checking SSO token validity: $e');
      return false;
    }
  }

  /// Clear SSO session data
  Future<void> _clearSSOSession() async {
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: PrefStrings.isSSOLogin);
      await storage.delete(key: PrefStrings.ssoTokenReceivedTime);
      await storage.delete(key: PrefStrings.ssoTokenExpiresIn);
      await storage.delete(key: PrefStrings.accessToken);
      await storage.delete(key: PrefStrings.refreshToken);
      await storage.delete(key: PrefStrings.userData);
      print('🧹 SSO session cleared');
    } catch (e) {
      print('❌ Error clearing SSO session: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();

    Future.delayed(const Duration(seconds: 1), () async {
      // Check if already navigated (e.g., by SSO deep link)
      if (_hasNavigated) {
        print('⏭️ Skipping splash navigation - already navigated');
        return;
      }

      // Initialize services
      await _initializeServices();

      // Double-check navigation hasn't happened
      if (_hasNavigated) {
        print('⏭️ Skipping splash navigation - navigated during init');
        return;
      }

      // Mark as navigated
      _hasNavigated = true;

      // Check SSO token validity
      final isSSOValid = await _isSSOTokenValid();

      if (isSSOValid) {
        // SSO token is valid, go directly to home page
        print('🚀 SSO token valid - Navigating to home page');
        Get.offAllNamed(AppRoutes.mainPage);
      } else {
        // Check if it was an SSO login that expired
        const storage = FlutterSecureStorage();
        final wasSSOLogin = await storage.read(key: PrefStrings.isSSOLogin);

        if (wasSSOLogin == 'true') {
          // Clear expired SSO session
          await _clearSSOSession();
          print('🧹 Expired SSO session cleared');
        }

        // Go to login page for normal login or expired SSO
        print('🚀 Navigating to login page');
        Get.offAllNamed(AppRoutes.loginPage);
      }
    });
  }

  // Method to cancel splash navigation (called by SSO or other flows)
  void cancelNavigation() {
    _hasNavigated = true;
    print('🛑 Splash navigation cancelled');
  }

  @override
  void onClose() {
    print('🗑️ SplashPageController onClose called');
    super.onClose();
  }
}