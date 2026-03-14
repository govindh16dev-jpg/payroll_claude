import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/routes/app_route.dart';

import '../routes/app_pages.dart';

// class ApiService {
//   static Future<LoginResponse> login(
//       String email, String password) async {
//
//     try {
//       var response = await http.post(
//         Uri.parse('https://hroapi.smartiapps.com/api/login'),
//         body: {'email': email, 'password': password},
//       );
//
//       if (response.statusCode == 200) {
//         // Decode the response body
//         LoginResponse responseData = loginResponseFromJson(response.body);
//
//         // Save token and user data to secure storage
//         const storage = FlutterSecureStorage();
//         await storage.write(key: PrefStrings.loginData, value: loginResponseToJson(responseData));
//
//
//         return responseData;
//       }
//
//     } catch (e) {
//       // return null;
//     }
//     return null;
//   }
//
//   //payslipdropdown
// }

class ProgressService extends GetxService {
  var showProgress = false.obs;

  Future<ProgressService> init() async {
    return this;
  }

  showProgressDialog(bool show) {
    showProgress.value = show;
  }
}

class ApiProvider {
  // static const String version = 'v1';
  final String baseUrl = ApiConstants.baseUrl;
  final String notifyUrl = ApiConstants.notifyUrl;
  final String notifyDropdownUrl = ApiConstants.notifyDropdownUrl;
  final String notifyUpdateToken = ApiConstants.notifyUpdateToken;
  final String notifyStatus = ApiConstants.notifyStatus;
  final String jsonHeaderName = "Content-Type";
  final String jsonHeaderValue = "application/json";
  final String jsonMultipartHeaderValue = "multipart/form-data";
  final String jsonAuthenticationName = "Authorization";
  final String jsonHeaderRoleName = "role";
  final String jsonHeaderRoleValue = "Customer";
  final int successResponse = 200;
  String _token = "";

  //
  final NetworkService networkManager = Get.find<NetworkService>();
  final ProgressService progressService = Get.find<ProgressService>();
  // final SharedPreferences preferenceService = Get.find<SharedPreferences>();

  Future<void> navigateToLogin() async {
    Get.offAllNamed(AppRoutes.loginPage);
  }

  Map<String, String> getJsonHeader() {
    var header = <String, String>{};
    header[jsonHeaderName] = jsonHeaderValue;
    return header;
  }

  Future<Map<String, String>> getJsonHeaderURL({int version = 6}) async {
    _token = await _getAuthToken();
    var header = <String, String>{};
    header[jsonHeaderName] = jsonHeaderValue;
    header[jsonAuthenticationName] = 'Bearer $_token';

    return header;
  }

  Future<Map<String, String>> getAuthorisedHeader() async {
    if (_token.isEmpty) {
      _token = await _getAuthToken();
    }
    var header = getJsonHeader();
    if (_token.isNotEmpty) {
      header[jsonAuthenticationName] = 'Bearer $_token';
    }
    if (kDebugMode) { log("Token is $_token");
    }
    return header;
  }

  Future<Map<String, String>> getJsonMultipartAuthHeader() async {
    _token = await _getAuthToken();
    var header = <String, String>{};
    header[jsonHeaderName] = jsonMultipartHeaderValue;
    header[jsonHeaderRoleName] = jsonHeaderRoleValue;
    header[jsonAuthenticationName] = 'Bearer $_token';
    return header;
  }

  Future<Map<String, String>> getAuthorisedFormDataHeader() async {
    if (_token.isEmpty) {
      _token = await _getAuthToken();
    }
    var header = <String, String>{};
    if (_token.isNotEmpty) {
      header[jsonAuthenticationName] = 'Bearer $_token';
    }
    if (kDebugMode)  log("Token is $_token");
    return header;
  }

  Future<String> _getAuthToken() async {
    const storage = FlutterSecureStorage();
    var token = await storage.read(key: PrefStrings.accessToken) ?? '';
    return token;
  }

  get(String url,
      {Map<String, String>? headers, bool closeDialogOnTimeout = true}) async {
    if (headers == null) {
      headers = await getAuthorisedHeader();
      if (kDebugMode) log("headers: $headers");
    }
    if (true) {
      if (kDebugMode) log('url: $baseUrl$url');
      var response = await http
          .get(Uri.parse(baseUrl + url), headers: headers)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        if (closeDialogOnTimeout) {
          progressService.showProgressDialog(false);
        }
        throw Exception(); // CustomException(AppString.timeoutMessage);
      });
      if(response.statusCode==401){
        navigateToLogin();
      }
      if (kDebugMode)   print('response$url: ${response.body}');
      return response;
    } else {
      throw Exception(); // NoInternetException(AppString.noInternetConnection);
    }
  }

  getNotification(String url,
      {Map<String, String>? headers,body, bool closeDialogOnTimeout = true}) async {
    if (headers == null) {
      headers = await getAuthorisedHeader();
      if (kDebugMode)   log("headers: $headers");
    }
    if (true) {
      if (kDebugMode)  log('url: $baseUrl$url');
      if (kDebugMode)    log('body: $body');
      if (kDebugMode)   log("headers: $headers");

      var response = await http
          .post(Uri.parse(notifyUrl), headers: headers,body: jsonEncode(body) )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        if (closeDialogOnTimeout) {
          progressService.showProgressDialog(false);
        }
        throw Exception(); // CustomException(AppString.timeoutMessage);
      });
      if(response.statusCode==401){
        navigateToLogin();
      }
      return response;
    } else {
      throw Exception(); // NoInternetException(AppString.noInternetConnection);
    }
  }

  updateToken(String url,
      {Map<String, String>? headers,body, bool closeDialogOnTimeout = true}) async {
    if (headers == null) {
      headers = await getAuthorisedHeader();
      if (kDebugMode)    log("headerssss: $headers");
    }
    if (true) {
      var response = await http
          .post(Uri.parse(notifyUpdateToken), headers: headers,body: jsonEncode(body) )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        if (closeDialogOnTimeout) {
          progressService.showProgressDialog(false);
        }
        throw Exception(); // CustomException(AppString.timeoutMessage);
      });
      // log("resr: ${response.request?.url}");
      // log("resr: ${response.body}");
      if(response.statusCode==401){
        navigateToLogin();
      }
      return response;
    } else {
      throw Exception(); // NoInternetException(AppString.noInternetConnection);
    }
  }

  updateNotificationStatus(String url,
      {Map<String, String>? headers,body, bool closeDialogOnTimeout = true}) async {
    if (headers == null) {
      headers = await getAuthorisedHeader();
      if (kDebugMode) log("headerssss: $headers");
    }
    if (true) {
      var response = await http
          .post(Uri.parse(notifyStatus), headers: headers,body: jsonEncode(body) )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        if (closeDialogOnTimeout) {
          progressService.showProgressDialog(false);
        }
        throw Exception(); // CustomException(AppString.timeoutMessage);
      });
      // log("resr: ${response.request?.url}");
      // log("resr: ${response.body}");
      if(response.statusCode==401){
        navigateToLogin();
      }
      return response;
    } else {
      throw Exception(); // NoInternetException(AppString.noInternetConnection);
    }
  }

  getNotificationDropdown(String url,
      {Map<String, String>? headers, bool closeDialogOnTimeout = true}) async {
    if (headers == null) {
      headers = await getAuthorisedHeader();
      if (kDebugMode)   log("headers: $headers");
    }
    if (true) {
      if (kDebugMode)  log('url: $baseUrl$url');
      var response = await http
          .get(Uri.parse(notifyDropdownUrl), headers: headers)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        if (closeDialogOnTimeout) {
          progressService.showProgressDialog(false);
        }
        throw Exception(); // CustomException(AppString.timeoutMessage);
      });
      if(response.statusCode==401){
        navigateToLogin();
      }
      return response;
    } else {
      throw Exception(); // NoInternetException(AppString.noInternetConnection);
    }
  }

  delete(String url,
      {Map<String, String>? headers, bool closeDialogOnTimeout = true}) async {
    if (headers == null) {
      headers = await getAuthorisedHeader();
      if (kDebugMode) log("headers: $headers");
    }
    if (networkManager.connectivityResult) {
      if (kDebugMode)  log('url: $baseUrl$url');
      var response = await http
          .delete(Uri.parse(baseUrl + url), headers: headers)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        if (closeDialogOnTimeout) {
          progressService.showProgressDialog(false);
        }
        throw Exception(); // CustomException(AppString.timeoutMessage);
      });
      if(response.statusCode==401){
        navigateToLogin();
      }
      return response;
    } else {
      throw Exception(); //NoInternetException(AppString.noInternetConnection);
    }
  }

  getWithPrams(Uri url,
      {Map<String, String>? headers, bool closeDialogOnTimeout = true}) async {
    if (headers == null) {
      headers = await getAuthorisedHeader();
      if (kDebugMode)  log("headers: $headers");
    }
    if (networkManager.connectivityResult) {
      if (kDebugMode)  log('url:$baseUrl$url');
      var response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        if (closeDialogOnTimeout) {
          progressService.showProgressDialog(false);
        }
        throw Exception(); // CustomException(AppString.timeoutMessage);
      });
      if(response.statusCode==401){
        navigateToLogin();
      }
      return response;
    } else {
      throw Exception(); //NoInternetException(AppString.noInternetConnection);
    }
  }

  Future<http.Response> post(String url,
      {String? endPoint,
      Map<String, String>? headers,
      body,
      Encoding? encoding,
      bool closeDialogOnTimeout = true}) async {
    endPoint ??= baseUrl;
    headers ??= await getAuthorisedHeader();
    if (true) {
      if(kDebugMode){
        log('url: $endPoint$url');
        log('body: $body');
        log("headers: $headers");
      }
      var response = await http
          .post(Uri.parse(endPoint + url),
              headers: headers, body: jsonEncode(body), encoding: encoding)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        if (closeDialogOnTimeout) {
          progressService.showProgressDialog(false);
        }
        throw Exception(); // CustomException(AppString.timeoutMessage);
      });
        if (kDebugMode) {
          log("response: ${response.body}");
        }
      // log("response: ${response.statusCode}");
      if(response.statusCode==401&&endPoint!="login"){
        navigateToLogin();
      }
      return response;
    }
  }

  Future<http.Response> put(String url,
      {Map<String, String>? headers,
      body,
      Encoding? encoding,
      bool closeDialogOnTimeout = true}) async {
    headers ??= await getAuthorisedHeader();
    if (networkManager.connectivityResult) {
      if (kDebugMode) {
        log('url: $baseUrl$url');
        log('body: $body');
      }
      var response = await http
          .put(Uri.parse(baseUrl + url),
              headers: headers, body: body, encoding: encoding)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        if (closeDialogOnTimeout) {
          progressService.showProgressDialog(false);
        }
        throw Exception(); // CustomException(AppString.timeoutMessage);
      });
      // log('response: ${response.body}');
      if(response.statusCode==401){
        navigateToLogin();
      }
      return response;
    } else {
      throw Exception(); //NoInternetException(AppString.noInternetConnection);
    }
  }

  Future<http.Response> uploadImage(
      Map<String, File> images,
      Map<String, dynamic> body,
      String url, {
        String type = "POST",
        Map<String, String>? headers,
      }) async {
    if (!networkManager.connectivityResult) {
      throw Exception("No internet connection");
    }

    final uri = Uri.parse(baseUrl + url);
    if (kDebugMode) {
      log("url: $baseUrl$url");
      log("body: $body");
    }

    final request = http.MultipartRequest(type, uri);

    // Add headers
    request.headers.addAll(headers ?? await getAuthorisedHeader());
    if (kDebugMode) log("headers: ${request.headers}");

    // Add image files correctly
    for (var entry in images.entries) {
      final key = entry.key;
      final file = entry.value;

      final multipartFile = await http.MultipartFile.fromPath(key, file.path);
      request.files.add(multipartFile);
    }

    // Add fields
    body.forEach((key, value) {
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          request.fields['$key[$i]'] = jsonEncode(value[i]);
        }
      } else {
        request.fields[key] = value.toString();
      }
    });

    log("sending request...");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // log("response: ${response.statusCode}");
    // log("response body: ${response.body}");
    if(response.statusCode==401){
      navigateToLogin();
    }
    return response;
  }
  Future<http.Response> uploadImageFormData(
      Map<String, File> images,
      Map<String, dynamic> body,
      String url, {
        String type = "POST",
        Map<String, String>? headers,
      }) async {
    if (!networkManager.connectivityResult) {
      throw Exception("No internet connection");
    }

    final uri = Uri.parse(baseUrl + url);
    if (kDebugMode)    log("🔗 URL: $uri");

    final request = http.MultipartRequest(type, uri);

    final mergedHeaders = headers ?? await getAuthorisedHeader();
    request.headers.addAll(mergedHeaders);
    if (kDebugMode)  log("🧾 Headers: $mergedHeaders");

    for (var entry in images.entries) {
      final key = entry.key;
      final file = entry.value;

      if (file.existsSync()) {
        final fileName = file.path.split("/").last;
        final fileBytes = await file.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            key,
            fileBytes,
            filename: fileName,

          ),
        );

        log("📎 File added: key=$key, name=$fileName, size=${fileBytes.length}");
      } else {
        log("⚠️ File not found: ${file.path}");
      }
    }

    // ✅ Append fields like FormData.append()
    body.forEach((key, value) {
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          request.fields["$key[$i]"] = jsonEncode(value[i]);
        }
      } else {
        request.fields[key] = value.toString();
      }
    });

    log("📤 Sending multipart/form-data request...");

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);


      if (kDebugMode) {
        log("✅ Status: ${response.statusCode}");
        log("📨 Body: ${response.body}");
      }
      if (response.statusCode >= 400) {
        throw Exception("Upload failed: ${response.body}");
      }
      if(response.statusCode==401){
        navigateToLogin();
      }
      return response;
    } catch (e, stack) {
      log("❌ Upload error: $e");
      log("🪵 Stack: $stack");
      rethrow;
    }
  }


  Map<String, String> getAstrologyHeader() {
    String basicAuth = 'Basic ';
    Map<String, String> headers = {
      'authorization': basicAuth,
      'Content-Type': 'application/json',
    };
    return headers;
  }
}
