import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../routes/app_pages.dart';
import '../../../profile_page/data/model/profile_model.dart';
class HomePageProvider extends ApiProvider {

  Future<http.Response> getBannerData(ProfilePostData profileData ) async {
    http.Response response;
    try {
      response = await post(
        ApiConstants.getBannersData,
          body: {
      "client_id": profileData.clientId,
      "company_id": profileData.companyId,
      "employee_id": profileData.employeeId,}
      );
      if (response.statusCode == 200) {
        return response;
      } else if(response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      }else {
        final responseData = jsonDecode(response.body);
        String cleanedError = responseData['data'][0]['error_msg'].split("]").last.trim();
        throw CustomException(cleanedError);
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getMenuData( ) async {
    http.Response response;
    try {
      response = await get(
        ApiConstants.getMenus,

      );
      if (response.statusCode == 200) {
        return response;
      } else if(response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      }else {
        print(response.body);
        final responseData = jsonDecode(response.body);
        String cleanedError = responseData['data'][0]['error_msg'].split("]").last.trim();
        throw CustomException(cleanedError);
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getNotificationDropdownData( ) async {
    http.Response response;
    try {
      response = await getNotificationDropdown(
        ApiConstants.notification,

      );
      if (response.statusCode == 200) {
        return response;
      } else if(response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      }else {
        print(response.body);
        final responseData = jsonDecode(response.body);
        String cleanedError = responseData['data'][0]['error_msg'].split("]").last.trim();
        throw CustomException(cleanedError);
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getNotificationData(String roleId,String section ) async {
    http.Response response;
    try {
      response = await getNotification(
        ApiConstants.notification,
        body: {
          "section": section,
          "role": roleId,
        },
      );
      if (response.statusCode == 200) {
        return response;
      } else if(response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      }else {
        print(response.body);
        final responseData = jsonDecode(response.body);
        String cleanedError = responseData['data'][0]['error_msg'].split("]").last.trim();
        throw CustomException(cleanedError);
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

}
