// To parse this JSON data, do
//
//     final payslipPopupData = payslipPopupDataFromJson(jsonString);

import 'dart:convert';

PayslipPopupData payslipPopupDataFromJson(String str) => PayslipPopupData.fromJson(json.decode(str));

String payslipPopupDataToJson(PayslipPopupData data) => json.encode(data.toJson());

class PayslipPopupData {
  bool? success;
  String? message;
  int? statusCode;
  PopupData? data;

  PayslipPopupData({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory PayslipPopupData.fromJson(Map<String, dynamic> json) => PayslipPopupData(
    success: json["success"],
    message: json["message"],
    statusCode: json["status_code"],
    data: json["data"] == null ? null : PopupData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "status_code": statusCode,
    "data": data?.toJson(),
  };
}

class PopupData {
  List<ComponentDetail>? componentDetails;
  List<PayLossDataLop>? payLossDataLop;
  String? totalValueLop;
  String? lopTotalDays;
  List<PayLossDataLop>? payLossDataLopr;
  String? totalValueLopr;
  String? loprTotalDays;
  List<ArrearDetail>? arrearDetails;

  PopupData({
    this.componentDetails,
    this.payLossDataLop,
    this.totalValueLop,
    this.lopTotalDays,
    this.payLossDataLopr,
    this.totalValueLopr,
    this.loprTotalDays,
    this.arrearDetails,
  });

  factory PopupData.fromJson(Map<String, dynamic> json) => PopupData(
    componentDetails: json["component_details"] == null ? [] : List<ComponentDetail>.from(json["component_details"]!.map((x) => ComponentDetail.fromJson(x))),
    payLossDataLop: json["pay_loss_data_lop"] == null ? [] : List<PayLossDataLop>.from(json["pay_loss_data_lop"]!.map((x) => PayLossDataLop.fromJson(x))),
    totalValueLop: json["total_value_lop"],
    lopTotalDays: json["lop_total_days"],
    payLossDataLopr: json["pay_loss_data_lopr"] == null ? [] : List<PayLossDataLop>.from(json["pay_loss_data_lopr"]!.map((x) => PayLossDataLop.fromJson(x))),
    totalValueLopr: json["total_value_lopr"],
    loprTotalDays: json["lopr_total_days"],
    arrearDetails: json["arrear_details"] == null ? [] : List<ArrearDetail>.from(json["arrear_details"]!.map((x) => ArrearDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "component_details": componentDetails == null ? [] : List<dynamic>.from(componentDetails!.map((x) => x.toJson())),
    "pay_loss_data_lop": payLossDataLop == null ? [] : List<dynamic>.from(payLossDataLop!.map((x) => x.toJson())),
    "total_value_lop": totalValueLop,
    "lop_total_days": lopTotalDays,
    "pay_loss_data_lopr": payLossDataLopr == null ? [] : List<dynamic>.from(payLossDataLopr!.map((x) => x.toJson())),
    "total_value_lopr": totalValueLopr,
    "lopr_total_days": loprTotalDays,
    "arrear_details": arrearDetails == null ? [] : List<dynamic>.from(arrearDetails!.map((x) => x.toJson())),
  };
}

class ComponentDetail {
  String? componentId;
  String? componentKey;
  String? componentName;
  String? componentType;
  dynamic componentFormula;
  dynamic componentFormulaValues;
  String? ytdFormula;
  String? ytdFormulaValues;
  String? isNewPopup;
  String? provFormula;
  String? provCalculation;
  String? popupVersion;
  String? provValue;
  String? lopDays;
  String? lopFormula;
  String? lopCalculation;
  String? lopValue;
  String? actualFormula;
  String? actualCalculation;
  String? actualValue;
  String? newYtdFormula;
  dynamic currentYtdValues;
  String? lopStatus;
  String? lopReversal;
  String? arrearsStatus;
  dynamic lopreversalFormula;
  String? ctc;
  String? annualGross;
  String? monthlyGross;
  String? estimatedAnnualTaxableIncome;
  String? taxRegime;
  String? currencySymbol;
  String? currencyName;

  ComponentDetail({
    this.componentId,
    this.componentKey,
    this.componentName,
    this.componentType,
    this.componentFormula,
    this.componentFormulaValues,
    this.ytdFormula,
    this.ytdFormulaValues,
    this.isNewPopup,
    this.provFormula,
    this.provCalculation,
    this.popupVersion,
    this.provValue,
    this.lopDays,
    this.lopFormula,
    this.lopCalculation,
    this.lopValue,
    this.actualFormula,
    this.actualCalculation,
    this.actualValue,
    this.newYtdFormula,
    this.currentYtdValues,
    this.lopStatus,
    this.lopReversal,
    this.arrearsStatus,
    this.lopreversalFormula,
    this.ctc,
    this.annualGross,
    this.monthlyGross,
    this.estimatedAnnualTaxableIncome,
    this.taxRegime,
    this.currencySymbol,
    this.currencyName,
  });

  factory ComponentDetail.fromJson(Map<String, dynamic> json) => ComponentDetail(
    componentId: json["component_id"],
    componentKey: json["component_key"],
    componentName: json["component_name"],
    componentType: json["component_type"],
    componentFormula: json["component_formula"],
    componentFormulaValues: json["component_formula_values"],
    ytdFormula: json["ytd_formula"],
    ytdFormulaValues: json["ytd_formula_values"],
    isNewPopup: json["is_new_popup"],
    provFormula: json["prov_formula"],
    provCalculation: json["prov_calculation"],
    popupVersion: json["popup_version"],
    provValue: json["prov_value"],
    lopDays: json["lop_days"],
    lopFormula: json["lop_formula"],
    lopCalculation: json["lop_calculation"],
    lopValue: json["lop_value"],
    actualFormula: json["actual_formula"],
    actualCalculation: json["actual_calculation"],
    actualValue: json["actual_value"],
    newYtdFormula: json["new_ytd_formula"],
    currentYtdValues: json["current_ytd_values"],
    lopStatus: json["lop_status"],
    lopReversal: json["lop_reversal"],
    arrearsStatus: json["arrears_status"],
    lopreversalFormula: json["lopreversal_formula"],
    ctc: json["ctc"],
    annualGross: json["annual_gross"],
    monthlyGross: json["monthly_gross"],
    estimatedAnnualTaxableIncome: json["estimated_annual_taxable_income"],
    taxRegime: json["tax_regime"],
    currencySymbol: json["currency_symbol"],
    currencyName: json["currency_name"],
  );

  Map<String, dynamic> toJson() => {
    "component_id": componentId,
    "component_key": componentKey,
    "component_name": componentName,
    "component_type": componentType,
    "component_formula": componentFormula,
    "component_formula_values": componentFormulaValues,
    "ytd_formula": ytdFormula,
    "ytd_formula_values": ytdFormulaValues,
    "is_new_popup": isNewPopup,
    "prov_formula": provFormula,
    "prov_calculation": provCalculation,
    "popup_version": popupVersion,
    "prov_value": provValue,
    "lop_days": lopDays,
    "lop_formula": lopFormula,
    "lop_calculation": lopCalculation,
    "lop_value": lopValue,
    "actual_formula": actualFormula,
    "actual_calculation": actualCalculation,
    "actual_value": actualValue,
    "new_ytd_formula": newYtdFormula,
    "current_ytd_values": currentYtdValues,
    "lop_status": lopStatus,
    "lop_reversal": lopReversal,
    "arrears_status": arrearsStatus,
    "lopreversal_formula": lopreversalFormula,
    "ctc": ctc,
    "annual_gross": annualGross,
    "monthly_gross": monthlyGross,
    "estimated_annual_taxable_income": estimatedAnnualTaxableIncome,
    "tax_regime": taxRegime,
    "currency_symbol": currencySymbol,
    "currency_name": currencyName,
  };
}

class PayLossDataLop {
  String? detailsType;
  String? month;
  String? noOfDays;
  String? monthDays;
  String? monthValue;
  String? componentValue;

  PayLossDataLop({
    this.detailsType,
    this.month,
    this.noOfDays,
    this.monthDays,
    this.monthValue,
    this.componentValue,
  });

  factory PayLossDataLop.fromJson(Map<String, dynamic> json) => PayLossDataLop(
    detailsType: json["details_type"],
    month: json["month"],
    noOfDays: json["no_of_days"],
    monthDays: json["month_days"],
    monthValue: json["month_value"],
    componentValue: json["component_value"],
  );

  Map<String, dynamic> toJson() => {
    "details_type": detailsType,
    "month": month,
    "no_of_days": noOfDays,
    "month_days": monthDays,
    "month_value": monthValue,
    "component_value": componentValue,
  };
}

class ArrearDetail {
  String? monthName;
  String? arrearValue;

  ArrearDetail({
    this.monthName,
    this.arrearValue,
  });

  factory ArrearDetail.fromJson(Map<String, dynamic> json) => ArrearDetail(
    monthName: json["month_name"],
    arrearValue: json["arrear_value"],
  );

  Map<String, dynamic> toJson() => {
    "month_name": monthName,
    "arrear_value": arrearValue,
  };
}
