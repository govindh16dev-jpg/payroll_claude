// To parse this JSON data, do
//
//     final checkDelegate = checkDelegateFromJson(jsonString);

import 'dart:convert';

CheckDelegate checkDelegateFromJson(String str) => CheckDelegate.fromJson(json.decode(str));

String checkDelegateToJson(CheckDelegate data) => json.encode(data.toJson());

class CheckDelegate {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  CheckDelegate({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory CheckDelegate.fromJson(Map<String, dynamic> json) => CheckDelegate(
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
  List<Leaf>? leaves;

  Data({
    this.leaves,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    leaves: json["leaves"] == null ? [] : List<Leaf>.from(json["leaves"]!.map((x) => Leaf.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "leaves": leaves == null ? [] : List<dynamic>.from(leaves!.map((x) => x.toJson())),
  };
}

class Leaf {
  String? delicateId;

  Leaf({
    this.delicateId,
  });

  factory Leaf.fromJson(Map<String, dynamic> json) => Leaf(
    delicateId: json["delicate_id"],
  );

  Map<String, dynamic> toJson() => {
    "delicate_id": delicateId,
  };
}
