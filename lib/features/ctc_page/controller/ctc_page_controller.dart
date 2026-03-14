import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:payroll/features/login/domain/model/login_model.dart';

import '../../../routes/app_pages.dart';
import '../../../theme/theme_controller.dart';
import '../../profile_page/data/model/profile_model.dart';
import '../data/models/ctc_dropdown.dart';
import '../data/repository/ctc_provider.dart';

class CTCPageController extends GetxController {

  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  var loading = Loading.initial.obs;
  final CTCProvider ctcProvider = Get.put(CTCProvider());
  final appStateController = Get.put(AppStates());
  UserData userData = UserData();
  RxBool isMasked = true.obs;
  List<FinancialDropDown> taxYears = [];
  var selectedYear = FinancialDropDown().obs;
  final PageController pageController = PageController(initialPage: 1);

  // CTC specific data observables
  RxList<dynamic> ctcData = [].obs;
  RxMap<String, dynamic> employeeInfo = <String, dynamic>{}.obs;
  RxList<dynamic> earningsComponents = [].obs;
  RxList<dynamic> employerContributions = [].obs;
  RxMap<String, String> ctcTotals = <String, String>{}.obs;
  final RxList<bool> isExpanded = [false, false].obs;
  var hasPageInitialized = false.obs;
  GlobalKey swipeAreaKey = GlobalKey();

  void toggleMasked() {
    isMasked.value = !isMasked.value;
  }

  void toggleExpanded(int index) {
    isExpanded[index] = !isExpanded[index];
  }
  @override
  void onReady() {
    super.onReady();
    getUserData()?.then((userData) {
      if (userData?.user != null) {
        getDropDownData();
      }
    });
  }

  onSwipeLeft() {
    var appTheme = Get.find<ThemeController>().currentTheme;
    int selectedIndex = taxYears.indexOf(selectedYear.value);
    if (selectedIndex < taxYears.length - 1) {
      int decreasedIndex = selectedIndex + 1;
      selectedYear.value = taxYears[decreasedIndex];
      fetchCTCData();
    } else {
      appSnackBar(data: 'No more CTC data!', color: appTheme.green);
    }
  }

  onSwipeRight() {
    var appTheme = Get.find<ThemeController>().currentTheme;
    int selectedIndex = taxYears.indexOf(selectedYear.value);
    if (selectedIndex > 0) {
      int decreasedIndex = selectedIndex - 1;
      selectedYear.value = taxYears[decreasedIndex];
      fetchCTCData();
    } else {
      appSnackBar(data: 'No more CTC data!', color: appTheme.green);
    }
  }

  Future<void> openBase64Pdf(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/CTC_${selectedYear.value.financialLabel}.pdf');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }

  getDropDownData() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);

      await ctcProvider.getTaxDropdown(employeeData).then((dropdownData) {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(dropdownData.body);
        List<FinancialDropDown>? yearsData;
        if (responseData['success'] == true) {
          final data = taxDropdownDataFromJson(dropdownData.body);
          yearsData = data.data!.financialDropDown!;
        }
        taxYears = yearsData!;
        selectedYear.value = taxYears.isNotEmpty ? taxYears.first : FinancialDropDown();
      });
      fetchCTCData();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  fetchCTCData() async {
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

      await ctcProvider
          .getCTCData(employeeData, int.parse(selectedYear.value.companyFinancialYearId ?? '2'))
          .then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          // Process employee info
          if (responseData['data']['employee_info'] != null &&
              responseData['data']['employee_info'].isNotEmpty) {
            employeeInfo.value = responseData['data']['employee_info'][0];
          }

          // Process salary compensation
          ctcData.value = responseData['data']['salary_compensation'];
          _processCTCComponents();
        }
      });
      loading.value = Loading.loaded;
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  fetchCTCPdf() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await ctcProvider
          .downloadCTC(employeeData)
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

  void _processCTCComponents() {
    earningsComponents.clear();
    employerContributions.clear();
    ctcTotals.clear();

    for (var component in ctcData) {
      if (component['component_type'] == 'Earnings' &&
          component['component_key'] != 'Gross_Salary') {
        earningsComponents.add(component);
      } else if (component['component_type'] == 'Employer_Contribution') {
        employerContributions.add(component);
      } else if (component['component_key'] == 'Gross_Salary') {
        ctcTotals['gross_yearly'] = component['amount'];
        ctcTotals['gross_monthly'] = component['monthly_amount'];
      } else if (component['component_key'] == 'ctc') {
        ctcTotals['ctc_yearly'] = component['amount'];
        ctcTotals['ctc_monthly'] = component['monthly_amount'];
      }
    }

    // Calculate employer contribution totals
    double yearlyTotal = 0;
    double monthlyTotal = 0;
    for (var contribution in employerContributions) {
      yearlyTotal += double.parse(contribution['amount'].replaceAll(',', ''));
      monthlyTotal += double.parse(contribution['monthly_amount'].replaceAll(',', ''));
    }
    ctcTotals['employer_yearly'] = _formatAmount(yearlyTotal);
    ctcTotals['employer_monthly'] = _formatAmount(monthlyTotal);
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    );
  }

  String getFormattedEmployeeName() {
    if (employeeInfo.isEmpty) return '';
    return '${employeeInfo['employee_name'] ?? ''} (${employeeInfo['employee_no'] ?? ''})';
  }

  String getEmployeeDesignationDepartment() {
    if (employeeInfo.isEmpty) return '';
    return '${employeeInfo['designation'] ?? ''} | ${employeeInfo['department'] ?? ''}';
  }

  String getFormattedDOB() {
    if (employeeInfo.isEmpty) return '';
    return 'DOB: ${employeeInfo['dob'] ?? ''}';
  }

  String getFormattedDOJ() {
    if (employeeInfo.isEmpty) return '';
    return 'DOJ: ${employeeInfo['doj'] ?? ''}';
  }

  String getMaskedAmount(String amount) {
    if (isMasked.value) {
      int commaCount = amount.split(',').length - 1;
      return '*****';
    }
    return amount;
  }

  void openFreshchat() {
    // Open the Freshchat chat interface
    // Freshchat.showConversations();
  }

  Future<UserData?>? getUserData() async {
    userData = appStateController.userData.value;
    return userData;
  }

  @override
  void dispose() {
    Get.delete<CTCPageController>();
    super.dispose();
  }
}
