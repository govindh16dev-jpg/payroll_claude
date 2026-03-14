// To parse this JSON data, do
//
//     final bannerData = bannerDataFromJson(jsonString);



// To parse this JSON data, do
//
//     final bannerData = bannerDataFromJson(jsonString);

import 'dart:convert';

BannerData bannerDataFromJson(String str) => BannerData.fromJson(json.decode(str));

String bannerDataToJson(BannerData data) => json.encode(data.toJson());

class BannerData {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  BannerData({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) => BannerData(
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
  List<Banner>? banners;
  List<LeaveRecod>? leaveRecods;

  Data({
    this.banners,
    this.leaveRecods,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    banners: json["banners"] == null ? [] : List<Banner>.from(json["banners"]!.map((x) => Banner.fromJson(x))),
    leaveRecods: json["leave_recods"] == null ? [] : List<LeaveRecod>.from(json["leave_recods"]!.map((x) => LeaveRecod.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "banners": banners == null ? [] : List<dynamic>.from(banners!.map((x) => x.toJson())),
    "leave_recods": leaveRecods == null ? [] : List<dynamic>.from(leaveRecods!.map((x) => x.toJson())),
  };
}

class Banner {
  String? employeeNo;
  String? employeeName;
  String? gender;
  String? bankName;
  String? accountNumber;
  String? noOfDays;
  dynamic lopReversalMonth;
  dynamic lopRecoveryMonth;
  String? noOfDaysWorked;
  String? noOfLopDays;
  String? lopReversal;
  String? lopRecovery;
  dynamic taxRegime;
  String? ctc;
  String? payMothYear;
  String? currentMonthNetPay;
  String? netPayPercentageDiff;
  String? currencySymbol;
  String? remainingMonths;
  String? totalTaxLiability;
  String? taxPaidTillNow;
  String? balanceTax;
  String? monthlyTaxPayable;
  String? upComingHoliday;

  Banner({
    this.employeeNo,
    this.employeeName,
    this.gender,
    this.bankName,
    this.accountNumber,
    this.noOfDays,
    this.lopReversalMonth,
    this.lopRecoveryMonth,
    this.noOfDaysWorked,
    this.noOfLopDays,
    this.lopReversal,
    this.lopRecovery,
    this.taxRegime,
    this.ctc,
    this.payMothYear,
    this.currentMonthNetPay,
    this.netPayPercentageDiff,
    this.currencySymbol,
    this.remainingMonths,
    this.totalTaxLiability,
    this.taxPaidTillNow,
    this.balanceTax,
    this.monthlyTaxPayable,
    this.upComingHoliday,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
    employeeNo: json["employee_no"],
    employeeName: json["employee_name"],
    gender: json["gender"],
    bankName: json["bank_name"],
    accountNumber: json["account_number"],
    noOfDays: json["no_of_days"],
    lopReversalMonth: json["lop_reversal_month"],
    lopRecoveryMonth: json["lop_recovery_month"],
    noOfDaysWorked: json["no_of_days_worked"],
    noOfLopDays: json["no_of_lop_days"],
    lopReversal: json["lop_reversal"],
    lopRecovery: json["lop_recovery"],
    taxRegime: json["tax_regime"],
    ctc: json["ctc"],
    payMothYear: json["pay_moth_year"],
    currentMonthNetPay: json["current_month_net_pay"],
    netPayPercentageDiff: json["net_pay_percentage_diff"],
    currencySymbol: json["currency_symbol"],
    remainingMonths: json["remaining_months"],
    totalTaxLiability: json["total_tax_liability"],
    taxPaidTillNow: json["tax_paid_till_now"],
    balanceTax: json["balance_tax"],
    monthlyTaxPayable: json["monthly_tax_payable"],
    upComingHoliday: json["up_coming_holiday"],
  );

  Map<String, dynamic> toJson() => {
    "employee_no": employeeNo,
    "employee_name": employeeName,
    "gender": gender,
    "bank_name": bankName,
    "account_number": accountNumber,
    "no_of_days": noOfDays,
    "lop_reversal_month": lopReversalMonth,
    "lop_recovery_month": lopRecoveryMonth,
    "no_of_days_worked": noOfDaysWorked,
    "no_of_lop_days": noOfLopDays,
    "lop_reversal": lopReversal,
    "lop_recovery": lopRecovery,
    "tax_regime": taxRegime,
    "ctc": ctc,
    "pay_moth_year": payMothYear,
    "current_month_net_pay": currentMonthNetPay,
    "net_pay_percentage_diff": netPayPercentageDiff,
    "currency_symbol": currencySymbol,
    "remaining_months": remainingMonths,
    "total_tax_liability": totalTaxLiability,
    "tax_paid_till_now": taxPaidTillNow,
    "balance_tax": balanceTax,
    "monthly_tax_payable": monthlyTaxPayable,
    "up_coming_holiday": upComingHoliday,
  };
}

class LeaveRecod {
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

  LeaveRecod({
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

  factory LeaveRecod.fromJson(Map<String, dynamic> json) => LeaveRecod(
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


// To parse this JSON data, do
//
//     final menuData = menuDataFromJson(jsonString);

MenuData menuDataFromJson(String str) => MenuData.fromJson(json.decode(str));

String menuDataToJson(MenuData data) => json.encode(data.toJson());

class MenuData {
  bool? success;
  String? message;
  int? statusCode;
  Menus? data;

  MenuData({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory MenuData.fromJson(Map<String, dynamic> json) => MenuData(
    success: json["success"],
    message: json["message"],
    statusCode: json["status_code"],
    data: json["data"] == null ? null : Menus.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "status_code": statusCode,
    "data": data?.toJson(),
  };
}

class Menus {
  List<Map<String, String?>>? menu;

  Menus({
    this.menu,
  });

  factory Menus.fromJson(Map<String, dynamic> json) => Menus(
    menu: json["menu"] == null ? [] : List<Map<String, String?>>.from(json["menu"]!.map((x) => Map.from(x).map((k, v) => MapEntry<String, String?>(k, v)))),
  );

  Map<String, dynamic> toJson() => {
    "menu": menu == null ? [] : List<dynamic>.from(menu!.map((x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v)))),
  };
}
