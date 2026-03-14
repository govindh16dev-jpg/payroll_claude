// To parse this JSON data, do
//
//     final delegateDataResponse = delegateDataResponseFromJson(jsonString);

import 'dart:convert';

DelegateDataResponse delegateDataResponseFromJson(String str) => DelegateDataResponse.fromJson(json.decode(str));

String delegateDataResponseToJson(DelegateDataResponse data) => json.encode(data.toJson());

class DelegateDataResponse {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  DelegateDataResponse({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory DelegateDataResponse.fromJson(Map<String, dynamic> json) => DelegateDataResponse(
    success: json["success"],
    message: json["message"],
    statusCode: json["status_code"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "status_code": statusCode,
    "data": data?.toJson(),
  };
}

class Data {
  List<DelegateData>? leaves;

  Data({
    this.leaves,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    leaves: json["leaves"] == null ? [] : List<DelegateData>.from(json["leaves"]!.map((x) => DelegateData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "leaves": leaves == null ? [] : List<dynamic>.from(leaves!.map((x) => x.toJson())),
  };
}

class DelegateData {
  String? delicateId;
  String? clientId;
  String? companyId;
  String? employeeId;
  String? delicateEmployeeId;
  String? fromDate;
  String? toDate;
  String? employeeNotification;
  String? employeeNo;

  DelegateData({
    this.delicateId,
    this.clientId,
    this.companyId,
    this.employeeId,
    this.delicateEmployeeId,
    this.fromDate,
    this.toDate,
    this.employeeNotification,
    this.employeeNo,
  });

  factory DelegateData.fromJson(Map<String, dynamic> json) => DelegateData(
    delicateId: json["delicate_id"],
    clientId: json["client_id"],
    companyId: json["company_id"],
    employeeId: json["employee_id"],
    delicateEmployeeId: json["delicate_employee_id"],
    fromDate: json["from_date"],
    toDate: json["to_date"],
    employeeNotification: json["employee_notification"],
    employeeNo: json["employee_no"],
  );

  Map<String, dynamic> toJson() => {
    "delicate_id": delicateId,
    "client_id": clientId,
    "company_id": companyId,
    "employee_id": employeeId,
    "delicate_employee_id": delicateEmployeeId,
    "from_date": fromDate,
    "to_date": toDate,
    "employee_notification": employeeNotification,
    "employee_no": employeeNo,
  };
}
