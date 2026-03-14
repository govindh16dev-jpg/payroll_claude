// To parse this JSON data, do
//
//     final leaveActionPostData = leaveActionPostDataFromJson(jsonString);

import 'dart:convert';

LeaveActionPostData leaveActionPostDataFromJson(String str) => LeaveActionPostData.fromJson(json.decode(str));

String leaveActionPostDataToJson(LeaveActionPostData data) => json.encode(data.toJson());

class LeaveActionPostData {
  String? clientId;
  String? companyId;
  int? employeeId;
  String? actionFlag;
  int? employeeLeaveId;
  int? leavePlanTypeId;
  int? requestEmployeeId;
  String? noOfDays;
  String? leaveActionReason;

  LeaveActionPostData({
    this.clientId,
    this.companyId,
    this.employeeId,
    this.actionFlag,
    this.employeeLeaveId,
    this.leavePlanTypeId,
    this.requestEmployeeId,
    this.noOfDays,
    this.leaveActionReason,
  });

  factory LeaveActionPostData.fromJson(Map<String, dynamic> json) => LeaveActionPostData(
    clientId: json["client_id"],
    companyId: json["company_id"],
    employeeId: json["employee_id"],
    actionFlag: json["action_flag"],
    employeeLeaveId: json["employee_leave_id"],
    leavePlanTypeId: json["leave_plan_type_id"],
    requestEmployeeId: json["request_employee_id"],
    noOfDays: json["no_of_days"],
    leaveActionReason: json["leave_action_reason"],
  );

  Map<String, dynamic> toJson() => {
    "client_id": clientId,
    "company_id": companyId,
    "employee_id": employeeId,
    "action_flag": actionFlag,
    "employee_leave_id": employeeLeaveId,
    "leave_plan_type_id": leavePlanTypeId,
    "request_employee_id": requestEmployeeId,
    "no_of_days": noOfDays,
    "leave_action_reason": leaveActionReason,
  };
}
