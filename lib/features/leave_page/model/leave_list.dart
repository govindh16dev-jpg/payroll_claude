// To parse this JSON data, do
//
//     final leaveListData = leaveListDataFromJson(jsonString);

import 'dart:convert';

LeaveListData leaveListDataFromJson(String str) =>
    LeaveListData.fromJson(json.decode(str));

String leaveListDataToJson(LeaveListData data) => json.encode(data.toJson());

class LeaveListData {
  bool? success;
  String? message;
  LeaveList? data;

  LeaveListData({
    this.success,
    this.message,
    this.data,
  });

  factory LeaveListData.fromJson(Map<String, dynamic> json) => LeaveListData(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : LeaveList.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class LeaveList {
  List<List<Map<String, String?>>>? leaves;

  LeaveList({
    this.leaves,
  });

  factory LeaveList.fromJson(Map<String, dynamic> json) => LeaveList(
        leaves: json["leaves"] == null
            ? []
            : List<List<Map<String, String?>>>.from(json["leaves"]!.map((x) =>
                List<Map<String, String?>>.from(x.map((x) => Map.from(x)
                    .map((k, v) => MapEntry<String, String?>(k, v)))))),
      );

  Map<String, dynamic> toJson() => {
        "leaves": leaves == null
            ? []
            : List<dynamic>.from(leaves!.map((x) => List<dynamic>.from(x.map(
                (x) => Map.from(x)
                    .map((k, v) => MapEntry<String, dynamic>(k, v)))))),
      };
}
