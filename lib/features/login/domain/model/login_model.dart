import 'dart:convert';

class LoginPostData {
  String? email;
  String? password;

  LoginPostData({this.email, this.password});
}

class LoginCredentials {
  final String email;
  final String password;

  LoginCredentials({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };

  factory LoginCredentials.fromJson(Map<String, dynamic> json) => LoginCredentials(
    email: json['email'] ?? '',
    password: json['password'] ?? '',
  );

  @override
  String toString() => 'LoginCredentials(email: $email, password: $password)';
}

// JSON helpers
String loginCredentialsToJson(LoginCredentials data) => json.encode(data.toJson());

LoginCredentials loginCredentialsFromJson(String str) =>
    LoginCredentials.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());
UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  bool success;
  String message;
  int statusCode;
  UserData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json["success"],
    message: json["message"],
    statusCode: json["status_code"],
    data: UserData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "status_code": statusCode,
    "data": data.toJson(),
  };
}

class UserData {
  String? tokenType;
  int? expiresIn;
  String? accessToken;
  String? refreshToken;
  User? user;

  UserData({
    this.tokenType,
    this.expiresIn,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    tokenType: json["token_type"],
    expiresIn: _parseExpiresIn(json["expires_in"]),
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  // Helper method to parse expires_in safely
  static int? _parseExpiresIn(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    "token_type": tokenType,
    "expires_in": expiresIn,
    "access_token": accessToken,
    "refresh_token": refreshToken,
    "user": user?.toJson(),
  };
}

class User {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? recordStatus;
  String? clientId;
  String? createdBy;
  String? updatedBy;
  String? userType;
  String? avatar;
  String? messengerColor;
  String? darkMode;
  String? activeStatus;
  String? isFirstLogin;
  String? fcmToken;
  dynamic appUpdateRefresh;
  String? lastLoginAt;
  String? lastLoginIp;
  String? lastLoginUserAgent;
  String? companyId;
  String? employeeId;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.recordStatus,
    this.clientId,
    this.createdBy,
    this.updatedBy,
    this.userType,
    this.avatar,
    this.messengerColor,
    this.darkMode,
    this.activeStatus,
    this.isFirstLogin,
    this.fcmToken,
    this.appUpdateRefresh,
    this.lastLoginAt,
    this.lastLoginIp,
    this.lastLoginUserAgent,
    this.companyId,
    this.employeeId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    recordStatus: json["record_status"],
    clientId: json["client_id"],
    createdBy: json["created_by"],
    updatedBy: json["updated_by"],
    userType: json["user_type"],
    avatar: json["avatar"],
    messengerColor: json["messenger_color"],
    darkMode: json["dark_mode"],
    activeStatus: json["active_status"],
    isFirstLogin: json["is_first_login"],
    fcmToken: json["fcm_token"],
    appUpdateRefresh: json["app_update_refresh"],
    lastLoginAt: json["last_login_at"],
    lastLoginIp: json["last_login_ip"],
    lastLoginUserAgent: json["last_login_user_agent"],
    companyId: json["company_id"],
    employeeId: json["employee_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "record_status": recordStatus,
    "client_id": clientId,
    "created_by": createdBy,
    "updated_by": updatedBy,
    "user_type": userType,
    "avatar": avatar,
    "messenger_color": messengerColor,
    "dark_mode": darkMode,
    "active_status": activeStatus,
    "is_first_login": isFirstLogin,
    "fcm_token": fcmToken,
    "app_update_refresh": appUpdateRefresh,
    "last_login_at": lastLoginAt,
    "last_login_ip": lastLoginIp,
    "last_login_user_agent": lastLoginUserAgent,
    "company_id": companyId,
    "employee_id": employeeId,
  };
}

DeleteUserRes deleteUserResFromJson(String str) =>
    DeleteUserRes.fromJson(json.decode(str));

String deleteUserResToJson(DeleteUserRes data) =>
    json.encode(data.toJson());

class DeleteUserRes {
  final bool success;
  final String message;
  final int statusCode;
  final List<dynamic> data;

  DeleteUserRes({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory DeleteUserRes.fromJson(Map<String, dynamic> json) {
    return DeleteUserRes(
      success: json['success'] as bool,
      message: json['message'] as String,
      statusCode: json['status_code'] as int,
      data: json['data'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status_code': statusCode,
      'data': data,
    };
  }
}
