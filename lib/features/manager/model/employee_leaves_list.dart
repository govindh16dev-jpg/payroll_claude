// To parse this JSON data, do
//
//     final employeeLeavesList = employeeLeavesListFromJson(jsonString);

import 'dart:convert';

EmployeeLeavesList employeeLeavesListFromJson(String str) => EmployeeLeavesList.fromJson(json.decode(str));

String employeeLeavesListToJson(EmployeeLeavesList data) => json.encode(data.toJson());

class EmployeeLeavesList {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  EmployeeLeavesList({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory EmployeeLeavesList.fromJson(Map<String, dynamic> json) => EmployeeLeavesList(
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
  List<LeavesDetail>? leavesDetails;
  List<DelicateStatus>? delicateStatus;
  List<Calendar>? calendar;
  List<LeaveGraph>? leaveGraph;
  List<LeaveHistory>? leaveHistory;
  List<EmployeeHistory>? employeeHistory;

  Data({
    this.leavesDetails,
    this.delicateStatus,
    this.calendar,
    this.leaveGraph,
    this.leaveHistory,
    this.employeeHistory,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    leavesDetails: json["leaves_details"] == null ? [] : List<LeavesDetail>.from(json["leaves_details"]!.map((x) => LeavesDetail.fromJson(x))),
    delicateStatus: json["delicate_status"] == null ? [] : List<DelicateStatus>.from(json["delicate_status"]!.map((x) => DelicateStatus.fromJson(x))),
    calendar: json["calendar"] == null ? [] : List<Calendar>.from(json["calendar"]!.map((x) => Calendar.fromJson(x))),
    leaveGraph: json["leave_graph"] == null ? [] : List<LeaveGraph>.from(json["leave_graph"]!.map((x) => LeaveGraph.fromJson(x))),
    leaveHistory: json["leave_history"] == null ? [] : List<LeaveHistory>.from(json["leave_history"]!.map((x) => LeaveHistory.fromJson(x))),
    employeeHistory: json["employee_history"] == null ? [] : List<EmployeeHistory>.from(json["employee_history"]!.map((x) => EmployeeHistory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "leaves_details": leavesDetails == null ? [] : List<dynamic>.from(leavesDetails!.map((x) => x.toJson())),
    "delicate_status": delicateStatus == null ? [] : List<dynamic>.from(delicateStatus!.map((x) => x.toJson())),
    "calendar": calendar == null ? [] : List<dynamic>.from(calendar!.map((x) => x.toJson())),
    "leave_graph": leaveGraph == null ? [] : List<dynamic>.from(leaveGraph!.map((x) => x.toJson())),
    "leave_history": leaveHistory == null ? [] : List<dynamic>.from(leaveHistory!.map((x) => x.toJson())),
    "employee_history": employeeHistory == null ? [] : List<dynamic>.from(employeeHistory!.map((x) => x.toJson())),
  };
}

class Calendar {
  DateTime? start;
  DateTime? end;
  String? employeeName;
  String? leaveStatus;
  String? employeeCount;

  Calendar({
    this.start,
    this.end,
    this.employeeName,
    this.leaveStatus,
    this.employeeCount,
  });

  factory Calendar.fromJson(Map<String, dynamic> json) => Calendar(
    start: json["start"] == null ? null : DateTime.parse(json["start"]),
    end: json["end"] == null ? null : DateTime.parse(json["end"]),
    employeeName: json["employee_name"],
    leaveStatus: json["leave_status"],
    employeeCount: json["employee_count"],
  );

  Map<String, dynamic> toJson() => {
    "start": "${start!.year.toString().padLeft(4, '0')}-${start!.month.toString().padLeft(2, '0')}-${start!.day.toString().padLeft(2, '0')}",
    "end": "${end!.year.toString().padLeft(4, '0')}-${end!.month.toString().padLeft(2, '0')}-${end!.day.toString().padLeft(2, '0')}",
    "employee_name": employeeName,
    "leave_status": leaveStatus,
    "employee_count": employeeCount,
  };
}

class DelicateStatus {
  String? delegateStatus;

  DelicateStatus({
    this.delegateStatus,
  });

  factory DelicateStatus.fromJson(Map<String, dynamic> json) => DelicateStatus(
    delegateStatus: json["delegate_status"],
  );

  Map<String, dynamic> toJson() => {
    "delegate_status": delegateStatus,
  };
}

class EmployeeHistory {
  String? employeeId;
  String? employeeName;
  String? leavePlanTypeId;
  String? totalLeaveDays;
  String? takenLeaveDays;
  String? leaveApplied;
  String? availableLeaves;
  String? leavePlanTypeName;

  EmployeeHistory({
    this.employeeId,
    this.employeeName,
    this.leavePlanTypeId,
    this.totalLeaveDays,
    this.takenLeaveDays,
    this.leaveApplied,
    this.availableLeaves,
    this.leavePlanTypeName,
  });

  factory EmployeeHistory.fromJson(Map<String, dynamic> json) => EmployeeHistory(
    employeeId: json["employee_id"],
    employeeName: json["employee_name"],
    leavePlanTypeId: json["leave_plan_type_id"],
    totalLeaveDays: json["total_leave_days"],
    takenLeaveDays: json["taken_leave_days"],
    leaveApplied: json["leave_applied"],
    availableLeaves: json["available_leaves"],
    leavePlanTypeName: json["leave_plan_type_name"],
  );

  Map<String, dynamic> toJson() => {
    "employee_id": employeeId,
    "employee_name": employeeName,
    "leave_plan_type_id": leavePlanTypeId,
    "total_leave_days": totalLeaveDays,
    "taken_leave_days": takenLeaveDays,
    "leave_applied": leaveApplied,
    "available_leaves": availableLeaves,
    "leave_plan_type_name": leavePlanTypeName,
  };
}

class LeaveGraph {
  String? dataType;
  String? leavePlanId;
  String? leavePlanTypeId;
  String? leavePlanShort;
  String? leavePlanTypeName;
  String? totalLeaveDays;
  String? takenLeaveDays;
  String? leaveApplied;
  String? availableLeaves;
  String? isGraph;
  String? leaveKey;
  String? considerWeekendLeaves;
  String? considerHolidays;

  LeaveGraph({
    this.dataType,
    this.leavePlanId,
    this.leavePlanTypeId,
    this.leavePlanShort,
    this.leavePlanTypeName,
    this.totalLeaveDays,
    this.takenLeaveDays,
    this.leaveApplied,
    this.availableLeaves,
    this.isGraph,
    this.leaveKey,
    this.considerWeekendLeaves,
    this.considerHolidays,
  });

  factory LeaveGraph.fromJson(Map<String, dynamic> json) => LeaveGraph(
    dataType: json["data_type"],
    leavePlanId: json["leave_plan_id"],
    leavePlanTypeId: json["leave_plan_type_id"],
    leavePlanShort: json["leave_plan_short"],
    leavePlanTypeName: json["leave_plan_type_name"],
    totalLeaveDays: json["total_leave_days"],
    takenLeaveDays: json["taken_leave_days"],
    leaveApplied: json["leave_applied"],
    availableLeaves: json["available_leaves"],
    isGraph: json["is_graph"],
    leaveKey: json["leave_key"],
    considerWeekendLeaves: json["consider_weekend_leaves"],
    considerHolidays: json["consider_holidays"],
  );

  Map<String, dynamic> toJson() => {
    "data_type": dataType,
    "leave_plan_id": leavePlanId,
    "leave_plan_type_id": leavePlanTypeId,
    "leave_plan_short": leavePlanShort,
    "leave_plan_type_name": leavePlanTypeName,
    "total_leave_days": totalLeaveDays,
    "taken_leave_days": takenLeaveDays,
    "leave_applied": leaveApplied,
    "available_leaves": availableLeaves,
    "is_graph": isGraph,
    "leave_key": leaveKey,
    "consider_weekend_leaves": considerWeekendLeaves,
    "consider_holidays": considerHolidays,
  };
}

class LeaveHistory {
  String? employeeId;
  String? employeeName;
  String? totalLeaveDays;
  String? takenDays;
  String? balanceDays;

  LeaveHistory({
    this.employeeId,
    this.employeeName,
    this.totalLeaveDays,
    this.takenDays,
    this.balanceDays,
  });

  factory LeaveHistory.fromJson(Map<String, dynamic> json) => LeaveHistory(
    employeeId: json["employee_id"],
    employeeName: json["employee_name"],
    totalLeaveDays: json["total_leave_days"],
    takenDays: json["taken_days"],
    balanceDays: json["balance_days"],
  );

  Map<String, dynamic> toJson() => {
    "employee_id": employeeId,
    "employee_name": employeeName,
    "total_leave_days": totalLeaveDays,
    "taken_days": takenDays,
    "balance_days": balanceDays,
  };
}

class LeavesDetail {
  String? sno;
  String? employeeLeaveId;
  String? employeeId;
  String? leavePlanTypeId;
  String? planTypeName;
  String? clientId;
  String? companyId;
  String? leavePlanId;
  String? employeeNo;
  String? employeeName;
  DateTime? toDate;
  DateTime? fromDate;
  String? approvedBy;
  String? noOfDays;
  String? leaveReason;
  String? leaveStatus;
  String? leaveActionReason;
  dynamic reasonForCancel;
  DateTime? createdAt;
  dynamic addressToContact;
  String? leaveDate;
  String? createdDate;
  String? approvedDate;
  String? delegateStatus;
  String? fromDateFormat;
  String? toDateFormat;

  LeavesDetail({
    this.sno,
    this.employeeLeaveId,
    this.employeeId,
    this.leavePlanTypeId,
    this.planTypeName,
    this.clientId,
    this.companyId,
    this.leavePlanId,
    this.employeeNo,
    this.employeeName,
    this.toDate,
    this.fromDate,
    this.approvedBy,
    this.noOfDays,
    this.leaveReason,
    this.leaveStatus,
    this.leaveActionReason,
    this.reasonForCancel,
    this.createdAt,
    this.addressToContact,
    this.leaveDate,
    this.createdDate,
    this.approvedDate,
    this.delegateStatus,
    this.fromDateFormat,
    this.toDateFormat,
  });

  factory LeavesDetail.fromJson(Map<String, dynamic> json) => LeavesDetail(
    sno: json["sno"],
    employeeLeaveId: json["employee_leave_id"],
    employeeId: json["employee_id"],
    leavePlanTypeId: json["leave_plan_type_id"],
    planTypeName: json["plan_type_name"],
    clientId: json["client_id"],
    companyId: json["company_id"],
    leavePlanId: json["leave_plan_id"],
    employeeNo: json["employee_no"],
    employeeName: json["employee_name"],
    toDate: json["to_date"] == null ? null : DateTime.parse(json["to_date"]),
    fromDate: json["from_date"] == null ? null : DateTime.parse(json["from_date"]),
    approvedBy: json["approved_by"],
    noOfDays: json["no_of_days"],
    leaveReason: json["leave_reason"],
    leaveStatus: json["leave_status"],
    leaveActionReason: json["leave_action_reason"],
    reasonForCancel: json["reason_for_cancel"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    addressToContact: json["address_to_contact"],
    leaveDate: json["leave_date"],
    createdDate: json["created_date"],
    approvedDate: json["approved_date"],
    delegateStatus: json["delegate_status"],
    fromDateFormat: json["from_date_format"],
    toDateFormat: json["to_date_format"],
  );

  Map<String, dynamic> toJson() => {
    "sno": sno,
    "employee_leave_id": employeeLeaveId,
    "employee_id": employeeId,
    "leave_plan_type_id": leavePlanTypeId,
    "plan_type_name": planTypeName,
    "client_id": clientId,
    "company_id": companyId,
    "leave_plan_id": leavePlanId,
    "employee_no": employeeNo,
    "employee_name": employeeName,
    "to_date": "${toDate!.year.toString().padLeft(4, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}",
    "from_date": "${fromDate!.year.toString().padLeft(4, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}",
    "approved_by": approvedBy,
    "no_of_days": noOfDays,
    "leave_reason": leaveReason,
    "leave_status": leaveStatus,
    "leave_action_reason": leaveActionReason,
    "reason_for_cancel": reasonForCancel,
    "created_at": "${createdAt!.year.toString().padLeft(4, '0')}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}",
    "address_to_contact": addressToContact,
    "leave_date": leaveDate,
    "created_date": createdDate,
    "approved_date": approvedDate,
    "delegate_status": delegateStatus,
    "from_date_format": fromDateFormat,
    "to_date_format": toDateFormat,
  };
}
