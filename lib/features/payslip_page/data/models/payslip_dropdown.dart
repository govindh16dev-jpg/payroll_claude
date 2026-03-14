import 'dart:convert';

class PayslipDropdownData {
  final List<String> years;
  final Map<String, List<String>> yearMonthMap;

  PayslipDropdownData({required this.years, required this.yearMonthMap});
}

// To parse this JSON data, do
//
//     final payslip = payslipFromJson(jsonString);




class PayslipTotals {
  String? totalEarnings;
  String? totalDeduction;
  String? netPay;
  String? daysWorked;

  PayslipTotals({
    this.totalEarnings,
    this.totalDeduction,
    this.netPay,
    this.daysWorked,
  });
}
// To parse this JSON data, do
//
//     final incomeTaxData = incomeTaxDataFromJson(jsonString);



// To parse this JSON data, do
//
//     final incomeTaxData = incomeTaxDataFromJson(jsonString);

IncomeTaxData incomeTaxDataFromJson(String str) => IncomeTaxData.fromJson(json.decode(str));

String incomeTaxDataToJson(IncomeTaxData data) => json.encode(data.toJson());

class IncomeTaxData {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  IncomeTaxData({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory IncomeTaxData.fromJson(Map<String, dynamic> json) => IncomeTaxData(
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
  List<IncomeSlab>? incomeSlab;
  List<IncomeSlab>? surcharge;
  List<IncomeSlab>? taxAfterSurcharge;
  List<IncomeSlab>? otherTabs;

  Data({
    this.incomeSlab,
    this.surcharge,
    this.taxAfterSurcharge,
    this.otherTabs,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    incomeSlab: json["income_slab"] == null ? [] : List<IncomeSlab>.from(json["income_slab"]!.map((x) => IncomeSlab.fromJson(x))),
    surcharge: json["surcharge"] == null ? [] : List<IncomeSlab>.from(json["surcharge"]!.map((x) => IncomeSlab.fromJson(x))),
    taxAfterSurcharge: json["tax_after_surcharge"] == null ? [] : List<IncomeSlab>.from(json["tax_after_surcharge"]!.map((x) => IncomeSlab.fromJson(x))),
    otherTabs: json["other_tabs"] == null ? [] : List<IncomeSlab>.from(json["other_tabs"]!.map((x) => IncomeSlab.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "income_slab": incomeSlab == null ? [] : List<dynamic>.from(incomeSlab!.map((x) => x.toJson())),
    "surcharge": surcharge == null ? [] : List<dynamic>.from(surcharge!.map((x) => x.toJson())),
    "tax_after_surcharge": taxAfterSurcharge == null ? [] : List<dynamic>.from(taxAfterSurcharge!.map((x) => x.toJson())),
    "other_tabs": otherTabs == null ? [] : List<dynamic>.from(otherTabs!.map((x) => x.toJson())),
  };
}

class IncomeSlab {
  String? slab;
  String? formulaOrPercentage;
  String? value;

  IncomeSlab({
    this.slab,
    this.formulaOrPercentage,
    this.value,
  });

  factory IncomeSlab.fromJson(Map<String, dynamic> json) => IncomeSlab(
    slab: json["slab"],
    formulaOrPercentage: json["formula_or_percentage"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "slab": slab,
    "formula_or_percentage": formulaOrPercentage,
    "value": value,
  };
}

