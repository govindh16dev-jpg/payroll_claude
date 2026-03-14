import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payroll/service/token_manager.dart';

class AppLifecycleController extends GetxController with WidgetsBindingObserver {
  final TokenManager _tokenManager = Get.find<TokenManager>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Load token data on app start
    _tokenManager.loadTokenData();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground - start monitoring
        debugPrint('🟢 App resumed - Starting token monitoring');
        _tokenManager.startTokenMonitoring();
        break;
        
      case AppLifecycleState.paused:
        // App is in background - stop monitoring
        debugPrint('🟡 App paused - Stopping token monitoring');
        _tokenManager.stopTokenMonitoring();
        break;
        
      case AppLifecycleState.inactive:
        debugPrint('⚪ App inactive');
        break;
        
      case AppLifecycleState.detached:
        debugPrint('🔴 App detached');
        _tokenManager.stopTokenMonitoring();
        break;
      case AppLifecycleState.hidden:
        debugPrint('🔴 App hidden');
        _tokenManager.stopTokenMonitoring();
        break;
    }
  }
}
