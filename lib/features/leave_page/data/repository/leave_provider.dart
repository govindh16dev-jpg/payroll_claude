import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../routes/app_pages.dart';
import '../../../../util/getUserdata.dart';
import '../../../profile_page/data/model/profile_model.dart';
import '../../model/apply_leave.dart';

class LeaveProvider extends ApiProvider {

  Future<http.Response> applyLeave(ApplyLeavePostData leaveData) async {
    http.Response response;
    try {
        response = await post(
        ApiConstants.applyLeave,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId,
          "leave_plan_type_id": leaveData.leavePlanTypeId,
          // "leave_plan_id": leaveData.leavePlanId,
          "from_date":
              dateTimeToString(leaveData.fromDate!, format: "yyyy-MM-dd"),
          "to_date": dateTimeToString(leaveData.toDate!, format: "yyyy-MM-dd"),
          "leave_reason": leaveData.leaveReason,
          "leave_details": leaveData.leaveDetails,
          "attachment_url": leaveData.attachmentUrl,
          "expected_date": leaveData.expectedDate,
          "alternative_contact_number": leaveData.alternativeContactNumber,
          "no_of_days": leaveData.noOfDays,
          "address_to_contact": leaveData.addressToContact,
        },
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
  Future<http.Response> validateLeave(ApplyLeavePostData leaveData) async {
    http.Response response;
    try {
        response = await post(
        ApiConstants.validateLeave,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId,
          "leave_plan_type_id": leaveData.leavePlanTypeId,
          // "leave_plan_id": leaveData.leavePlanId,
          "from_date":
              dateTimeToString(leaveData.fromDate!, format: "yyyy-MM-dd"),
          "to_date": dateTimeToString(leaveData.toDate!, format: "yyyy-MM-dd"),
          "leave_reason": leaveData.leaveReason,
          "leave_details": leaveData.leaveDetails,
          "attachment_url": leaveData.attachmentUrl,
          "expected_date": leaveData.expectedDate,
          "alternative_contact_number": leaveData.alternativeContactNumber,
          "no_of_days": leaveData.noOfDays,
          "address_to_contact": leaveData.addressToContact,
        },
      );

      if (response.statusCode == 200) {
        return response;
      }else if(response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        final responseData = jsonDecode(response.body);
        String cleanedError = responseData['data'][0]['error_msg'].split("]").last.trim();
        throw CustomException(cleanedError);
      }
    } catch (e, s) {
      debugPrint("we got  $e $s");
      rethrow;
    }
  }

  Future<http.Response> getLeave(ProfilePostData leaveData) async {
    try {
      final response = await post(
        ApiConstants.getLeave,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId
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
