// ignore_for_file: file_names, library_private_types_in_public_api, unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:payroll/routes/app_route.dart';

import '../../../config/appstates.dart';
import '../../../config/constants.dart';
import '../../../service/app_expection.dart';
import '../../../theme/theme_controller.dart';
import '../data/repository/login_provider.dart';
import '../domain/model/login_model.dart';

class BiometricAuth extends StatefulWidget {
  final bool rememberMe;

  const BiometricAuth({
    super.key,
    required this.rememberMe,
  });

  @override
  _BiometricAuthState createState() => _BiometricAuthState();
}

enum SupportState {
  unknown,
  supported,
  unsupported,
}

class _BiometricAuthState extends State<BiometricAuth> {
  final LocalAuthentication auth = LocalAuthentication();
  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometrics;
  bool hasFingerprint = false;
  bool hasFaceRecognition = false;
  var loading = Loading.initial.obs;
  final LoginProvider loginProvider = Get.put(LoginProvider());
  static const storage = FlutterSecureStorage();
  final appStateController = Get.put(AppStates());

  @override
  void initState() {
    auth.isDeviceSupported().then((bool isSupported) {
      setState(() {
        supportState =
        isSupported ? SupportState.supported : SupportState.unsupported;
      });
      if (isSupported) {
        checkBiometric();
        getAvailableBiometrics();
      }
    });
    super.initState();
  }

  Future<void> checkBiometric() async {
    late bool canCheckBiometric;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
      canCheckBiometric = false;
    }
  }

  onLoginTap() async {
    try {
      loading.value = Loading.loading;
      String? userCredData;
      LoginCredentials? userData;
      userCredData = await storage.read(key: PrefStrings.userCredentialsData);
      if (userCredData != null) {
        userData = loginCredentialsFromJson(userCredData);
      }
      LoginPostData userDetails = LoginPostData(
        email: userData?.email,
        password: userData?.password,
      );
      await loginProvider.login(userDetails, widget.rememberMe).then((value) {
        loading.value = Loading.loaded;
        appStateController.userData.value = value;
        Get.offAllNamed(AppRoutes.homePage);
      });
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> biometricTypes;
    try {
      biometricTypes = await auth.getAvailableBiometrics();
      print("Supported biometrics $biometricTypes");

      if (Platform.isIOS) {
        // iOS returns specific biometric types
        if (biometricTypes.contains(BiometricType.face)) {
          setState(() {
            hasFaceRecognition = true;
            appStateController.isBioMetricsSupported.value = true;
          });
        }
        if (biometricTypes.contains(BiometricType.fingerprint)) {
          setState(() {
            hasFingerprint = true;
            appStateController.isBioMetricsSupported.value = true;
          });
        }
      } else if (Platform.isAndroid) {
        // Android: just check if ANY biometric is available
        // Android returns weak/strong, not specific types
        if (biometricTypes.isNotEmpty) {
          appStateController.isBioMetricsSupported.value = true;
          // Set one flag for display purposes - show single biometric icon
          setState(() {
            hasFingerprint = true; // Use this to show the single icon
            hasFaceRecognition = false; // Don't show separate face icon on Android
          });
        }
      }
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      availableBiometrics = biometricTypes;
    });
  }

  Future<void> authenticateWithBiometric(String biometricType) async {
    try {
      String localizedReason;

      if (Platform.isIOS) {
        // iOS-specific messages
        if (biometricType == 'face') {
          localizedReason = 'Authenticate with Face ID';
        } else {
          localizedReason = 'Authenticate with Touch ID';
        }
      } else {
        // Android generic message (OS decides which biometric to use)
        localizedReason = 'Authenticate to continue';
      }

      final authenticated = await auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (!mounted) {
        return;
      }
      if (authenticated) {
        onLoginTap();
      }
    } on PlatformException catch (e) {
      print(e);
      // Show error message to user
      if (e.code == 'NotAvailable') {
        appSnackBar(
          data: 'Biometric authentication not available',
          color: AppColors.appRedColor,
        );
      } else if (e.code == 'NotEnrolled') {
        appSnackBar(
          data: 'No biometrics enrolled on this device',
          color: AppColors.appRedColor,
        );
      }
      return;
    }
  }

  Widget _buildBiometricButton(dynamic appTheme, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: appTheme.appColor.withAlpha(20),
      ),
      padding: EdgeInsets.all(20),
      child: Icon(
        icon,
        size: 60,
        color: appTheme.appColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    if (supportState == SupportState.unsupported) {
      return Container(
        alignment: Alignment.center,
        child: Text(
          'Biometric authentication is not supported on this device',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: appTheme.red,
          ),
        ),
      );
    }

    // If no biometrics are available, don't show anything
    if (!hasFingerprint && !hasFaceRecognition) {
      return SizedBox.shrink();
    }

    // Platform-specific rendering
    if (Platform.isIOS) {
      // iOS: Show specific icons for enrolled biometrics
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (hasFingerprint)
            GestureDetector(
              onTap: () => authenticateWithBiometric('fingerprint'),
              child: _buildBiometricButton(
                appTheme,
                Icons.fingerprint,
              ),
            ),
          if (hasFaceRecognition)
            GestureDetector(
              onTap: () => authenticateWithBiometric('face'),
              child: _buildBiometricButton(
                appTheme,
                Icons.face_unlock_outlined,
              ),
            ),
        ],
      );
    } else {
      // Android: Show single biometric icon (OS handles which type)
      return Center(
        child: GestureDetector(
          onTap: () => authenticateWithBiometric('biometric'),
          child: _buildBiometricButton(
            appTheme,
            Icons.fingerprint, // Generic biometric icon
          ),
        ),
      );
    }
  }
}
