import 'dart:convert';

import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this import
import 'package:payroll/features/homepage/data/model/banner.dart';
import 'package:payroll/features/homepage/data/repository/home_provider.dart';
import 'package:payroll/features/login/domain/model/login_model.dart';
import 'package:payroll/features/notification/notification_handler.dart';

import '../../../routes/app_pages.dart';
import '../../../routes/app_route.dart';
import '../../profile_page/data/model/profile_model.dart';
import '../data/model/notification.dart';
import '../views/widgets/carosel.dart';

class HomePageController extends GetxController {
  var loading = Loading.initial.obs;
  var bannerData = BannerData().obs;
  var menuData = MenuData().obs;
  var notificationData = NotificationData().obs;
  var notificationDropdownData = NotificationDropdown().obs;
  final appStateController = Get.put(AppStates());
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();

  UserData userData = UserData();
  RxBool isMasked = true.obs;
  RxList bannerItems = [].obs;
  RxList menuItems = [].obs;
  RxList<Notification> notificationItems = <Notification>[].obs;
  RxList<Section> sectionItems = <Section>[].obs;
  RxString selectedSection = "All".obs;
  RxString notificationCount = "0".obs;
  var selectedRole = Role(roleId: "0", roleName: "All").obs;
  RxString selectedRoleID = "0".obs;
  RxList<Role> roleItems = <Role>[].obs;
  final List<String> notificationFilterOptions = [
    "All",
    "Announcement",
    "Leave Update",
    "Appraisal"
  ];

  final HomePageProvider homeProvider = Get.put(HomePageProvider());
  var selectedNotificationFilter = "All".obs;

  // Function to update the selected filter
  void updateNotificationFilter(String value) {
    selectedNotificationFilter.value = value;
  }

  void openFreshChat() {
    // Open the Freshchat chat interface
    // Freshchat.showConversations();
  }

  @override
  void onInit() {
    super.onInit();
    bannerItems.value = [
      NetPayCard(
        monthYear: 'Jan 2025',
        daysWorked: '29',
        amount: '1,51,500',
        percentageChange: 0.1,
        bankAccountNumber: '****7890',
        bankName: 'HDFC Bank',
      ),
      TaxCard(
        taxLiability: '1,60,274',
        taxPaid: '9,045',
        balanceTax: '1,51,500',
        remainingMonths: '10',
        monthlyTax: '13746',
      ),
      if (checkForLeave())
        LeaveCardOverAll(
          title: 'Earned Leave',
          sickLeave: '10',
          earnedLeave: '3',
          compOff: '7',
          upcomingHoliday: 'Upcoming Holiday : 25 Feb 2025',
        ),
    ];

    // Initialize everything in the correct order
    _initializeApp();
  }

  /// Initialize Firebase and notification services in the correct order
  Future<void> _initializeApp() async {
    try {
      // Step 1: Get user data first
      await getUserData();

      // Step 2: Initialize Firebase before any Firebase service usage
      await _initializeFirebase();

      // Step 3: Initialize notification service (without Firebase.initializeApp call)
      await _initializeNotificationService();
    } catch (e) {
      print('❌ Error initializing app: $e');
      // Handle initialization error - maybe show error dialog
    }
  }

  /// Initialize Firebase based on platform
  Future<void> _initializeFirebase() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        // Initialize Firebase with platform-specific options
        await Firebase.initializeApp(
            // Add your Firebase options here if needed for mobile
            // For web, the options are handled in NotificationService
            );
        print('✅ Firebase initialized successfully');
      } else {
        print('ℹ️ Firebase already initialized');
      }
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Initialize notification services after Firebase is ready
  Future<void> _initializeNotificationService() async {
    try {
      // Initialize notification service (this will not call Firebase.initializeApp again)
      await NotificationService().init();

      // Wait a bit for initialization to complete
      await Future.delayed(Duration(seconds: 1));

      // Initialize token handling for authenticated user
      await NotificationService().initializeTokenHandlingForAuthenticatedUser();

      // Handle foreground messages
      await NotificationService().handleForegroundMessages();

      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      // Continue without notifications rather than crashing
    }
  }

  Future<UserData> getUserData() async {
    const storage = FlutterSecureStorage();
    final String? userDataLocal = await storage.read(key: PrefStrings.userData);

    if (userDataLocal == null) {
      // No user data - redirect to login
      print('❌ No user data found - redirecting to login');
      Get.offAllNamed(AppRoutes.loginPage);
      throw Exception('No user data');
    }

    userData = userDataFromJson(userDataLocal);
    appStateController.userData.value = userData;
    setIsTestUser();
    // Fetch data after user data is loaded
    fetchBannerData();
    fetchMenuData();
    fetchNotificationDropDownData();
    fetchNotificationData();

    return userData;
  }


  bool checkForLeave() {
    // Check if any menu item has the key "absence_employee"
    bool hasLeave =
        menuItems.any((menu) => menu['menu_key'] == 'absence_employee');
    return hasLeave;
  }

  bool isManager() {
    // Check if any menu item has the key "absence_manager"
    return menuItems.any((menu) => menu['menu_key'] == 'absence_manager');
  }

  // Rest of your methods remain the same...
  fetchMenuData() async {
    try {
      loading.value = Loading.loading;
      await homeProvider.getMenuData().then((value) {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          menuData.value = menuDataFromJson(value.body);
          final menuDataAPI = menuData.value;
          if (menuData.value.data != null) {
            menuItems.clear();
            for (var menu in menuDataAPI.data!.menu!) {
              if (menu['menu_image_link'] != null) menuItems.add(menu);
            }
           if(appStateController.isTestUser.value){
             menuItems.add({
               "menu_image_link": "https://s3.ap-south-2.amazonaws.com/azattachments/Menus/1724673122-Profile.png?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAYHUWSFLCE4BRLRGN%2F20250824%2Fap-south-2%2Fs3%2Faws4_request&X-Amz-Date=20250824T151641Z&X-Amz-SignedHeaders=host&X-Amz-Expires=72000&X-Amz-Signature=8cf15a76f5ad35eac82d2c28b1dda13bc8160b0a9c3d223dd305814545251a0d",
               "menu_name": "Time",
               "menu_key": "time",
             });
           }
            appStateController.menuItems = menuItems;
          }
        }
      });
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  getRemainingLeaves(leaveType) {
    LeaveRecod? leaveData = bannerData.value.data?.leaveRecods
        ?.firstWhere((record) => record.leaveKey == leaveType);
    return leaveData?.availableLeaves ?? "";
  }

  void setIsTestUser() {
    if (userData.user == null) {
      appStateController.isTestUser.value = false;
      return;
    }

    appStateController.isTestUser.value =
        (userData.user!.clientId == '3' &&
            userData.user!.companyId == '1' &&
            userData.user!.employeeId == '105') ||
            (userData.user!.clientId == '3' &&
                userData.user!.companyId == '1' &&
                userData.user!.employeeId == '107');
  }

  fetchBannerData() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await homeProvider.getBannerData(employeeData).then((value) {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          bannerData.value = bannerDataFromJson(value.body);
          final bannerDataAPI = bannerData.value;
          appStateController.currency.value =
              bannerDataAPI.data!.banners![0].currencySymbol!;
          appStateController.updateHoliday(bannerDataAPI
                  .data?.banners?.first.upComingHoliday
                  ?.substring(0, 12) ??
              "");
          if (bannerData.value.data != null) {
            bannerItems.clear();
            bannerItems.value = [
              PayslipBannerDivided(
                monthYear: bannerDataAPI.data?.banners?.first.payMothYear ?? "",
                workedDaysValue:
                    bannerDataAPI.data?.banners?.first.noOfDays ?? "",
                accountNumberSuffix:
                    bannerDataAPI.data?.banners?.first.accountNumber ?? "",
                bankName: bannerDataAPI.data?.banners?.first.bankName ?? "",
                lopJanValue:
                    bannerDataAPI.data?.banners?.first.noOfLopDays ?? '1',
                plopDecValue:
                    bannerDataAPI.data?.banners?.first.lopRecovery ?? '1',
                lopReversalValue:
                    bannerDataAPI.data?.banners?.first.lopReversal ?? '1',
                netPayAmount:
                    bannerDataAPI.data?.banners?.first.currentMonthNetPay ??
                        "0",
              ),
              TaxCard(
                taxLiability:
                    bannerDataAPI.data?.banners?.first.totalTaxLiability ?? "0",
                taxPaid:
                    bannerDataAPI.data?.banners?.first.taxPaidTillNow ?? "0",
                balanceTax:
                    bannerDataAPI.data?.banners?.first.balanceTax ?? "0",
                remainingMonths:
                    bannerDataAPI.data?.banners?.first.remainingMonths ?? "0",
                monthlyTax:
                    bannerDataAPI.data?.banners?.first.monthlyTaxPayable ?? "0",
              ),
              if (checkForLeave())
                LeaveCardOverAll(
                  title: "Leave balance",
                  sickLeave: getRemainingLeaves("sick_leave"),
                  earnedLeave: getRemainingLeaves("earned_leave"),
                  compOff: getRemainingLeaves("casual_leave"),
                  upcomingHoliday:
                      'Upcoming Holiday : ${bannerDataAPI.data?.banners?.first.upComingHoliday?.substring(0, 12) ?? ""}',
                ),
            ];
          }
        }
      });
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  fetchNotificationDropDownData() async {
    try {
      loading.value = Loading.loading;
      await homeProvider.getNotificationDropdownData().then((value) {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          notificationDropdownData.value =
              notificationDropdownFromJson(value.body);
          final notificationDropdownDataAPI =
              notificationDropdownData.value.data;
          if (notificationDropdownData.value.data != null) {
            notificationCount.value =
                notificationDropdownDataAPI!.count![0].countNotify!;
            if (notificationDropdownDataAPI.section!.isNotEmpty) {
              sectionItems.clear();
              for (var section in notificationDropdownDataAPI.section!) {
                sectionItems.add(section);
              }
            }
            if (notificationDropdownDataAPI.role!.isNotEmpty) {
              roleItems.clear();
              for (var role in notificationDropdownDataAPI.role!) {
                roleItems.add(role);
              }
            }
          }
        }
      });
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  fetchNotificationData() async {
    try {
      loading.value = Loading.loading;
      await homeProvider
          .getNotificationData(selectedRoleID.value, selectedSection.value)
          .then((value) {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          notificationData.value = notificationDataFromJson(value.body);
          final notificationDataAPI = notificationData.value;
          if (notificationData.value.data != null) {
            notificationItems.clear();
            for (var notification in notificationDataAPI.data!.notification!) {
              notificationItems.add(notification);
            }
          }
        }
      });
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  @override
  void dispose() {
    Get.delete<HomePageController>();
    super.dispose();
  }
}
