import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../routes/app_route.dart';
import '../../../../service/token_manager.dart';
import '../../domain/model/login_model.dart';
import 'package:http/http.dart' as http;

class LoginProvider extends ApiProvider {
  final TokenManager _tokenManager = Get.find<TokenManager>();

  Future<UserData> loginWithSSO(String ssoToken) async {
    try {
      debugPrint('🔗 Calling SSO login API with token...');

      final response = await post(
        ApiConstants.ssoLogin,
        body: {
          'sso_token': ssoToken,
        },
      );

      debugPrint('SSO Login Response Body: ${response.body}');
      debugPrint('SSO Login Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final loginResponse = loginResponseFromJson(response.body);

        if (loginResponse.success) {
          const storage = FlutterSecureStorage();
          String strData = userDataToJson(loginResponse.data);
          UserData userData = loginResponse.data;
          DateTime tokenReceivedTime = DateTime.now();


          // Store all data
          await storage.write(key: PrefStrings.userData, value: strData);
          await storage.write(
              key: PrefStrings.accessToken, value: userData.accessToken);
          await storage.write(
              key: PrefStrings.refreshToken, value: userData.refreshToken);
          await storage.write(
              key: PrefStrings.ssoTokenReceivedTime,
              value: tokenReceivedTime.toIso8601String());
          await storage.write(key: PrefStrings.isSSOLogin, value: 'true');
          await storage.write(
              key: PrefStrings.ssoTokenExpiresIn,
              value: userData.expiresIn.toString());
          // 🔥 mark deep link as consumed
          await storage.write(key: PrefStrings.ssoLinkConsumed, value: 'true');
          print('ssoLoginData $strData');
          // SSO login doesn't need to remember credentials
          await storage.write(key: PrefStrings.rememberMe, value: 'false');

          // 🔥 Initialize Token Manager with automatic refresh
          if (userData.refreshToken != null) {
            await _tokenManager.initializeToken(userData);
          }

          debugPrint('✅ SSO Login successful');
          return loginResponse.data;
        } else {
          final responseData = jsonDecode(response.body);
          String? cleanedError =
              responseData['data']['error_msg']?.toString().trim();
          throw CustomException(cleanedError ?? 'SSO Authentication Failed');
        }
      } else if (response.statusCode == 401) {
        throw CustomException('Invalid or expired SSO token');
      } else {
        final responseData = jsonDecode(response.body);
        String? cleanedError =
            responseData['data']['error_msg']?.toString().trim();
        throw CustomException(cleanedError ?? 'SSO Login Error Occurred');
      }
    } catch (e, s) {
      debugPrint("SSO Login error: $e $s");
      rethrow;
    }
  }

  Future<UserData> login(LoginPostData userDetails, bool saveUserCred) async {
    try {
      final response = await post(
        ApiConstants.login,
        headers: getJsonHeader(),
        body: {
          'email': userDetails.email,
          'password': userDetails.password,
        },
      );

      final loginResponse = loginResponseFromJson(response.body);
      print('Response Body: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (loginResponse.success) {
          const storage = FlutterSecureStorage();
          String strData = userDataToJson(loginResponse.data);
          UserData userData = loginResponse.data;

          // Store all data
          await storage.write(key: PrefStrings.userData, value: strData);
          await storage.write(
              key: PrefStrings.accessToken, value: userData.accessToken);
          await storage.write(
              key: PrefStrings.refreshToken, value: userData.refreshToken);
          await storage.write(
              key: PrefStrings.rememberMe, value: saveUserCred.toString());

          if (saveUserCred) {
            String strCredData = loginCredentialsToJson(LoginCredentials(
                email: userDetails.email!, password: userDetails.password!));
            await storage.write(
                key: PrefStrings.userCredentialsData, value: strCredData);
          }

          // 🔥 Initialize Token Manager with automatic refresh
          await _tokenManager.initializeToken(userData);

          return loginResponse.data;
        } else {
          final responseData = jsonDecode(response.body);
          String? cleanedError =
              responseData['data']['error_msg']?.toString().trim();
          throw CustomException(cleanedError ?? 'Error Occurred');
        }
      } else {
        final responseData = jsonDecode(response.body);
        String? cleanedError =
            responseData['data']['error_msg']?.toString().trim();
        throw CustomException(cleanedError ?? 'Error Occurred');
      }
    } catch (e, s) {
      debugPrint("Login error: $e $s");
      rethrow;
    }
  }

  /// 🔥 Refresh Token API Call
  Future<LoginResponse?> refreshTokenAPI(String refreshToken) async {
    try {
      debugPrint('🔄 Calling refresh token API...');

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $refreshToken', // Some APIs expect this
            },
            body: json.encode({
              'refresh_token': refreshToken,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Refresh API Status: ${response.statusCode}');
      log('Refresh API Body: ${response.body}');

      if (response.statusCode == 200) {
        final refreshResponse = loginResponseFromJson(response.body);

        if (refreshResponse.success) {
          const storage = FlutterSecureStorage();
          UserData userData = refreshResponse.data;

          // Update stored tokens
          await storage.write(
              key: PrefStrings.accessToken, value: userData.accessToken);
          await storage.write(
              key: PrefStrings.refreshToken, value: userData.refreshToken);
          // await storage.write(
          //     key: PrefStrings.userData, value: userDataToJson(userData));

          debugPrint('✅ Refresh token API successful');
          return refreshResponse;
        } else {
          debugPrint('❌ Refresh API returned success=false');
          return null;
        }
      } else if (response.statusCode == 401) {
        debugPrint('❌ Refresh token expired or invalid (401)');
        return null;
      } else {
        debugPrint('❌ Refresh API error: ${response.statusCode}');
        return null;
      }
    } catch (e, s) {
      debugPrint('❌ Refresh token API error: $e\n$s');
      return null;
    }
  }

  Future<http.Response> deActivateUser() async {
    http.Response response;
    try {
      response = await get(
        ApiConstants.deactivateAccount,
      );
      if (response.statusCode == 200) {
        // Clear token data on account deactivation
        await _tokenManager.clearTokenData();
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        print(response.body);
        final responseData = jsonDecode(response.body);
        String? cleanedError =
            responseData['data']['error_msg']?.toString().trim();
        throw CustomException(cleanedError ?? 'Error Occurred');
      }
    } catch (e, s) {
      debugPrint("Deactivate error: $e $s");
      rethrow;
    }
  }

  /// Logout and clear all data
  Future<void> logout() async {
    await _tokenManager.clearTokenData();
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    Get.offAllNamed(AppRoutes.loginPage);
  }
}
