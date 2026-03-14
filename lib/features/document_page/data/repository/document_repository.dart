import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../../routes/app_pages.dart';
import '../../../profile_page/data/model/profile_model.dart';
import '../model/document_model.dart';

class DocumentRepository extends ApiProvider {
  Future<http.Response> getDocDropdown(ProfilePostData leaveData) async {
    try {
      final response = await post(
        ApiConstants.docDropdown,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId
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

  Future<http.Response> getDocDetails(ProfilePostData leaveData,
      String docId) async {
    try {
      final response = await post(
        ApiConstants.docDetails,
        body: {
          "client_id": leaveData.clientId,
          "company_id": leaveData.companyId,
          "employee_id": leaveData.employeeId,
          "employee_document_id": docId
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

  Future<http.Response> editDocument(DocumentPostData docData,
      File image) async {
    try {
      final response = await uploadImageFormData(
        {
          "document": image
        },
        docData.toJson(),
        ApiConstants.docAdd,
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

  Future<http.Response> addDocument(DocumentPostData docData,
      File? image) async {
    try {
      final response = image != null
          ? await uploadImageFormData(
        {"document": image},
        docData.toJson(),
        ApiConstants.docAdd,
      )
          : await uploadImageFormData(
        {}, // Empty map when no image
        docData.toJson(),
        ApiConstants.docAdd,
      );

      if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 401) {
        throw CustomException('Session Expired Login/Authenticate Again!');
      } else {
        throw CustomException('Error Occurred');
      }
    } catch (e, s) {
      debugPrint("we got $e $s");
      rethrow;
    }
  }

  Future<http.Response> downloadDoc(ProfilePostData empData,String docID) async {
    try {
      final response = await post(
        ApiConstants.docDownload,
        body: {
          "client_id": empData.clientId,
          "company_id": empData.companyId,
          "employee_id": empData.employeeId,
          "employee_document_id":docID
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
