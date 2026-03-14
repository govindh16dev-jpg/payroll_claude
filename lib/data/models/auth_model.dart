// // To parse this JSON data, do
// //
// //     final welcome = welcomeFromJson(jsonString);
//
// import 'dart:convert';
//
// LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));
//
// String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());
//
// class LoginResponse {
//     bool success;
//     UserData data;
//
//     LoginResponse({
//         required this.success,
//         required this.data,
//     });
//
//     factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
//         success: json["success"],
//         data: UserData.fromJson(json["data"]),
//     );
//
//     Map<String, dynamic> toJson() => {
//         "success": success,
//         "data": data.toJson(),
//     };
// }
//
// class UserData {
//     User user;
//     String token;
//
//     UserData({
//         required this.user,
//         required this.token,
//     });
//
//     factory UserData.fromJson(Map<String, dynamic> json) => UserData(
//         user: User.fromJson(json["user"]),
//         token: json["token"],
//     );
//
//     Map<String, dynamic> toJson() => {
//         "user": user.toJson(),
//         "token": token,
//     };
// }
//
// class User {
//     int id;
//     String name;
//     String email;
//     dynamic emailVerifiedAt;
//     DateTime createdAt;
//     DateTime updatedAt;
//     String recordStatus;
//     String clientId;
//     String createdBy;
//     String updatedBy;
//     String userType;
//     String avatar;
//     String messengerColor;
//     String darkMode;
//     String activeStatus;
//     String isFirstLogin;
//     String companyId;
//     String employeeId;
//
//     User({
//         required this.id,
//         required this.name,
//         required this.email,
//         required this.emailVerifiedAt,
//         required this.createdAt,
//         required this.updatedAt,
//         required this.recordStatus,
//         required this.clientId,
//         required this.createdBy,
//         required this.updatedBy,
//         required this.userType,
//         required this.avatar,
//         required this.messengerColor,
//         required this.darkMode,
//         required this.activeStatus,
//         required this.isFirstLogin,
//         required this.companyId,
//         required this.employeeId,
//     });
//
//     factory User.fromJson(Map<String, dynamic> json) => User(
//         id: json["id"],
//         name: json["name"],
//         email: json["email"],
//         emailVerifiedAt: json["email_verified_at"],
//         createdAt: DateTime.parse(json["created_at"]),
//         updatedAt: DateTime.parse(json["updated_at"]),
//         recordStatus: json["record_status"],
//         clientId: json["client_id"],
//         createdBy: json["created_by"],
//         updatedBy: json["updated_by"],
//         userType: json["user_type"],
//         avatar: json["avatar"],
//         messengerColor: json["messenger_color"],
//         darkMode: json["dark_mode"],
//         activeStatus: json["active_status"],
//         isFirstLogin: json["is_first_login"],
//         companyId: json["company_id"],
//         employeeId: json["employee_id"],
//     );
//
//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "email": email,
//         "email_verified_at": emailVerifiedAt,
//         "created_at": createdAt.toIso8601String(),
//         "updated_at": updatedAt.toIso8601String(),
//         "record_status": recordStatus,
//         "client_id": clientId,
//         "created_by": createdBy,
//         "updated_by": updatedBy,
//         "user_type": userType,
//         "avatar": avatar,
//         "messenger_color": messengerColor,
//         "dark_mode": darkMode,
//         "active_status": activeStatus,
//         "is_first_login": isFirstLogin,
//         "company_id": companyId,
//         "employee_id": employeeId,
//     };
// }
