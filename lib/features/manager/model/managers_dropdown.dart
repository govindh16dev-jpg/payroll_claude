
// To parse this JSON data, do
//
//     final managersDropDown = managersDropDownFromJson(jsonString);

import 'dart:convert';

ManagersDropDown managersDropDownFromJson(String str) => ManagersDropDown.fromJson(json.decode(str));

String managersDropDownToJson(ManagersDropDown data) => json.encode(data.toJson());

class ManagersDropDown {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  ManagersDropDown({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory ManagersDropDown.fromJson(Map<String, dynamic> json) => ManagersDropDown(
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
  List<ManagerData>? leaves;

  Data({
    this.leaves,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    leaves: json["leaves"] == null ? [] : List<ManagerData>.from(json["leaves"]!.map((x) => ManagerData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "leaves": leaves == null ? [] : List<dynamic>.from(leaves!.map((x) => x.toJson())),
  };
}

class ManagerData {
  String? dropDownId;
  String? employeeId;
  String? employeeName;
  String? employeeNo;

  ManagerData({
    this.dropDownId,
    this.employeeId,
    this.employeeName,
    this.employeeNo,
  });

  factory ManagerData.fromJson(Map<String, dynamic> json) => ManagerData(
    dropDownId: json["drop_down_id"],
    employeeId: json["employee_id"],
    employeeName: json["employee_name"],
    employeeNo: json["employee_no"],
  );

  Map<String, dynamic> toJson() => {
    "drop_down_id": dropDownId,
    "employee_id": employeeId,
    "employee_name": employeeName,
    "employee_no": employeeNo,
  };
}
