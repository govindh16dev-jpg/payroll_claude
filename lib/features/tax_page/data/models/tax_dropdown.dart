import 'dart:convert';

class TaxTotals {
  String? totalGrossSalary;
  String? totalTaxIncome;
  String? totalTaxPayable;
  String? taxPaidTillNow;
  String? balanceTax;
  String? monthlyTaxPaid;

  TaxTotals({
    this.totalGrossSalary,
    this.totalTaxIncome,
    this.totalTaxPayable,
    this.taxPaidTillNow,
    this.balanceTax,
    this.monthlyTaxPaid,
  });
}

class TaxCardData {
  final String? taxLiability;
  final String? taxPaid;
  final String? balanceTax;
  final String? remainingMonths;
  final String? monthlyTax;
  TaxCardData({
      this.taxLiability,
      this.taxPaid,
      this.balanceTax,
      this.remainingMonths,
      this.monthlyTax
  });
}

// To parse this JSON data, do
//
//     final taxDropdownData = taxDropdownDataFromJson(jsonString);



TaxDropdownData taxDropdownDataFromJson(String str) => TaxDropdownData.fromJson(json.decode(str));

String taxDropdownDataToJson(TaxDropdownData data) => json.encode(data.toJson());

class TaxDropdownData {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  TaxDropdownData({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory TaxDropdownData.fromJson(Map<String, dynamic> json) => TaxDropdownData(
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
  List<FinancialDropDown>? financialDropDown;

  Data({
    this.financialDropDown,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    financialDropDown: json["financial_drop_down"] == null ? [] : List<FinancialDropDown>.from(json["financial_drop_down"]!.map((x) => FinancialDropDown.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "financial_drop_down": financialDropDown == null ? [] : List<dynamic>.from(financialDropDown!.map((x) => x.toJson())),
  };
}

class FinancialDropDown {
  String? companyFinancialYearId;
  String? financialLabel;
  DateTime? startDate;
  DateTime? endDate;

  FinancialDropDown({
    this.companyFinancialYearId,
    this.financialLabel,
    this.startDate,
    this.endDate,
  });

  factory FinancialDropDown.fromJson(Map<String, dynamic> json) => FinancialDropDown(
    companyFinancialYearId: json["company_financial_year_id"],
    financialLabel: json["financial_label"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
  );

  Map<String, dynamic> toJson() => {
    "company_financial_year_id": companyFinancialYearId,
    "financial_label": financialLabel,
    "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "end_date": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
  };
}
