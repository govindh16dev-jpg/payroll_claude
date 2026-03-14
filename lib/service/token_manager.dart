import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../config/constants.dart';
import '../features/login/data/repository/login_provider.dart';
import '../features/login/domain/model/login_model.dart';
import '../routes/app_route.dart';

class TokenManager extends GetxController {
  static TokenManager get instance => Get.find<TokenManager>();

  Timer? _tokenCheckTimer;
  DateTime? _tokenReceivedTime;
  int? _expiresIn;
  bool _isRefreshing = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Constants
  static const int REFRESH_BEFORE_EXPIRY_SECONDS = 60; // 1 minute before expiry
  static const int CHECK_INTERVAL_SECONDS = 30; // Check every 30 seconds

  // Storage keys
  static const String KEY_TOKEN_RECEIVED_TIME = 'token_received_time';
  static const String KEY_EXPIRES_IN = 'expires_in';

  /// Initialize token manager with login response
  Future<void> initializeToken(UserData userData) async {
    _tokenReceivedTime = DateTime.now();
    _expiresIn = userData.expiresIn ?? 480; // Default 8 minutes

    // Store token timing data
    await _storage.write(
        key: KEY_TOKEN_RECEIVED_TIME,
        value: _tokenReceivedTime!.toIso8601String()
    );
    await _storage.write(
        key: KEY_EXPIRES_IN,
        value: _expiresIn.toString()
    );

    // Start monitoring
    startTokenMonitoring();

    debugPrint('✅ Token initialized. Expires in: $_expiresIn seconds (${_expiresIn! / 60} minutes)');
  }

  /// Load existing token data from storage
  Future<void> loadTokenData() async {
    final tokenTimeStr = await _storage.read(key: KEY_TOKEN_RECEIVED_TIME);
    final expiresInStr = await _storage.read(key: KEY_EXPIRES_IN);

    if (tokenTimeStr != null && expiresInStr != null) {
      _tokenReceivedTime = DateTime.parse(tokenTimeStr);
      _expiresIn = int.parse(expiresInStr);

      // Check if token is still valid
      final isValid = await isTokenValid();
      if (isValid) {
        startTokenMonitoring();
        debugPrint('📂 Token data loaded. Still valid.');
      } else {
        debugPrint('⚠️ Token expired. User needs to login again.');
        await clearTokenData();
      }
    }
  }

  /// Start background monitoring (only when app is in foreground)
  void startTokenMonitoring() {
    // Cancel existing timer if any
    _tokenCheckTimer?.cancel();

    _tokenCheckTimer = Timer.periodic(
      const Duration(seconds: CHECK_INTERVAL_SECONDS),
          (timer) => _checkAndRefreshToken(),
    );

    debugPrint('🔄 Token monitoring started (checking every $CHECK_INTERVAL_SECONDS seconds)');
  }

  /// Stop monitoring
  void stopTokenMonitoring() {
    _tokenCheckTimer?.cancel();
    _tokenCheckTimer = null;
    debugPrint('⏸️ Token monitoring stopped');
  }

  /// Check if token needs refresh and call API if needed
  Future<void> _checkAndRefreshToken() async {
    if (_isRefreshing || _tokenReceivedTime == null || _expiresIn == null) {
      return;
    }

    final now = DateTime.now();
    final elapsedSeconds = now.difference(_tokenReceivedTime!).inSeconds;
    final remainingSeconds = _expiresIn! - elapsedSeconds;

    debugPrint('⏰ Token check: Elapsed: ${elapsedSeconds}s, Remaining: ${remainingSeconds}s');

    // Refresh if less than 1 minute remaining
    if (remainingSeconds <= REFRESH_BEFORE_EXPIRY_SECONDS && remainingSeconds > 0) {
      debugPrint('🔑 Token expiring soon! Triggering refresh...');
      await refreshToken();
    } else if (remainingSeconds <= 0) {
      debugPrint('❌ Token expired! Logging out user...');
      await _handleTokenRefreshFailure();
    }
  }

  /// Call refresh token API
  Future<bool> refreshToken() async {
    if (_isRefreshing) {
      debugPrint('⚠️ Refresh already in progress');
      return false;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.read(key: PrefStrings.refreshToken);

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('❌ No refresh token available');
        await _handleTokenRefreshFailure();
        _isRefreshing = false;
        return false;
      }

      // 🔥 Use LoginProvider's refresh API method
      final loginProvider = LoginProvider();
      final response = await loginProvider.refreshTokenAPI(refreshToken);

      if (response != null && response.success) {
        // Update token timing (tokens already stored by refreshTokenAPI)
        await initializeToken(response.data);

        debugPrint('✅ Token refreshed successfully');
        return true;
      } else {
        debugPrint('❌ Token refresh failed');
        await _handleTokenRefreshFailure();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error refreshing token: $e');
      await _handleTokenRefreshFailure();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Handle token refresh failure (logout user)
  Future<void> _handleTokenRefreshFailure() async {
    stopTokenMonitoring();
    await clearTokenData();

    // Navigate to login screen using GetX
    Get.offAllNamed(AppRoutes.loginPage);
    Get.snackbar(
      'Session Expired',
      'Please login again',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: PrefStrings.accessToken);
  }

  /// Check if token is valid
  Future<bool> isTokenValid() async {
    if (_tokenReceivedTime == null || _expiresIn == null) {
      await loadTokenData();
    }

    if (_tokenReceivedTime == null || _expiresIn == null) {
      return false;
    }

    final now = DateTime.now();
    final elapsedSeconds = now.difference(_tokenReceivedTime!).inSeconds;

    return elapsedSeconds < _expiresIn!;
  }

  /// Clear all token data (on logout)
  Future<void> clearTokenData() async {
    stopTokenMonitoring();

    await _storage.delete(key: KEY_TOKEN_RECEIVED_TIME);
    await _storage.delete(key: KEY_EXPIRES_IN);
    await _storage.delete(key: PrefStrings.accessToken);
    await _storage.delete(key: PrefStrings.refreshToken);
    await _storage.delete(key: PrefStrings.userData);

    _tokenReceivedTime = null;
    _expiresIn = null;

    debugPrint('🗑️ Token data cleared');
  }

  @override
  void onClose() {
    stopTokenMonitoring();
    super.onClose();
  }
}
