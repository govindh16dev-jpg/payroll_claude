// To parse this JSON data, do
//
//     final documentPostData = documentPostDataFromJson(jsonString);

import 'dart:convert';

DocumentPostData documentPostDataFromJson(String str) => DocumentPostData.fromJson(json.decode(str));

String documentPostDataToJson(DocumentPostData data) => json.encode(data.toJson());

class DocumentPostData {
  String? companyId;
  String? clientId;
  String? employeeId;
  String? documentTypeId;
  String? documentValue;
  String? issueDate;
  String? documentName;
  String? issuePlace;
  String? validFrom;
  String? validTo;


  DocumentPostData({
    this.companyId,
    this.clientId,
    this.employeeId,
    this.documentTypeId,
    this.documentValue,
    this.issueDate,
    this.documentName,
    this.issuePlace,
    this.validFrom,
    this.validTo,
  });

  factory DocumentPostData.fromJson(Map<String, dynamic> json) => DocumentPostData(
    companyId: json["company_id"],
    clientId: json["client_id"],
    employeeId: json["employee_id"],
    documentTypeId: json["document_type_id"],
    documentValue: json["document_value"],
    issueDate: json["issue_date"],
    documentName: json["document_name"],
    issuePlace: json["issue_place"],
    validFrom: json["valid_from"],
    validTo: json["valid_to"],
  );

  Map<String, dynamic> toJson() => {
    "company_id": companyId,
    "client_id": clientId,
    "employee_id": employeeId,
    "document_type_id": documentTypeId,
    "document_value": documentValue,
    "issue_date": issueDate,
    "document_name": documentName,
    "issue_place": issuePlace,
    "valid_from": validFrom,
    "valid_to": validTo,
  };
}

// To parse this JSON data, do
//
//     final documentDetails = documentDetailsFromJson(jsonString);



DocumentDetails documentDetailsFromJson(String str) => DocumentDetails.fromJson(json.decode(str));

String documentDetailsToJson(DocumentDetails data) => json.encode(data.toJson());

class DocumentDetails {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  DocumentDetails({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory DocumentDetails.fromJson(Map<String, dynamic> json) => DocumentDetails(
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
  List<Document>? document;

  Data({
    this.document,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    document: json["document"] == null ? [] : List<Document>.from(json["document"]!.map((x) => Document.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "document": document == null ? [] : List<dynamic>.from(document!.map((x) => x.toJson())),
  };
}

class Document {
  String? employeeDocumentId;
  String? employeeId;
  String? clientId;
  String? companyId;
  String? documentTypeId;
  String? documentValue;
  String? documentName;
  String? documentPath;
  DateTime? issueDate;
  String? issuePlace;
  DateTime? validFrom;
  DateTime? validTo;
  String? fileName;

  Document({
    this.employeeDocumentId,
    this.employeeId,
    this.clientId,
    this.companyId,
    this.documentTypeId,
    this.documentValue,
    this.documentName,
    this.documentPath,
    this.issueDate,
    this.issuePlace,
    this.validFrom,
    this.validTo,
    this.fileName,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    employeeDocumentId: json["employee_document_id"],
    employeeId: json["employee_id"],
    clientId: json["client_id"],
    companyId: json["company_id"],
    documentTypeId: json["document_type_id"],
    documentValue: json["document_value"],
    documentName: json["document_name"],
    documentPath: json["document_path"],
    issueDate: json["issue_date"] == null ? null : DateTime.parse(json["issue_date"]),
    issuePlace: json["issue_place"],
    validFrom: json["valid_from"] == null ? null : DateTime.parse(json["valid_from"]),
    validTo: json["valid_to"] == null ? null : DateTime.parse(json["valid_to"]),
    fileName: json["file_name"],
  );

  Map<String, dynamic> toJson() => {
    "employee_document_id": employeeDocumentId,
    "employee_id": employeeId,
    "client_id": clientId,
    "company_id": companyId,
    "document_type_id": documentTypeId,
    "document_value": documentValue,
    "document_name": documentName,
    "document_path": documentPath,
    "issue_date": "${issueDate!.year.toString().padLeft(4, '0')}-${issueDate!.month.toString().padLeft(2, '0')}-${issueDate!.day.toString().padLeft(2, '0')}",
    "issue_place": issuePlace,
    "valid_from": "${validFrom!.year.toString().padLeft(4, '0')}-${validFrom!.month.toString().padLeft(2, '0')}-${validFrom!.day.toString().padLeft(2, '0')}",
    "valid_to": "${validTo!.year.toString().padLeft(4, '0')}-${validTo!.month.toString().padLeft(2, '0')}-${validTo!.day.toString().padLeft(2, '0')}",
    "file_name": fileName,
  };
}
