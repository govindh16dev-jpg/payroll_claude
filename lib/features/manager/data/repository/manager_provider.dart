import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:payroll/features/manager/model/leave_action.dart';

import '../../../../routes/app_pages.dart';
import '../../../../util/getUserdata.dart';
import '../../../profile_page/data/model/profile_model.dart';
import '../../model/manager_delegate.dart';

class ManagerProvider extends ApiProvider {

  Future<http.Response> createDelegate(DelegateData delegateData) async {
    http.Response response;
    try {
        response = await post(
        ApiConstants.createDelegate,
        body: {
          "client_id":delegateData.clientId,
          "company_id":delegateData.companyId,
          "employee_id":delegateData.employeeId,
          "delegate_employee_id":delegateData.delicateEmployeeId,
          "notification_employees":delegateData.employeeNotification,
          "from_date":delegateData.fromDate,
          "to_date":delegateData.toDate,
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
  Future<http.Response> updateDelegate(DelegateData delegateData) async {
    http.Response response;
    try {
        response = await post(
        ApiConstants.updateDelegate,
        body: {
          "delegate_id":delegateData.delicateId,
          "client_id":delegateData.clientId,
          "company_id":delegateData.companyId,
          "employee_id":delegateData.employeeId,
          "delegate_employee_id":delegateData.delicateEmployeeId,
          "notification_employees":delegateData.employeeNotification,
          "from_date":delegateData.fromDate,
          "to_date":delegateData.toDate,
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
  Future<http.Response> getLeaveData(ProfilePostData leaveData) async {
    try {
      final response = await post(
        ApiConstants.leaveManager,
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
  Future<http.Response> getCalendarLeaveData(ProfilePostData leaveData,DateTime fromDate) async {
    try {
      final response = await post(
        ApiConstants.leaveCalendarData,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId,
          "from_date":    dateTimeToString( fromDate, format: "yyyy-MM-dd"),
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
  Future<http.Response> updateLeaveStatus(LeaveActionPostData leaveActionData) async {
    try {
      final response = await post(
        ApiConstants.leaveStatusUpdate,
        body: leaveActionData.toJson(),
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
  Future<http.Response> checkDelegate(ProfilePostData profileData) async {
    try {
      final response = await post(
        ApiConstants.checkDelegate,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId
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
  Future<http.Response> getDelegateData(ProfilePostData profileData) async {
    try {
      final response = await post(
        ApiConstants.editDelegate,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId
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
  Future<http.Response> removeDelegate(ProfilePostData profileData,String delegateID) async {
    try {
      final response = await post(
        ApiConstants.removeDelegate,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId,
          "delegate_id":delegateID
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
  Future<http.Response> getManagersDropdown(ProfilePostData profileData) async {
    try {
      final response = await post(
        ApiConstants.managerDropdown,
        body: {
          "client_id": profileData.clientId,
          "company_id": profileData.companyId,
          "employee_id": profileData.employeeId
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
