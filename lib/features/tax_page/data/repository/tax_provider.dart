import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../routes/app_pages.dart';
import '../../../profile_page/data/model/profile_model.dart';

class TaxProvider extends ApiProvider {

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

  Future<http.Response> getTaxData(ProfilePostData leaveData,int selectedYear) async {
    try {
      final response = await post(
        ApiConstants.taxData,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId,
          "company_financial_year_id":selectedYear,
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else if(response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      }else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }
  Future<http.Response> downloadTaxPdf(ProfilePostData leaveData,int selectedYear) async {
    try {
      final response = await post(
        ApiConstants.taxDownload,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId,
          "company_financial_year_id":selectedYear,
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
}
