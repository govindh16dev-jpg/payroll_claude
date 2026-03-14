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
import '../data/models/tax_dropdown.dart';
import '../data/repository/tax_provider.dart';

class TaxPageController extends GetxController {

  final GlobalKey<ScaffoldState> drawerKeyTax= GlobalKey<ScaffoldState>();
  var loading = Loading.initial.obs;
  final TaxProvider taxProvider = Get.put(TaxProvider());
  final appStateController = Get.put(AppStates());
  UserData userData = UserData();
  RxBool isMasked = true.obs;
  List<FinancialDropDown> taxYears = [];
  var selectedYear = FinancialDropDown().obs;
  final PageController pageController = PageController(initialPage: 1);
  var hasPageInitialized = false.obs;
  GlobalKey swipeAreaKey = GlobalKey();
  RxList<dynamic> taxData = [].obs;
  RxList<Map<String, dynamic>> grossSalaryData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> taxableIncomeData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> taxPayableData = <Map<String, dynamic>>[].obs;

  RxList propertiesData = [].obs;
  RxList sortedEarnings = [].obs;
  final RxList<bool> isExpanded = [false, false].obs; // Tracks expansion state
  var totals = TaxTotals().obs;
  var taxCardData = TaxCardData().obs;

  void toggleExpanded(int index) {
    isExpanded[index] = !isExpanded[index];
  }

  @override
  void onReady() {
    super.onReady();
    getUserData()?.then((userData) {
      if (userData?.user != null) {
        getTaxDropDownData();
      }
    });
  }

  onSwipeLeft() {
    var appTheme = Get.find<ThemeController>().currentTheme;
    int selectedIndex = taxYears.indexOf(selectedYear.value);
    if (selectedIndex < taxYears.length - 1) {
      int decreasedIndex = selectedIndex+1;
      selectedYear.value = taxYears[decreasedIndex];
      fetchTaxData();
    }else{
      appSnackBar(data: 'No more tax data !', color: appTheme.green);
    }
  }

  onSwipeRight() {
    var appTheme = Get.find<ThemeController>().currentTheme;
    int selectedIndex = taxYears.indexOf(selectedYear.value);
    if (selectedIndex > 0) {
      int decreasedIndex = selectedIndex-1;
      selectedYear.value = taxYears[decreasedIndex];
      fetchTaxData();
    }else{
      appSnackBar(data: 'No more tax data !', color: appTheme.green);
    }
  }

  Future<void> openBase64Pdf(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Tax_${selectedYear.value.financialLabel }.pdf');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error opening PDF: $e');
    }
    //   <key>LSApplicationQueriesSchemes</key>
    // <array>
    //   <string>pdf</string>
    // </array>
    //On iOS: You may need to add the following to ios/Runner/Info.plist:
  }

  getTaxDropDownData() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await taxProvider.getTaxDropdown(employeeData).then((dropdownData) {
        loading.value = Loading.loaded;
        final responseData = jsonDecode(dropdownData.body);
        List<FinancialDropDown>? yearsData;
        if (responseData['success'] == true) {
          final data = taxDropdownDataFromJson(dropdownData.body);
          yearsData = data.data!.financialDropDown!;
        }
        taxYears = yearsData!;
        selectedYear.value =
            taxYears.isNotEmpty ? taxYears.first : FinancialDropDown();
      });
      fetchTaxData();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  fetchTaxPdf() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await taxProvider
          .downloadTaxPdf(employeeData,   int.parse(selectedYear.value.companyFinancialYearId ?? '2'))
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

  fetchTaxData() async {
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
      await taxProvider
          .getTaxData(employeeData,
              int.parse(selectedYear.value.companyFinancialYearId ?? '2'))
          .then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          taxData.value = responseData['data']['tax_computation'];
          var grossSalaryList = taxData[1];
          var taxableIncomeList = taxData[2];
          grossSalaryData.clear();
          taxableIncomeData.clear();
          taxPayableData.clear();
          totals.value = TaxTotals();
          for (var component in grossSalaryList) {
            grossSalaryData.add(component);
          }
          var taxableIncome =
              taxableIncomeList.take(10).toList(); // first 9 are tax income
          for (var component in taxableIncome) {
            if (component['actual_property_key'] == 'tax_gross_salary') {
              totals.value.totalGrossSalary = component['total'];
            } else {
              taxableIncomeData.add(component);
            }
            if (component['actual_property_key'] ==
                'tax_taxable_income_round') {
              totals.value.totalTaxIncome = component['total'];
            }
          }
          var taxPayable = taxableIncomeList.skip(10).toList();
          for (var component in taxPayable) {
            taxPayableData.add(component);
            if (component['actual_property_key'] == 'tax_total_tax_payable') {
              totals.value.totalTaxPayable = component['total'];
            }
            if (component['actual_property_key'] == 'tax_balance_tax_payable') {
              totals.value.balanceTax = component['total'];
            }
            if (component['actual_property_key'] == 'current_month_tax') {
              totals.value.monthlyTaxPaid = component['total'];
            }
            if (component['actual_property_key'] == 'tax_recovered') {
              totals.value.taxPaidTillNow = component['total'];
            }
          }
        }
      });
      loading.value = Loading.loaded;
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
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
    Get.delete<TaxPageController>();
    super.dispose();
  }
}
