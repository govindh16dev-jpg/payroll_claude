import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../routes/app_pages.dart';
import '../../../profile_page/data/model/profile_model.dart';
import '../models/payslip_dropdown.dart';

class PayslipProvider extends ApiProvider {

  Future<PayslipDropdownData> getPaySlipDropDown(
      ProfilePostData empData) async {
    try {
      final response = await post(
        ApiConstants.paySlipDropdown,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        List<String> years = [];
        Map<String, List<String>> yearMonthMap = {};

        // Extract year numbers from the first array in the response data
        for (var item in responseData['data']['pay_slip'][0]) {
          years.add(item['year_no'].toString());
        }

        // Extract month names and match them with corresponding year numbers
        for (var entry in responseData['data']['pay_slip'][1]) {
          String year = entry['year_no'];
          String month = entry['month_name'];
          if (!yearMonthMap.containsKey(year)) {
            yearMonthMap[year] = [];
          }
          yearMonthMap[year]!.add(month);
        }

        return PayslipDropdownData(years: years, yearMonthMap: yearMonthMap);
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

  Future<http.Response> getPaySlipData(ProfilePostData empData,
      String selectedYear, String selectedMonth) async {
    try {
      final response = await post(
        ApiConstants.paySlipData,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId,
          "year_no": selectedYear,
          "month_name": selectedMonth
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

  Future<http.Response> downloadPaySlip(ProfilePostData empData,
      String selectedYear, String selectedMonth) async {
    try {
      final response = await post(
        ApiConstants.paySlipDownload,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId,
          "year_no": selectedYear,
          "month_name": selectedMonth
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
  Future<http.Response> getFormulaData(ProfilePostData empData,
      String payId,String componentId  ) async {
    try {
      final response = await post(
        ApiConstants.paySlipPopup,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId,
          "pay_id": payId,
          "component_id": componentId
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
  Future<http.Response> getIncomeTaxData(ProfilePostData empData,
      String selectedYear, String selectedMonth) async {
    try {
      final response = await post(
        ApiConstants.incomeTaxData,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId,
          "year_no": selectedYear,
          "month_name": selectedMonth
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

}
