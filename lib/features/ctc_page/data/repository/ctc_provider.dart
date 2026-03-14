import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../routes/app_pages.dart';
import '../../../profile_page/data/model/profile_model.dart';

class CTCProvider extends ApiProvider {

  Future<http.Response> getTaxDropdown(
      ProfilePostData empData) async {
    try {
      final response = await post(
        ApiConstants.taxDropdown,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId,
        },
      );

      if (response.statusCode == 200) {

        return response;
      }else if(response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getCTCData(ProfilePostData profileData,int selectedYear) async {
    try {
      final response = await post(
        ApiConstants.ctcData,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId,
          "from_date": "2025-07-12",
          "to_date": "2023-07-15"
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> downloadCTC(ProfilePostData empData) async {
    try {
      final response = await post(
        ApiConstants.ctcDownload,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId
        },
      );

      if (response.statusCode == 200) {
        return response;
      }else if(response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      }
      else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }
}
