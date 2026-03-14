// To parse this JSON data, do
//
//     final notificationData = notificationDataFromJson(jsonString);

import 'dart:convert';

NotificationData notificationDataFromJson(String str) => NotificationData.fromJson(json.decode(str));

String notificationDataToJson(NotificationData data) => json.encode(data.toJson());

class NotificationData {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  NotificationData({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
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
  List<Notification>? notification;

  Data({
    this.notification,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    notification: json["notification"] == null ? [] : List<Notification>.from(json["notification"]!.map((x) => Notification.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "notification": notification == null ? [] : List<dynamic>.from(notification!.map((x) => x.toJson())),
  };
}

class Notification {
  String? notificationId;
  String? notificationContent;
  String? msgStatus;
  String? section;
  String? menuImageLink;
  String? menuName;
  String? menuLink;
  String? menuKey;
  String? menuId;
  dynamic pageTabId;
  dynamic tabName;
  dynamic tabKey;
  String? roleName;
  String? roleId;
  String? email;
  String? name;
  String? date;
  String? parentMenu;

  Notification({
    this.notificationId,
    this.notificationContent,
    this.msgStatus,
    this.section,
    this.menuImageLink,
    this.menuName,
    this.menuLink,
    this.menuKey,
    this.menuId,
    this.pageTabId,
    this.tabName,
    this.tabKey,
    this.roleName,
    this.roleId,
    this.email,
    this.name,
    this.date,
    this.parentMenu,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    notificationId: json["notification_id"],
    notificationContent: json["notification_content"],
    msgStatus: json["msg_status"],
    section: json["section"],
    menuImageLink: json["menu_image_link"],
    menuName: json["menu_name"],
    menuLink: json["menu_link"],
    menuKey: json["menu_key"],
    menuId: json["menu_id"],
    pageTabId: json["page_tab_id"],
    tabName: json["tab_name"],
    tabKey: json["tab_key"],
    roleName: json["role_name"],
    roleId: json["role_id"],
    email: json["email"],
    name: json["name"],
    date: json["date"],
    parentMenu: json["parent_menu"],
  );

  Map<String, dynamic> toJson() => {
    "notification_id": notificationId,
    "notification_content": notificationContent,
    "msg_status": msgStatus,
    "section": section,
    "menu_image_link": menuImageLink,
    "menu_name": menuName,
    "menu_link": menuLink,
    "menu_key": menuKey,
    "menu_id": menuId,
    "page_tab_id": pageTabId,
    "tab_name": tabName,
    "tab_key": tabKey,
    "role_name": roleName,
    "role_id": roleId,
    "email": email,
    "name": name,
    "date": date,
    "parent_menu": parentMenu,
  };
}
// To parse this JSON data, do
//
//     final notificationDropdown = notificationDropdownFromJson(jsonString);



NotificationDropdown notificationDropdownFromJson(String str) => NotificationDropdown.fromJson(json.decode(str));

String notificationDropdownToJson(NotificationDropdown data) => json.encode(data.toJson());

class NotificationDropdown {
  bool? success;
  String? message;
  int? statusCode;
  NotificationDropdownData? data;

  NotificationDropdown({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory NotificationDropdown.fromJson(Map<String, dynamic> json) => NotificationDropdown(
    success: json["success"],
    message: json["message"],
    statusCode: json["status_code"],
    data: json["data"] == null ? null : NotificationDropdownData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "status_code": statusCode,
    "data": data?.toJson(),
  };
}

class NotificationDropdownData {
  List<Section>? section;
  List<Role>? role;
  List<Count>? count;

  NotificationDropdownData({
    this.section,
    this.role,
    this.count,
  });

  factory NotificationDropdownData.fromJson(Map<String, dynamic> json) => NotificationDropdownData(
    section: json["section"] == null ? [] : List<Section>.from(json["section"]!.map((x) => Section.fromJson(x))),
    role: json["role"] == null ? [] : List<Role>.from(json["role"]!.map((x) => Role.fromJson(x))),
    count: json["count"] == null ? [] : List<Count>.from(json["count"]!.map((x) => Count.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "section": section == null ? [] : List<dynamic>.from(section!.map((x) => x.toJson())),
    "role": role == null ? [] : List<dynamic>.from(role!.map((x) => x.toJson())),
    "count": count == null ? [] : List<dynamic>.from(count!.map((x) => x.toJson())),
  };
}

class Count {
  String? countNotify;

  Count({
    this.countNotify,
  });

  factory Count.fromJson(Map<String, dynamic> json) => Count(
    countNotify: json["count_notify"],
  );

  Map<String, dynamic> toJson() => {
    "count_notify": countNotify,
  };
}

class Role {
  String? roleName;
  String? roleId;

  Role({
    this.roleName,
    this.roleId,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    roleName: json["role_name"],
    roleId: json["role_id"],
  );

  Map<String, dynamic> toJson() => {
    "role_name": roleName,
    "role_id": roleId,
  };
}

class Section {
  String? section;

  Section({
    this.section,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    section: json["section"],
  );

  Map<String, dynamic> toJson() => {
    "section": section,
  };
}
