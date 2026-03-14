import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../../../routes/app_pages.dart';
import '../model/profile_model.dart';
import 'package:http/http.dart' as http;

class ProfileRepository extends ApiProvider {
  Future<http.Response> updateProfileImage(ProfilePostData empData,File image) async {
    try {
      final response = await uploadImageFormData(
        {
          "profile_img":image
        },
        empData.toJson(),
        ApiConstants.userProfileUpdate,
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
  Future<List<UserProfile>> getUserProfile(ProfilePostData empData) async {
    try {
      final response = await post(
        ApiConstants.userProfile,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId,
        },
      );
      // final profileResponse = profileDataFromJson(response.body);
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final employeeInfo = responseData['data']['employee_info'];
        final employmentInfo = responseData['data']['employment_info'];
        final bankInfo = responseData['data']['bank_info'];

        final userData = employeeInfo[0];
        final bankData = bankInfo[0];
        final employmentData = employmentInfo[0];
        List<UserProfile> transformed = [
          UserProfile(
            dataOfJoining: employmentData['DOJ'],
            departmentName: employmentData['Department'],
            dob: userData['DOB'],
            email: userData['Work Mail'],
            employeeName: userData['Name'],
            firstName: userData['first_name'],
            mobile: userData['Mobile'],
            sex: userData['Gender'],
            workExperiences: employmentData['Experience'],
            jobTitle:employmentData['Job Title'],
            bankName: bankData['Bank Name'],
            accountNumber: bankData['Account Number'],
            accountType: bankData['Accont type'],
            bankBranch: bankData['Branch'],
            img: userData['img'],
            userData: responseData['data']
          )
        ];
        return transformed;
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

  Future<http.Response> removeDocument(ProfilePostData empData,String docId) async {
    try {
      final response = await post(
        ApiConstants.docRemove,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId,
          "employee_document_id":docId
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
