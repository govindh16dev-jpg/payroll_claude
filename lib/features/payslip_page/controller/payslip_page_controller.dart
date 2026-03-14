import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:payroll/features/login/domain/model/login_model.dart';
import 'package:payroll/features/payslip_page/data/models/payslipPopupData.dart';
import 'package:payroll/features/payslip_page/data/repository/payslip_provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../routes/app_pages.dart';
import '../../../theme/theme_controller.dart';
import '../../homepage/views/widgets/carosel.dart';
import '../../profile_page/data/model/profile_model.dart';
import '../data/models/employeeData.dart';
import '../data/models/payslip_dropdown.dart';

class PayslipPageController extends GetxController {
  final GlobalKey<ScaffoldState> drawerKeyPayslip = GlobalKey<ScaffoldState>();

  var loading = Loading.initial.obs;
  final PayslipProvider payslipProvider = Get.put(PayslipProvider());
  final appStateController = Get.put(AppStates());
  UserData userData = UserData();
  UserProfile userProfile = UserProfile();
  ProfileDataPayslip userProfilePaySlip = ProfileDataPayslip();
  RxBool isMasked = true.obs;
  RxList bannerItems = [].obs;
  List<String> payslipYears = [];
  Map<String, List<String>> payslipYearMonthMap = {};
  RxString selectedYear = ''.obs;
  RxString selectedMonth = '...'.obs;
  RxList<dynamic> paySlipData = [].obs;
  IncomeTaxData incomeTaxData = IncomeTaxData();
  PayslipPopupData payslipPopupData = PayslipPopupData();
  RxList<dynamic> employeeDataAcc = [].obs;

  ///payslip
  RxList<Map<String, dynamic>> earningsData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> deductionData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> cumulativeData = <Map<String, dynamic>>[].obs;

  ///tax
  RxList<Map<String, dynamic>> slabData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> surcharge = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> annualIT = <Map<String, dynamic>>[].obs;
  RxList propertiesData = [].obs;
  RxList sortedEarnings = [].obs;
  final RxList<bool> isExpanded = [false, false].obs; // Tracks expansion state
  var totals = PayslipTotals().obs;
  final PageController pageController = PageController(initialPage: 1);
  var hasPageInitialized = false.obs;
  GlobalKey swipeAreaKey = GlobalKey();
  TutorialCoachMark? tutorialCoachMark;
  void toggleExpanded(int index) {
    isExpanded[index] = !isExpanded[index];
  }

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args != null &&
        args is Map &&
        args.containsKey('month') &&
        args.containsKey('year')) {
      selectedMonth.value = args['month'];
      selectedYear.value = args['year'];
    } else {
      selectedMonth.value = "";
      selectedYear.value = "";
      debugPrint('month not passed');
    }
    // Future.delayed(Duration(milliseconds: 300), showTutorial);
    getUserData()?.then((userData) {

      if (userData?.user != null) {
        getPaySlipDropDownData();
      }
    });
  }

  onSwipeLeft() {
    print('dddsss');
    var appTheme = Get.find<ThemeController>().currentTheme;
    var nextMonthYear = getNextMonthYear();
    if (nextMonthYear != null) {
      final expParts = nextMonthYear.split('/');
      selectedMonth.value = expParts[0];
      selectedYear.value = expParts[1];
      fetchPaySlipData(false);
    } else {
      appSnackBar(data: 'No more payslip data !', color: appTheme.green);
    }
  }
  Future<void> openBase64Pdf(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Payslip_${selectedMonth.substring(0,3)}$selectedYear.pdf');
      await file.writeAsBytes(bytes);
      final result = await OpenFile.open(file.path);
      print("File opened: ${result.message}");
    } catch (e) {
      print('Error opening PDF: $e');
    }
  //   <key>LSApplicationQueriesSchemes</key>
    // <array>
    //   <string>pdf</string>
    // </array>
    //On iOS: You may need to add the following to ios/Runner/Info.plist:
  }

  onSwipeRight() {
    var previousMonthYear = getPreviousMonthYear();
    var appTheme = Get.find<ThemeController>().currentTheme;
    if (previousMonthYear != null) {
      final expParts = previousMonthYear.split('/');
      selectedMonth.value = expParts[0];
      selectedYear.value = expParts[1];
      fetchPaySlipData(false);
    } else {
      appSnackBar(data: 'No more payslip data !', color: appTheme.green);
    }
  }

  String? getPreviousMonthYear() {
    int selectedYearIndex = payslipYears.indexOf(selectedYear.value);

    if (selectedYearIndex == -1) return null;

    List<String>? monthsInSelectedYear =
        payslipYearMonthMap[selectedYear.value];
    if (monthsInSelectedYear == null || monthsInSelectedYear.isEmpty) {
      return null;
    }

    int selectedMonthIndex = monthsInSelectedYear.indexOf(selectedMonth.value);
    if (selectedMonthIndex == -1) return null;

    // Determine previous month-year
    if (selectedMonthIndex > 0) {
      // Previous month is in the same year
      return "${monthsInSelectedYear[selectedMonthIndex - 1]}/$selectedYear";
    } else if (selectedYearIndex > 0) {
      // Previous month is in the previous year
      String previousYear = payslipYears[selectedYearIndex - 1];
      List<String>? monthsInPreviousYear = payslipYearMonthMap[previousYear];
      if (monthsInPreviousYear != null && monthsInPreviousYear.isNotEmpty) {
        return "${monthsInPreviousYear.last}/$previousYear";
      }
    }

    return null; // No previous month-year found
  }

  String? getNextMonthYear() {
    int selectedYearIndex = payslipYears.indexOf(selectedYear.value);

    if (selectedYearIndex == -1) return null;

    List<String>? monthsInSelectedYear =
        payslipYearMonthMap[selectedYear.value];
    if (monthsInSelectedYear == null || monthsInSelectedYear.isEmpty) {
      return null;
    }

    int selectedMonthIndex = monthsInSelectedYear.indexOf(selectedMonth.value);
    if (selectedMonthIndex == -1) return null;

    // Determine next month-year
    if (selectedMonthIndex < monthsInSelectedYear.length - 1) {
      // Next month is in the same year
      return "${monthsInSelectedYear[selectedMonthIndex + 1]}/$selectedYear";
    } else if (selectedYearIndex < payslipYears.length - 1) {
      // Next month is in the next year
      String nextYear = payslipYears[selectedYearIndex + 1];
      List<String>? monthsInNextYear = payslipYearMonthMap[nextYear];
      if (monthsInNextYear != null && monthsInNextYear.isNotEmpty) {
        return "${monthsInNextYear.first}/$nextYear";
      }
    }

    return null; // No next month-year found
  }

  getPaySlipDropDownData() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await payslipProvider
          .getPaySlipDropDown(employeeData)
          .then((dropdownData) {
        loading.value = Loading.loaded;
        payslipYears = dropdownData.years;
        payslipYearMonthMap = dropdownData.yearMonthMap;
        selectedYear.value = payslipYears.isNotEmpty ? payslipYears.first : '';
        selectedMonth.value = selectedYear.isNotEmpty
            ? (payslipYearMonthMap[selectedYear.value]?.isNotEmpty ?? false
                ? payslipYearMonthMap[selectedYear.value]!.first
                : '')
            : '';
      });
      fetchPaySlipData(false);

    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  fetchPaySlipData(isRight) async {
    Future.delayed(Duration(milliseconds: 300), () {
      pageController.jumpToPage(1);
      notifyChildrens();
    });
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await payslipProvider
          .getPaySlipData(employeeData, selectedYear.value, selectedMonth.value)
          .then((value) {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          var payslipProfile =
              List<dynamic>.from(responseData['data']['pay_slip'][0]).first;

          userProfilePaySlip = ProfileDataPayslip.fromJson(payslipProfile);
          paySlipData.value =
              List<dynamic>.from(responseData['data']['pay_slip'][1]);
          totals.value = PayslipTotals();
          earningsData.clear();
          deductionData.clear();
          cumulativeData.clear();
          employeeDataAcc.clear();
          for (var component in paySlipData) {
            if (component['component_type'] == 'Earnings') {
              earningsData.add(component);
            }
            if (component['component_type'] == 'Deductions') {
              deductionData.add(component);
            }
            if (component['component_type'] == 'Cumulative') {
              cumulativeData.add(component);
              if (component['component_name'] == 'Gross Earnings') {
                totals.value.totalEarnings = component['component_values'];
              }
              if (component['component_name'] == 'Gross Deductions') {
                totals.value.totalDeduction = component['component_values'];
              }
              if (component['component_name'] == 'Net Salary') {
                totals.value.netPay = component['component_values'];
              }
            }
          }
          employeeDataAcc.value =
              List<dynamic>.from(responseData['data']['pay_slip'][0]);
          if (employeeDataAcc.isNotEmpty) {
            totals.value.daysWorked = employeeDataAcc[0]['no_of_days'];
          }
        }
      });
    } on CustomException catch (err,st) {
      loading.value = Loading.loaded;  print('err ${err.toString()}');
      print(st.toString());

      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error,st) {
      loading.value = Loading.loaded;
      print('err ${error.toString()}');
      print(st.toString());
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  fetchPaySlipPdf() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await payslipProvider
          .downloadPaySlip(employeeData, selectedYear.value, selectedMonth.value)
          .then((value) async {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          String base64Pdf = responseData['data']['file'];
          await openBase64Pdf(base64Pdf);

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

  fetchIncomeTaxData() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await payslipProvider
          .getIncomeTaxData(
              employeeData, selectedYear.value, selectedMonth.value)
          .then((value) {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final data = incomeTaxDataFromJson(value.body);
          incomeTaxData = data;
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

  fetchFormulaData(String payId,String componentId ) async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await payslipProvider
          .getFormulaData(
              employeeData, payId,componentId)
          .then((value) {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final data = payslipPopupDataFromJson(value.body);
          payslipPopupData = data;
        }
      });
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error,st) {
      loading.value = Loading.loaded;
      print('err ${error.toString()}');
      print(st.toString());
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  void openFreshchat() {
    // Open the Freshchat chat interface
    // Freshchat.showConversations();
  }

  @override
  void onInit() {
    super.onInit();
    bannerItems.value = [
      NetPayCard(
        daysWorked: '28',
        monthYear: 'Jan 2025',
        amount: '1,51,500',
        percentageChange: 0.1,
        bankAccountNumber: '****7890',
        bankName: 'HDFC Bank',
      ),
    ];
  }

  Future<UserData?>? getUserData() async {
    userData = appStateController.userData.value;
    userProfile = appStateController.userProfileData.value;

    return userData;
  }

  void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.deepPurple,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
    )..show(
        context: Get.context!,
      );
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "SwipeArea",
        keyTarget: swipeAreaKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Swipe Left or Right",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22),
                ),
                SizedBox(height: 8),
                Text(
                  "👈 Swipe left to view the previous month\n👉 Swipe right for the next month",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          )
        ],
      )
    ];
  }

  @override
  void dispose() {
    Get.delete<PayslipPageController>();
    super.dispose();
  }
}
