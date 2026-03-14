// To parse this JSON data, do
//
//     final applyLeavePostData = applyLeavePostDataFromJson(jsonString);

import 'dart:convert';
// To parse this JSON data, do
//
//     final validateLeaveResponse = validateLeaveResponseFromJson(jsonString);
ValidateLeaveResponse validateLeaveResponseFromJson(String str) => ValidateLeaveResponse.fromJson(json.decode(str));

String validateLeaveResponseToJson(ValidateLeaveResponse data) => json.encode(data.toJson());

class ValidateLeaveResponse {
  bool? success;
  String? message;
  int? statusCode;
  List<Datum>? data;

  ValidateLeaveResponse({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory ValidateLeaveResponse.fromJson(Map<String, dynamic> json) => ValidateLeaveResponse(
    success: json["success"],
    message: json["message"],
    statusCode: json["status_code"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "status_code": statusCode,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? errorMsg;

  Datum({
    this.errorMsg,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    errorMsg: json["error_msg"],
  );

  Map<String, dynamic> toJson() => {
    "error_msg": errorMsg,
  };
}

// To parse this JSON data, do
//
//     final leaveType = leaveTypeFromJson(jsonString);

LeaveType leaveTypeFromJson(String str) => LeaveType.fromJson(json.decode(str));

String leaveTypeToJson(LeaveType data) => json.encode(data.toJson());

class LeaveType {
  String? leaveName;
  String? leavePlanTypeId;
  String? remainingLeaves;

  LeaveType({
    this.leaveName,
    this.leavePlanTypeId,
    this.remainingLeaves,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) => LeaveType(
    leaveName: json["leave_name"],
    leavePlanTypeId: json["leave_plan_type_id"],
    remainingLeaves: json["remaining_leaves"],
  );

  Map<String, dynamic> toJson() => {
    "leave_name": leaveName,
    "leave_plan_type_id": leavePlanTypeId,
    "remaining_leaves": remainingLeaves,
  };
}

 


// To parse this JSON data, do
//
//     final leaveData = leaveDataFromJson(jsonString);

LeaveData leaveDataFromJson(String str) => LeaveData.fromJson(json.decode(str));

String leaveDataToJson(LeaveData data) => json.encode(data.toJson());

class LeaveData {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  LeaveData({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) => LeaveData(
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
  List<LeaveDetail>? leaveDetails;
  List<WeekEnd>? weekEnds;
  List<Holiday>? holidays;
  List<DayTypeDropdown>? dayTypeDropdown;
  List<Map<String, String?>>? leaveHistory;
  List<Map<String, String?>>? calenderView;

  Data({
    this.leaveDetails,
    this.weekEnds,
    this.holidays,
    this.dayTypeDropdown,
    this.leaveHistory,
    this.calenderView,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    leaveDetails: json["leave_details"] == null ? [] : List<LeaveDetail>.from(json["leave_details"]!.map((x) => LeaveDetail.fromJson(x))),
    weekEnds: json["week_ends"] == null ? [] : List<WeekEnd>.from(json["week_ends"]!.map((x) => WeekEnd.fromJson(x))),
    holidays: json["holidays"] == null ? [] : List<Holiday>.from(json["holidays"]!.map((x) => Holiday.fromJson(x))),
    dayTypeDropdown: json["day_type_dropdown"] == null ? [] : List<DayTypeDropdown>.from(json["day_type_dropdown"]!.map((x) => DayTypeDropdown.fromJson(x))),
    leaveHistory: json["leave_history"] == null ? [] : List<Map<String, String?>>.from(json["leave_history"]!.map((x) => Map.from(x).map((k, v) => MapEntry<String, String?>(k, v)))),
    calenderView: json["calender_view"] == null ? [] : List<Map<String, String?>>.from(json["calender_view"]!.map((x) => Map.from(x).map((k, v) => MapEntry<String, String?>(k, v)))),
  );

  Map<String, dynamic> toJson() => {
    "leave_details": leaveDetails == null ? [] : List<dynamic>.from(leaveDetails!.map((x) => x.toJson())),
    "week_ends": weekEnds == null ? [] : List<dynamic>.from(weekEnds!.map((x) => x.toJson())),
    "holidays": holidays == null ? [] : List<dynamic>.from(holidays!.map((x) => x.toJson())),
    "day_type_dropdown": dayTypeDropdown == null ? [] : List<dynamic>.from(dayTypeDropdown!.map((x) => x.toJson())),
    "leave_history": leaveHistory == null ? [] : List<dynamic>.from(leaveHistory!.map((x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v)))),
    "calender_view": calenderView == null ? [] : List<dynamic>.from(calenderView!.map((x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v)))),
  };
}

class DayTypeDropdown {
  String? dataType;
  String? leaveDayType;
  String? leaveLabel;

  DayTypeDropdown({
    this.dataType,
    this.leaveDayType,
    this.leaveLabel,
  });

  factory DayTypeDropdown.fromJson(Map<String, dynamic> json) => DayTypeDropdown(
    dataType: json["data_type"],
    leaveDayType: json["leave_day_type"],
    leaveLabel: json["leave_label"],
  );

  Map<String, dynamic> toJson() => {
    "data_type": dataType,
    "leave_day_type": leaveDayType,
    "leave_label": leaveLabel,
  };
}

class Holiday {
  String? holidayName;
  DateTime? holidayDate;
  DateTime? toDate;
  String? monthName;
  String? extractedDay;
  String? dayOfWeek;
  String? status;
  bool? isLeave;
  Type? type;

  Holiday({
    this.holidayName,
    this.holidayDate,
    this.monthName,
    this.extractedDay,
    this.dayOfWeek,
    this.type,
    this.isLeave,
    this.status,
    this.toDate
  });

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(
    holidayName: json["holiday_name"],
    holidayDate: json["holiday_date"] == null ? null : DateTime.parse(json["holiday_date"]),
    monthName: json["month_name"],
    extractedDay: json["ExtractedDay"],
    dayOfWeek: json["DayOfWeek"],
    type: typeValues.map[json["type"]]!,
  );

  Map<String, dynamic> toJson() => {
    "holiday_name": holidayName,
    "holiday_date": "${holidayDate!.year.toString().padLeft(4, '0')}-${holidayDate!.month.toString().padLeft(2, '0')}-${holidayDate!.day.toString().padLeft(2, '0')}",
    "month_name": monthName,
    "ExtractedDay": extractedDay,
    "DayOfWeek": dayOfWeek,
    "type": typeValues.reverse[type],
  };
}

enum Type {
  MANDATORY
}

final typeValues = EnumValues({
  "mandatory": Type.MANDATORY
});

class LeaveDetail {
  String? dataType;
  String? leavePlanId;
  String? leavePlanTypeId;
  String? leavePlanShort;
  String? leavePlanTypeName;
  dynamic sequenceOrderLeavePlan;
  String? totalLeaveDays;
  String? takenLeaveDays;
  String? leaveApplied;
  String? availableLeaves;
  String? isGraph;
  String? isCard;
  String? leaveKey;
  String? considerWeekendLeaves;
  String? considerHolidays;

  LeaveDetail({
    this.dataType,
    this.leavePlanId,
    this.leavePlanTypeId,
    this.leavePlanShort,
    this.leavePlanTypeName,
    this.sequenceOrderLeavePlan,
    this.totalLeaveDays,
    this.takenLeaveDays,
    this.leaveApplied,
    this.availableLeaves,
    this.isGraph,
    this.isCard,
    this.leaveKey,
    this.considerWeekendLeaves,
    this.considerHolidays,
  });

  factory LeaveDetail.fromJson(Map<String, dynamic> json) => LeaveDetail(
    dataType: json["data_type"],
    leavePlanId: json["leave_plan_id"],
    leavePlanTypeId: json["leave_plan_type_id"],
    leavePlanShort: json["leave_plan_short"],
    leavePlanTypeName: json["leave_plan_type_name"],
    sequenceOrderLeavePlan: json["sequence_order_leave_plan"],
    totalLeaveDays: json["total_leave_days"],
    takenLeaveDays: json["taken_leave_days"],
    leaveApplied: json["leave_applied"],
    availableLeaves: json["available_leaves"],
    isGraph: json["is_graph"],
    isCard: json["is_card"],
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
    "sequence_order_leave_plan": sequenceOrderLeavePlan,
    "total_leave_days": totalLeaveDays,
    "taken_leave_days": takenLeaveDays,
    "leave_applied": leaveApplied,
    "available_leaves": availableLeaves,
    "is_graph": isGraph,
    "is_card": isCard,
    "leave_key": leaveKey,
    "consider_weekend_leaves": considerWeekendLeaves,
    "consider_holidays": considerHolidays,
  };
}

class WeekEnd {
  String? dataType;
  String? dayName;

  WeekEnd({
    this.dataType,
    this.dayName,
  });

  factory WeekEnd.fromJson(Map<String, dynamic> json) => WeekEnd(
    dataType: json["data_type"],
    dayName: json["day_name"],
  );

  Map<String, dynamic> toJson() => {
    "data_type": dataType,
    "day_name": dayName,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

