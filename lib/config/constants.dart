import 'package:flutter/material.dart';

enum Loading { initial, loading, loaded }

final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
class PrefStrings {
  static const String loginData = "loginData";
  static const String registerData = "registerData";
  static const String accessToken = "accessToken";
  static const String refreshToken = "refreshToken";
  static const bool isLoggedIn = false;
  static const String ssoLinkConsumed = 'sso_link_consumed';
  static const String isSSOLogin = 'isSSOLogin';
  static const String ssoTokenReceivedTime = 'ssoTokenReceivedTime';
  static const String ssoTokenExpiresIn = 'ssoTokenExpiresIn';
  static const String userData = "userData";
  static const String userCredentialsData = "userCredentialsData";
  static const String rememberMe = "rememberMe";
  static const String userProfileData = "userProfile";
  static const String leaveData = "leaveData";
}
getUrl(isLive,label){
  if(isLive){
    switch(label){
      case 'baseUrl':
      return  "https://essapi.azatecon.com/api/mobile/";
      case 'supportUrl':
        return   "https://ess.azatecon.com/support";
      case 'notifyUrl':
        return   "https://essapi.azatecon.com/api/notification";
      case 'notifyDropdownUrl':
        return    "https://essapi.azatecon.com/api/notify/dropdown";
      case 'notifyUpdateToken':
        return    "https://essapi.azatecon.com/api/fcm_token_update";
      case 'notifyStatus':
        return "https://essapi.azatecon.com/api/notification/status/update";
      case 'ssoLogin':
        return "http://essapi.azatecon.com/api/mobile/sso/login";
    }
  }else{
    switch(label){
      case 'baseUrl':
        return  "http://apistaging.azatecon.com/api/mobile/";
      case 'supportUrl':
        return   "http://apistaging.azatecon.com/support";
      case 'notifyUrl':
        return   "http://apistaging.azatecon.com/api/notification";
      case 'notifyDropdownUrl':
        return    "http://apistaging.azatecon.com/api/notify/dropdown";
      case 'notifyUpdateToken':
        return    "http://apistaging.azatecon.com/api/fcm_token_update";
      case 'notifyStatus':
        return "http://apistaging.azatecon.com/api/notification/status/update";
      case 'ssoLogin':
        return "http://apistaging.azatecon.com/api/mobile/sso/login";
    }
  }
}

class FirebaseConstants{
  static final String apiKey =  "AIzaSyDDiP35QpJwsMwvBUXYeUMQxrBtZfD0efE";
  static final String authDomain = "azatecon-3b631.firebaseapp.com";
  static final String projectId = "azatecon-3b631";
  static final String storageBucket =  "azatecon-3b631.firebasestorage.app";
  static final String messagingSenderId = "543784324609";
  static final String appId = "1:543784324609:web:db3c12da5c9e23cfd03a00";
  static final String appIdiOS = "1:543784324609:ios:ab98684c37215816d03a00";
}
/// A class containing all API endpoint constants used throughout the app.
class ApiConstants {
  /// Determines if the environment is live (production) or not (development).
  static final bool isLive = true;

  /// Base URL for the main API.
  static final String baseUrl = getUrl(isLive, "baseUrl");

  /// URL for support-related API endpoints.
  static final String supportUrl = getUrl(isLive, "supportUrl");

  /// URL for notification-related API endpoints.
  static final String notifyUrl = getUrl(isLive, "notifyUrl");

  /// URL for fetching notification dropdown data.
  static final String notifyDropdownUrl = getUrl(isLive, "notifyDropdownUrl");
  static final String notifyUpdateToken = getUrl(isLive, "notifyUpdateToken");
  static final String ssoLogin = "sso/login";


  // ----------------- Auth -----------------

  static const register = "register"; // User registration
  static const login = "login"; // User login
  static const forgotPassword = "forgot/password"; // Forgot password request
  static const verifyPassword = "otp-verify/password"; // Verify OTP for password reset

  // ----------------- Dashboard -----------------

  static const getBannersData = "banners/view"; // Fetch banner data
  static const getMenus = "menus"; // Fetch sidebar/menu options

  // ----------------- Payslip -----------------

  static const paySlipDropdown = "payslip/dropdown"; // Dropdown values for payslip
  static const paySlipData = "payslip/view"; // View payslip data
  static const paySlipPopup = "payslip/popup"; // View detailed payslip popup
  static const paySlipDownload = "payslip/download"; // Download payslip

  // ----------------- Income Tax -----------------

  static const incomeTaxData = "payslip/income-tax"; // View income tax data
  static const taxDropdown = "tax-computation/dropdown"; // Dropdown for tax computation
  static const taxData = "tax-computation/view"; // View tax computation details
  static const taxDownload = "tax-computation/download"; // Download tax documents

  // ----------------- Leave -----------------

  static const applyLeave = "leave/apply"; // Apply for leave
  static const validateLeave = "leave/validate"; // Validate leave application
  static const getLeave = "leave/view"; // View applied leaves

  // ----------------- CTC -----------------

  static const ctcData = "ctc/view"; // View CTC Data
  static const ctcDownload = "ctc/download"; // Download CTC Data

  // ----------------- Manager -----------------

  static const checkDelegate = "leave-delicate/check";
  static const createDelegate = "leave-delicate/create";
  static const updateDelegate = "leave-delicate/update";
  static const removeDelegate = "leave-delicate/remove";
  static const editDelegate = "leave-delicate/edit";
  static const managerDropdown = "leave-delicate/dropDown";

  // ----------------- Manager Leave -----------------

  static const leaveManager = "leave-manager/view";
  static const leaveStatusUpdate = "leave-manager/status";
  static const leaveCalendarData = "leave-manager/calendar";



  // ----------------- Notifications -----------------

  static const notification = "notification"; // Fetch notifications
  static const notificationDropdown = "/notify/dropdown"; // Notification dropdown data
  static const updateFCMToken = "fcm_token_update"; // Update token data
  static final String notifyStatus = getUrl(isLive, "notifyStatus");

  // ----------------- Documents -----------------

  static const docDropdown = "profie-info/document/dropdown"; // Dropdown for document types
  static const docAdd = "profie-info/document/add"; // Add new document
  static const docDetails = "profie-info/document/edit"; // Edit existing document
  static const docRemove = "profie-info/document/remove"; // Remove document
  static const docDownload = "profie-info/document/download"; // Download document

  // ----------------- Profile -----------------

  static const userProfile = "profie-info/view"; // Fetch user profile data
  static const userProfileUpdate = "profile-info/img-update"; // Update profile picture

  // ----------------- OTP -----------------

  static const verifyOtp = "verify-otp"; // OTP verification
  static const resendOtp = "resend-otp"; // Resend OTP
  static const String employeeTimeView = "time/view";
  static const String clockIn = "time/clock_in";
  static const String clockOut = "time/clock_out";
  static const String startBreak = "time/break/start";
  static const String endBreak = "time/break/end";
  static const String timeCalendar = "time/calendar";
  static const String timeDetails = "time/details";
  static const String timeRegularization = "time/regularize";
  static const String timePopup= "time/calendar/popup";
  static const String timeStatistics = "time/statistics";
  static const String timeHistory = "time/history";
  static const String updateGeoLocation = "time/geo/update";
  static const String shiftDetails = "time/shift";
  static const String calendarPopup = "time/calendar/popup";
  static const String workingStatus = "time/working/status";
  static const String modifyAttendance = "time/modify/attendance";
  static const String timeWorkStatusPopup = "time/workstatus/popup";
  static const String timeManagerStats = "time-manager/stats";
  static const String timeManagerRegularizeList = "time-manager/regularize-list";
  static const String timeManagerAction = "time-manager/action";
  static const String timeManagerDropdown = "time-manager/shift/dropdown";
  static const String timeManagerShift = "time-manager/shift";
  static const String timeManagerEmployeeDropdown = "time-manager/employee/dropdown";
  static const String timeManagerEmployeeDetails = "time-manager/employee-details";
  static const String timeManagerRouteList = "time-manager/route/list";
  static const String timeManagerStatsPopup = "time-manager/stats/popup";
  static const String routeAdd = "time/route/add";
  static const String employeeRouteList = "time/route/list";
  // ----------------- Settings -----------------

  static const changePassword = "change-password"; // Change user password
  static const deactivateAccount = "account/deactivate"; // Deactivate user account
  static const logOut = "logout"; // User logout
}


class AppColors {
  static const Color buttonColor = Color(0xFFFDFDFD);
  static const Color tileBg = Color(0xFFFDFDFD);

  static const Color primaryAppColor = Color(0xFF2F2F2F);
  static const Color unselectedIndicator = Color(0x802F2F2F);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF353535);
  static const Color borderColor = Color(0XFF7F7F7F);
  static const Color borderColorChat = Color(0X837F7F7F);
  static const Color textFieldBorderColor = Color(0xFFD1D1D1);
  static const Color textFieldBorderColorUnselected = Color(0xFFF2F2F2);
  static const Color dialogMessageColor = Color(0xFF767676);
  static const Color bgColor = Color(0xFFFCFCFC);
  static const Color textBlueColor = Color(0xFF0F6ABD);
  static const Color textBlueColorDark = Color(0xFF1337EC);
  static const Color headingTextColor = Color(0xFFABABAB);
  static const Color logoutButton = Color(0xFF0C0507);
  static const Color textEmailColor = Color(0xFF717171);
  static const Color textGreenColor = Color(0xFF0E7E13);
  static const Color textGreenColorLight = Color(0xFF2C6627);
  static const Color textFieldBgColor = Color(0xFFF5F6FA);
  static const Color textColorDark = Color(0xFF161616);
  static const Color reasonBgColor = Color(0xFFF3F3F3);
  static const Color boldTextColor = Color(0xFF4D4D4F);
  static const Color textColorLight = Color(0xFF7F8192);
  static const Color appRedColor = Color(0XFFA51010);
  static const Color boxShadowColor = Color(0x40000000);
  static const Color boxShadowColor2 = Color(0x33FCD240);
  static const Color dividerColorLogin = Color(0x80D1D1D1);
  static const Color boxBgColor = Color(0x1A000000);
  static const Color ratingTextColor = Color(0xFF757575);
  static const Color cardBG = Color(0XFFF8F8F8);
  static const Color loadingIndicatorColor = Color(0xFFD9D9D9);
  static const Color errorRedColor = Color(0xFFFF0000);
  static const Color textHeading = Color(0xFF000000);

  static const Color absoluteWhiteColor = Color.fromARGB(255, 255, 255, 255);
}
