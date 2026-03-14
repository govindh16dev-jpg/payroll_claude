// To parse this JSON data, do
//
//     final documentDropdown = documentDropdownFromJson(jsonString);

import 'dart:convert';

DocumentDropdown documentDropdownFromJson(String str) => DocumentDropdown.fromJson(json.decode(str));

String documentDropdownToJson(DocumentDropdown data) => json.encode(data.toJson());

class DocumentDropdown {
  bool? success;
  String? message;
  int? statusCode;
  Data? data;

  DocumentDropdown({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory DocumentDropdown.fromJson(Map<String, dynamic> json) => DocumentDropdown(
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
  List<DocumentLookUp>? documentLookUps;

  Data({
    this.documentLookUps,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    documentLookUps: json["document_look_ups"] == null ? [] : List<DocumentLookUp>.from(json["document_look_ups"]!.map((x) => DocumentLookUp.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "document_look_ups": documentLookUps == null ? [] : List<dynamic>.from(documentLookUps!.map((x) => x.toJson())),
  };
}

class DocumentLookUp {
  String? documentTypeId;
  String? documentType;
  String? documentCategory;

  DocumentLookUp({
    this.documentTypeId,
    this.documentType,
    this.documentCategory,
  });

  factory DocumentLookUp.fromJson(Map<String, dynamic> json) => DocumentLookUp(
    documentTypeId: json["document_type_id"],
    documentType: json["document_type"],
    documentCategory: json["document_category"],
  );

  Map<String, dynamic> toJson() => {
    "document_type_id": documentTypeId,
    "document_type": documentType,
    "document_category": documentCategory,
  };
}
