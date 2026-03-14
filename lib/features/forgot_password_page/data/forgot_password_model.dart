
import 'dart:convert';

SendMailResponse sendMailResponseFromJson(String str) => SendMailResponse.fromJson(json.decode(str));

String sendMailResponseToJson(SendMailResponse data) => json.encode(data.toJson());

class SendMailResponse {
  bool success;
  String message;
  int statusCode;
  List<dynamic> data;

  SendMailResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory SendMailResponse.fromJson(Map<String, dynamic> json) => SendMailResponse(
    success: json["success"],
    message: json["message"],
    statusCode: json["status_code"],
    data: json["data"] == null ? [] : List<dynamic>.from(json["data"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "status_code": statusCode,
    "data":  List<dynamic>.from(data.map((x) => x)),
  };
}

// To parse this JSON data, do
//
//     final verifyPasswordPostData = verifyPasswordPostDataFromJson(jsonString);



VerifyPasswordPostData verifyPasswordPostDataFromJson(String str) => VerifyPasswordPostData.fromJson(json.decode(str));

String verifyPasswordPostDataToJson(VerifyPasswordPostData data) => json.encode(data.toJson());

class VerifyPasswordPostData {
  String? email;
  String? password;
  String? confirmPassword;
  String? otp;

  VerifyPasswordPostData({
    this.email,
    this.password,
    this.confirmPassword,
    this.otp,
  });

  factory VerifyPasswordPostData.fromJson(Map<String, dynamic> json) => VerifyPasswordPostData(
    email: json["email"],
    password: json["password"],
    confirmPassword: json["confirm_password"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
    "confirm_password": confirmPassword,
    "otp": otp,
  };
}

