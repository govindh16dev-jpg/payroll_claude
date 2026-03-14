// To parse this JSON data, do
//
//     final applyLeavePostData = applyLeavePostDataFromJson(jsonString);

import 'dart:convert';

ApplyLeavePostData applyLeavePostDataFromJson(String str) => ApplyLeavePostData.fromJson(json.decode(str));

String applyLeavePostDataToJson(ApplyLeavePostData data) => json.encode(data.toJson());

class ApplyLeavePostData {
  int? clientId;
  int? companyId;
  int? employeeId;
  int? leavePlanTypeId;
  DateTime? fromDate;
  DateTime? toDate;
  String? leaveReason;
  List<LeaveDetailApply>? leaveDetails;
  String? attachmentUrl;
  String? expectedDate;
  String? alternativeContactNumber;
  String? noOfDays;
  String? addressToContact;

  ApplyLeavePostData({
    this.clientId,
    this.companyId,
    this.employeeId,
    this.leavePlanTypeId,
    this.fromDate,
    this.toDate,
    this.leaveReason,
    this.leaveDetails,
    this.attachmentUrl,
    this.expectedDate,
    this.alternativeContactNumber,
    this.noOfDays,
    this.addressToContact,
  });

  factory ApplyLeavePostData.fromJson(Map<String, dynamic> json) => ApplyLeavePostData(
    clientId: json["client_id"],
    companyId: json["company_id"],
    employeeId: json["employee_id"],
    leavePlanTypeId: json["leave_plan_type_id"],
    fromDate: json["from_date"] == null ? null : DateTime.parse(json["from_date"]),
    toDate: json["to_date"] == null ? null : DateTime.parse(json["to_date"]),
    leaveReason: json["leave_reason"],
    leaveDetails: json["leave_details"] == null ? [] : List<LeaveDetailApply>.from(json["leave_details"]!.map((x) => LeaveDetailApply.fromJson(x))),
    attachmentUrl: json["attachment_url"],
    expectedDate: json["expected_date"],
    alternativeContactNumber: json["alternative_contact_number"],
    noOfDays: json["no_of_days"],
    addressToContact: json["address_to_contact"],
  );

  Map<String, dynamic> toJson() => {
    "client_id": clientId,
    "company_id": companyId,
    "employee_id": employeeId,
    "leave_plan_type_id": leavePlanTypeId,
    "from_date": "${fromDate!.year.toString().padLeft(4, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}",
    "to_date": "${toDate!.year.toString().padLeft(4, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}",
    "leave_reason": leaveReason,
    "leave_details": leaveDetails == null ? [] : List<dynamic>.from(leaveDetails!.map((x) => x.toJson())),
    "attachment_url": attachmentUrl,
    "expected_date": expectedDate,
    "alternative_contact_number": alternativeContactNumber,
    "no_of_days": noOfDays,
    "address_to_contact": addressToContact,
  };
}

class LeaveDetailApply {
  DateTime? date;
  String? leaveDayType;
  String? halfDayType;
  String? startTime;
  String? endTime;

  LeaveDetailApply({
    this.date,
    this.leaveDayType,
    this.halfDayType,
    this.startTime,
    this.endTime,
  });

  factory LeaveDetailApply.fromJson(Map<String, dynamic> json) => LeaveDetailApply(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    leaveDayType: json["leave_day_type"],
    halfDayType: json["half_day_type"],
    startTime: json["start_time"],
    endTime: json["end_time"],
  );

  Map<String, dynamic> toJson() => {
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "leave_day_type": leaveDayType,
    "half_day_type": halfDayType,
    "start_time": startTime,
    "end_time": endTime,
  };
}
