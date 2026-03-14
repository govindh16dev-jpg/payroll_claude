// To parse this JSON data, do
//
//     final profileDataPayslip = profileDataPayslipFromJson(jsonString);

import 'dart:convert';

ProfileDataPayslip profileDataPayslipFromJson(String str) => ProfileDataPayslip.fromJson(json.decode(str));

String profileDataPayslipToJson(ProfileDataPayslip data) => json.encode(data.toJson());

class ProfileDataPayslip {
  String? employeeNo;
  String? employeeName;
  String? gender;
  String? dateOfBirth;
  String? dateOfJoining;
  String? department;
  String? designation;
  String? costCenter;
  String? panNumber;
  String? uanNumber;
  String? esiNumber;
  String? pfNumber;
  String? location;
  String? bankName;
  String? accountNumber;
  String? noOfDays;
  dynamic lopReversalMonth;
  dynamic lopRecoveryMonth;
  String? noOfDaysPaid;
  String? noOfLopDays;
  String? lopReversal;
  String? lopRecovery;
  dynamic taxRegime;
  String? currencySymbol;
  String? currencyName;
  String? ctc;
  String? annualGross;
  String? monthlyGross;
  String? fromMonth;
  String? estimatedAnnualTaxableIncome;

  ProfileDataPayslip({
    this.employeeNo,
    this.employeeName,
    this.gender,
    this.dateOfBirth,
    this.dateOfJoining,
    this.department,
    this.designation,
    this.costCenter,
    this.panNumber,
    this.uanNumber,
    this.esiNumber,
    this.pfNumber,
    this.location,
    this.bankName,
    this.accountNumber,
    this.noOfDays,
    this.lopReversalMonth,
    this.lopRecoveryMonth,
    this.noOfDaysPaid,
    this.noOfLopDays,
    this.lopReversal,
    this.lopRecovery,
    this.taxRegime,
    this.currencySymbol,
    this.currencyName,
    this.ctc,
    this.annualGross,
    this.monthlyGross,
    this.fromMonth,
    this.estimatedAnnualTaxableIncome,
  });

  factory ProfileDataPayslip.fromJson(Map<String, dynamic> json) => ProfileDataPayslip(
    employeeNo: json["employee_no"],
    employeeName: json["employee_name"],
    gender: json["gender"],
    dateOfBirth: json["date_of_birth"],
    dateOfJoining: json["date_of_joining"],
    department: json["department"],
    designation: json["designation"],
    costCenter: json["cost_center"],
    panNumber: json["pan_number"],
    uanNumber: json["uan_number"],
    esiNumber: json["esi_number"],
    pfNumber: json["pf_number"],
    location: json["location"],
    bankName: json["bank_name"],
    accountNumber: json["account_number"],
    noOfDays: json["no_of_days"],
    lopReversalMonth: json["lop_reversal_month"],
    lopRecoveryMonth: json["lop_recovery_month"],
    noOfDaysPaid: json["no_of_days_paid"],
    noOfLopDays: json["no_of_lop_days"],
    lopReversal: json["lop_reversal"],
    lopRecovery: json["lop_recovery"],
    taxRegime: json["tax_regime"],
    currencySymbol: json["currency_symbol"],
    currencyName: json["currency_name"],
    ctc: json["ctc"],
    annualGross: json["annual_gross"],
    monthlyGross: json["monthly_gross"],
    fromMonth: json["from_month"],
    estimatedAnnualTaxableIncome: json["estimated_annual_taxable_income"],
  );

  Map<String, dynamic> toJson() => {
    "employee_no": employeeNo,
    "employee_name": employeeName,
    "gender": gender,
    "date_of_birth": dateOfBirth,
    "date_of_joining": dateOfJoining,
    "department": department,
    "designation": designation,
    "cost_center": costCenter,
    "pan_number": panNumber,
    "uan_number": uanNumber,
    "esi_number": esiNumber,
    "pf_number": pfNumber,
    "location": location,
    "bank_name": bankName,
    "account_number": accountNumber,
    "no_of_days": noOfDays,
    "lop_reversal_month": lopReversalMonth,
    "lop_recovery_month": lopRecoveryMonth,
    "no_of_days_paid": noOfDaysPaid,
    "no_of_lop_days": noOfLopDays,
    "lop_reversal": lopReversal,
    "lop_recovery": lopRecovery,
    "tax_regime": taxRegime,
    "currency_symbol": currencySymbol,
    "currency_name": currencyName,
    "ctc": ctc,
    "annual_gross": annualGross,
    "monthly_gross": monthlyGross,
    "from_month": fromMonth,
    "estimated_annual_taxable_income": estimatedAnnualTaxableIncome,
  };
}
