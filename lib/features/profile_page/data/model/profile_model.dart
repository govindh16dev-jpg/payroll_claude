// To parse this JSON data, do
//
//     final profileData = profileDataFromJson(jsonString);
// To parse this JSON data, do
//
//     final profilePostData = profilePostDataFromJson(jsonString);

import 'dart:convert';

ProfilePostData profilePostDataFromJson(String str) =>
    ProfilePostData.fromJson(json.decode(str));

String profilePostDataToJson(ProfilePostData data) =>
    json.encode(data.toJson());

class ProfilePostData {
  String? clientId;
  String? companyId;
  String? employeeId;

  ProfilePostData({
    this.clientId,
    this.companyId,
    this.employeeId,
  });

  factory ProfilePostData.fromJson(Map<String, dynamic> json) =>
      ProfilePostData(
        clientId: json["client_id"],
        companyId: json["company_id"],
        employeeId: json["employee_id"],
      );

  Map<String, dynamic> toJson() => {
        "client_id": clientId,
        "company_id": companyId,
        "employee_id": employeeId,
      };
}

ProfileData profileDataFromJson(String str) =>
    ProfileData.fromJson(json.decode(str));

String profileDataToJson(ProfileData data) => json.encode(data.toJson());

class ProfileData {
  bool? success;
  String? message;
  Data? data;

  ProfileData({
    this.success,
    this.message,
    this.data,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  List<List<Map<String, String?>>>? employeeInfo;

  Data({
    this.employeeInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        employeeInfo: json["employee_info"] == null
            ? []
            : List<List<Map<String, String?>>>.from(json["employee_info"]!.map(
                (x) => List<Map<String, String?>>.from(x.map((x) => Map.from(x)
                    .map((k, v) => MapEntry<String, String?>(k, v)))))),
      );

  Map<String, dynamic> toJson() => {
        "employee_info": employeeInfo == null
            ? []
            : List<dynamic>.from(employeeInfo!.map((x) => List<dynamic>.from(
                x.map((x) => Map.from(x)
                    .map((k, v) => MapEntry<String, dynamic>(k, v)))))),
      };
}

class UserProfile {
  final String? employeeName;
  final String? mobile;
  final String? email;
  final String? dob;
  final String? sex;
  final String? firstName;
  final String? departmentName;
  final String? workExperiences;
  final String? dataOfJoining;
  final String? bankName;
  final String? accountNumber;
  final String? accountType;
  final String? bankBranch;
  final String? img;
  final String? jobTitle;
  final dynamic userData;

  UserProfile(
      {  this.employeeName,
       this.mobile,
       this.email,
       this.jobTitle,
       this.dob,
       this.sex,
       this.firstName,
       this.departmentName,
       this.dataOfJoining,
        this.workExperiences,
        this.bankName,
        this.accountNumber,
        this.accountType,
        this.bankBranch,
        this.img,
        this.userData
      });
}
// To parse this JSON data, do
//
//     final profileDataInfo = profileDataInfoFromJson(jsonString);


ProfileDataInfo profileDataInfoFromJson(String str) => ProfileDataInfo.fromJson(json.decode(str));

String profileDataInfoToJson(ProfileDataInfo data) => json.encode(data.toJson());

class ProfileDataInfo {
  bool? success;
  String? message;
  int? statusCode;
  ProfileInfoData? data;

  ProfileDataInfo({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory ProfileDataInfo.fromJson(Map<String, dynamic> json) => ProfileDataInfo(
    success: json["success"],
    message: json["message"],
    statusCode: json["status_code"],
    data: json["data"] == null ? null : ProfileInfoData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "status_code": statusCode,
    "data": data?.toJson(),
  };
}

class ProfileInfoData {
  List<EmployeeInfo>? employeeInfo;
  List<EmploymentInfo>? employmentInfo;
  List<BankInfo>? bankInfo;
  List<Map<String, String?>>? documentInfo;
  List<FamilyInfo>? familyInfo;
  List<dynamic>? educationInfo;
  List<CurrentExperienceInfo>? currentExperienceInfo;
  List<dynamic>? skillsInfo;

  ProfileInfoData({
    this.employeeInfo,
    this.employmentInfo,
    this.bankInfo,
    this.documentInfo,
    this.familyInfo,
    this.educationInfo,
    this.currentExperienceInfo,
    this.skillsInfo,
  });

  factory ProfileInfoData.fromJson(Map<String, dynamic> json) => ProfileInfoData(
    employeeInfo: json["employee_info"] == null ? [] : List<EmployeeInfo>.from(json["employee_info"]!.map((x) => EmployeeInfo.fromJson(x))),
    employmentInfo: json["employment_info"] == null ? [] : List<EmploymentInfo>.from(json["employment_info"]!.map((x) => EmploymentInfo.fromJson(x))),
    bankInfo: json["bank_info"] == null ? [] : List<BankInfo>.from(json["bank_info"]!.map((x) => BankInfo.fromJson(x))),
    documentInfo: json["document_info"] == null ? [] : List<Map<String, String?>>.from(json["document_info"]!.map((x) => Map.from(x).map((k, v) => MapEntry<String, String?>(k, v)))),
    familyInfo: json["family_info"] == null ? [] : List<FamilyInfo>.from(json["family_info"]!.map((x) => FamilyInfo.fromJson(x))),
    educationInfo: json["education_info"] == null ? [] : List<dynamic>.from(json["education_info"]!.map((x) => x)),
    currentExperienceInfo: json["current_experience_info"] == null ? [] : List<CurrentExperienceInfo>.from(json["current_experience_info"]!.map((x) => CurrentExperienceInfo.fromJson(x))),
    skillsInfo: json["skills_info"] == null ? [] : List<dynamic>.from(json["skills_info"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "employee_info": employeeInfo == null ? [] : List<dynamic>.from(employeeInfo!.map((x) => x.toJson())),
    "employment_info": employmentInfo == null ? [] : List<dynamic>.from(employmentInfo!.map((x) => x.toJson())),
    "bank_info": bankInfo == null ? [] : List<dynamic>.from(bankInfo!.map((x) => x.toJson())),
    "document_info": documentInfo == null ? [] : List<dynamic>.from(documentInfo!.map((x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v)))),
    "family_info": familyInfo == null ? [] : List<dynamic>.from(familyInfo!.map((x) => x.toJson())),
    "education_info": educationInfo == null ? [] : List<dynamic>.from(educationInfo!.map((x) => x)),
    "current_experience_info": currentExperienceInfo == null ? [] : List<dynamic>.from(currentExperienceInfo!.map((x) => x.toJson())),
    "skills_info": skillsInfo == null ? [] : List<dynamic>.from(skillsInfo!.map((x) => x)),
  };
}

class BankInfo {
  String? bankName;
  String? accountNumber;
  String? ifscCode;
  String? accontType;
  String? accountCategory;
  String? branch;
  String? rowType;
  String? tabName;

  BankInfo({
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accontType,
    this.accountCategory,
    this.branch,
    this.rowType,
    this.tabName,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) => BankInfo(
    bankName: json["Bank Name"],
    accountNumber: json["Account Number"],
    ifscCode: json["IFSC Code"],
    accontType: json["Accont type"],
    accountCategory: json["Account Category"],
    branch: json["Branch"],
    rowType: json["row_type"],
    tabName: json["tab_name"],
  );

  Map<String, dynamic> toJson() => {
    "Bank Name": bankName,
    "Account Number": accountNumber,
    "IFSC Code": ifscCode,
    "Accont type": accontType,
    "Account Category": accountCategory,
    "Branch": branch,
    "row_type": rowType,
    "tab_name": tabName,
  };
}

class CurrentExperienceInfo {
  String? employmentId;
  String? employeeId;
  String? departmentName;
  String? designationName;
  String? effectivePeriod;
  String? locationName;
  String? costCenterCode;
  String? jobGradeName;
  String? countryName;
  String? manager;
  String? rowType;
  String? tabName;

  CurrentExperienceInfo({
    this.employmentId,
    this.employeeId,
    this.departmentName,
    this.designationName,
    this.effectivePeriod,
    this.locationName,
    this.costCenterCode,
    this.jobGradeName,
    this.countryName,
    this.manager,
    this.rowType,
    this.tabName,
  });

  factory CurrentExperienceInfo.fromJson(Map<String, dynamic> json) => CurrentExperienceInfo(
    employmentId: json["employment_id"],
    employeeId: json["employee_id"],
    departmentName: json["department_name"],
    designationName: json["designation_name"],
    effectivePeriod: json["effective_period"],
    locationName: json["location_name"],
    costCenterCode: json["cost_center_code"],
    jobGradeName: json["job_grade_name"],
    countryName: json["country_name"],
    manager: json["manager"],
    rowType: json["row_type"],
    tabName: json["tab_name"],
  );

  Map<String, dynamic> toJson() => {
    "employment_id": employmentId,
    "employee_id": employeeId,
    "department_name": departmentName,
    "designation_name": designationName,
    "effective_period": effectivePeriod,
    "location_name": locationName,
    "cost_center_code": costCenterCode,
    "job_grade_name": jobGradeName,
    "country_name": countryName,
    "manager": manager,
    "row_type": rowType,
    "tab_name": tabName,
  };
}

class EmployeeInfo {
  String? employeeNo;
  String? name;
  String? mobile;
  String? workMail;
  String? dob;
  String? address1;
  dynamic address2;
  String? postcode;
  String? gender;
  dynamic religion;
  dynamic personalMail;
  String? title;
  String? addressType;
  String? physicallyChallenged;
  String? physicallyChallengedPercentage;
  String? employeeStatus;
  String? employeeCategory;
  String? maritalStatus;
  String? nationality;
  String? nationalityType;
  String? profileImg;
  String? rowType;
  String? tabName;
  String? img;

  EmployeeInfo({
    this.employeeNo,
    this.name,
    this.mobile,
    this.workMail,
    this.dob,
    this.address1,
    this.address2,
    this.postcode,
    this.gender,
    this.religion,
    this.personalMail,
    this.title,
    this.addressType,
    this.physicallyChallenged,
    this.physicallyChallengedPercentage,
    this.employeeStatus,
    this.employeeCategory,
    this.maritalStatus,
    this.nationality,
    this.nationalityType,
    this.profileImg,
    this.rowType,
    this.tabName,
    this.img,
  });

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) => EmployeeInfo(
    employeeNo: json["Employee No"],
    name: json["Name"],
    mobile: json["Mobile"],
    workMail: json["Work Mail"],
    dob: json["DOB"],
    address1: json["Address 1"],
    address2: json["Address 2"],
    postcode: json["Postcode"],
    gender: json["Gender"],
    religion: json["Religion"],
    personalMail: json["Personal Mail"],
    title: json["Title"],
    addressType: json["Address Type"],
    physicallyChallenged: json["Physically Challenged"],
    physicallyChallengedPercentage: json["Physically Challenged Percentage"],
    employeeStatus: json["Employee Status"],
    employeeCategory: json["Employee Category"],
    maritalStatus: json["Marital Status"],
    nationality: json["Nationality"],
    nationalityType: json["Nationality Type"],
    profileImg: json["profile_img"],
    rowType: json["row_type"],
    tabName: json["tab_name"],
    img: json["img"],
  );

  Map<String, dynamic> toJson() => {
    "Employee No": employeeNo,
    "Name": name,
    "Mobile": mobile,
    "Work Mail": workMail,
    "DOB": dob,
    "Address 1": address1,
    "Address 2": address2,
    "Postcode": postcode,
    "Gender": gender,
    "Religion": religion,
    "Personal Mail": personalMail,
    "Title": title,
    "Address Type": addressType,
    "Physically Challenged": physicallyChallenged,
    "Physically Challenged Percentage": physicallyChallengedPercentage,
    "Employee Status": employeeStatus,
    "Employee Category": employeeCategory,
    "Marital Status": maritalStatus,
    "Nationality": nationality,
    "Nationality Type": nationalityType,
    "profile_img": profileImg,
    "row_type": rowType,
    "tab_name": tabName,
    "img": img,
  };
}

class EmploymentInfo {
  String? jobTitle;
  String? team;
  String? department;
  String? employment;
  String? ctc;
  String? designation;
  String? grade;
  String? group;
  String? location;
  String? costCenter;
  String? reportingTo;
  String? doj;
  String? experience;
  String? rowType;
  String? tabName;

  EmploymentInfo({
    this.jobTitle,
    this.team,
    this.department,
    this.employment,
    this.ctc,
    this.designation,
    this.grade,
    this.group,
    this.location,
    this.costCenter,
    this.reportingTo,
    this.doj,
    this.experience,
    this.rowType,
    this.tabName,
  });

  factory EmploymentInfo.fromJson(Map<String, dynamic> json) => EmploymentInfo(
    jobTitle: json["Job Title"],
    team: json["Team"],
    department: json["Department"],
    employment: json["Employment"],
    ctc: json["CTC"],
    designation: json["Designation"],
    grade: json["Grade"],
    group: json["Group"],
    location: json["Location"],
    costCenter: json["Cost Center"],
    reportingTo: json["Reporting To"],
    doj: json["DOJ"],
    experience: json["Experience"],
    rowType: json["row_type"],
    tabName: json["tab_name"],
  );

  Map<String, dynamic> toJson() => {
    "Job Title": jobTitle,
    "Team": team,
    "Department": department,
    "Employment": employment,
    "CTC": ctc,
    "Designation": designation,
    "Grade": grade,
    "Group": group,
    "Location": location,
    "Cost Center": costCenter,
    "Reporting To": reportingTo,
    "DOJ": doj,
    "Experience": experience,
    "row_type": rowType,
    "tab_name": tabName,
  };
}

class FamilyInfo {
  String? employeeFamilyId;
  String? employeeId;
  String? clientId;
  String? relationOrder;
  String? relationType;
  String? firstName;
  String? surName;
  dynamic mobile;
  dynamic email;
  dynamic occupation;
  String? isPhysicallyChallenged;
  dynamic physicallyChallengedPercentage;
  dynamic dob;
  String? gender;
  dynamic nationalityId;
  dynamic nationalityType;
  dynamic contactStatus;
  String? recordStatus;
  String? rowType;
  String? tabName;

  FamilyInfo({
    this.employeeFamilyId,
    this.employeeId,
    this.clientId,
    this.relationOrder,
    this.relationType,
    this.firstName,
    this.surName,
    this.mobile,
    this.email,
    this.occupation,
    this.isPhysicallyChallenged,
    this.physicallyChallengedPercentage,
    this.dob,
    this.gender,
    this.nationalityId,
    this.nationalityType,
    this.contactStatus,
    this.recordStatus,
    this.rowType,
    this.tabName,
  });

  factory FamilyInfo.fromJson(Map<String, dynamic> json) => FamilyInfo(
    employeeFamilyId: json["employee_family_id"],
    employeeId: json["employee_id"],
    clientId: json["client_id"],
    relationOrder: json["relation_order"],
    relationType: json["relation_type"],
    firstName: json["first_name"],
    surName: json["sur_name"],
    mobile: json["mobile"],
    email: json["email"],
    occupation: json["occupation"],
    isPhysicallyChallenged: json["is_physically_challenged"],
    physicallyChallengedPercentage: json["physically_challenged_percentage"],
    dob: json["dob"],
    gender: json["gender"],
    nationalityId: json["nationality_id"],
    nationalityType: json["nationality_type"],
    contactStatus: json["contact_status"],
    recordStatus: json["record_status"],
    rowType: json["row_type"],
    tabName: json["tab_name"],
  );

  Map<String, dynamic> toJson() => {
    "employee_family_id": employeeFamilyId,
    "employee_id": employeeId,
    "client_id": clientId,
    "relation_order": relationOrder,
    "relation_type": relationType,
    "first_name": firstName,
    "sur_name": surName,
    "mobile": mobile,
    "email": email,
    "occupation": occupation,
    "is_physically_challenged": isPhysicallyChallenged,
    "physically_challenged_percentage": physicallyChallengedPercentage,
    "dob": dob,
    "gender": gender,
    "nationality_id": nationalityId,
    "nationality_type": nationalityType,
    "contact_status": contactStatus,
    "record_status": recordStatus,
    "row_type": rowType,
    "tab_name": tabName,
  };
}

