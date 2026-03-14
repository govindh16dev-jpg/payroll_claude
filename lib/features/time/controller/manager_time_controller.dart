import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:payroll/features/login/domain/model/login_model.dart';
import 'package:payroll/routes/app_route.dart';

import '../../../routes/app_pages.dart';

import '../data/manager_regularize_model.dart';
import '../data/manager_time_stats_model.dart';
import '../data/repository/time_provider.dart';
import '../views/widgets.dart';
import '../views/widgets/stats_dialog.dart';
import '../views/widgets/team_attendance_details_popup.dart';
import '../views/widgets/time_items.dart';

class ManagerTimeController extends GetxController {
  var loading = false.obs;
  var expandedIndex = RxnInt();
  var isManagerView = true.obs; // Toggle between Manager and Employee view
  var selectedDate = DateTime.now().obs;

  final TimeProvider timeProvider = TimeProvider();
  UserData userData = UserData();

  // Team attendance data - Populated from API
  final RxList<Map<String, String>> teamAttendanceList = <Map<String, String>>[].obs;

  // Dashboard stats data - now reactive for API updates
  final RxMap<String, String> statsData = <String, String>{
    'Full Hours': '0',
    'Extended Breaks': '0',
    'Leave': '0',
    'On-time(Entry)': '0',
    'On-time(Exit)': '0',
    'Late Entry': '0',
    'Late Exit': '0',
    'Short Hours': '0',
    'Over Time': '0',
  }.obs;

  String get formattedDate => DateFormat('dd/MM/yyyy').format(selectedDate.value);

  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = null;
    } else {
      expandedIndex.value = index;
    }
  }

  void toggleView(bool value) {
    isManagerView.value = value;
    if (!value) {
      // Navigate to employee time page
      Get.back(); // or Get.toNamed('/employee-time');
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      // Refresh data based on selected date
      await fetchData();
    }
  }

  void showStatsDialog(String title) async {
    loading.value = true;
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final statusKey = _getStatusKey(title);

      final response = await timeProvider.getStatsPopup(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        fromDate: dateStr,
        toDate: dateStr,
        statusKey: statusKey,
      );

      final responseData = jsonDecode(response.body);
      List<Map<String, String>> data = [];

      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> timeDetails = responseData['data']['time_details'] ?? [];
        data = timeDetails.map((item) {
          return <String, String>{
            'empId': item['employee_no']?.toString() ?? '',
            'empName': item['employee_name']?.toString() ?? '',
            'shiftStarts': item['alloted_start_time']?.toString() ?? '--',
            'entry': item['actual_start_time']?.toString() ?? '--',
          };
        }).toList();
      }

      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(0),
          child: StatsDialog(title: title, data: data),
        ),
      );
    } on CustomException catch (err) {
      debugPrint("showStatsDialog CustomException: ${err.message}");
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, s) {
      debugPrint("showStatsDialog Error: $e $s");
      appSnackBar(data: "Something went wrong", color: AppColors.appRedColor);
    } finally {
      loading.value = false;
    }
  }

  /// Map display title to API status_key
  String _getStatusKey(String title) {
    switch (title) {
      case 'Full Hours':
        return 'full_hours';
      case 'Extended Breaks':
        return 'extended_breaks';
      case 'Leave':
        return 'leave';
      case 'On-time(Entry)':
        return 'on_time_entry';
      case 'On-time(Exit)':
        return 'on_time_exit';
      case 'Late Entry':
        return 'late_entry';
      case 'Late Exit':
        return 'late_exit';
      case 'Short Hours':
        return 'short_hours';
      case 'Over Time':
        return 'over_time';
      default:
        return title.toLowerCase().replaceAll(' ', '_');
    }
  }

  void navigateToEmployeeSelectionPage() {
    // Navigate to individual employee time details page
    Get.toNamed(AppRoutes.individualEmployeeTimePage); // or your route
  }

  void navigateToShiftDetailsPage() {
    // Navigate to shift details page
    Get.toNamed(AppRoutes.shiftWiseFilterPage); // or your route
  }

  void showAttendanceDetails(Map<String, String> item) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(0),
        child: TeamAttendanceDetailsPopup(item: item),
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    _initUserDataAndFetch();
  }

  /// Load user data from secure storage and then fetch stats
  Future<void> _initUserDataAndFetch() async {
    try {
      const storage = FlutterSecureStorage();
      String? userDataString = await storage.read(key: 'userData');
      if (userDataString != null) {
        userData = UserData.fromJson(jsonDecode(userDataString));
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
    await fetchData();
  }

  Future<void> fetchData() async {
    loading.value = true;
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

      // 1. Fetch Stats
      final statsResponse = await timeProvider.getManagerTimeStats(
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        clientId: userData.user?.clientId ?? '',
        fromDate: dateStr,
      );

      final statsDataJson = jsonDecode(statsResponse.body);
      if (statsDataJson['success'] == true && statsDataJson['data'] != null) {
        final model = ManagerTimeStatsModel.fromJson(statsDataJson['data']);
        statsData.assignAll(model.toStatsMap());
      }

      // 2. Fetch Regularize List (Action Needed)
      final regResponse = await timeProvider.getManagerRegularizeList(
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        clientId: userData.user?.clientId ?? '',
      );

      final regDataJson = jsonDecode(regResponse.body);
      if (regDataJson['success'] == true &&
          regDataJson['data'] != null &&
          regDataJson['data']['emp_view_details'] != null) {
        
        final List<dynamic> listProxy = regDataJson['data']['emp_view_details'];
        final List<Map<String, String>> newList = [];
        
        for (var item in listProxy) {
          final model = ManagerRegularizeModel.fromJson(item);
          newList.add(model.toUiMap());
        }
        
        teamAttendanceList.assignAll(newList);
      }

    } on CustomException catch (err) {
      debugPrint("fetchData CustomException: ${err.message}");
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, s) {
      debugPrint("fetchData Error: $e $s");
    } finally {
      loading.value = false;
    }
  }

  Future<void> approveRequest(Map<String, String> item) async {
    final result = await showTimeActionConfirmationDialog(
      item['empName'] ?? 'Employee',
      true,
    );
    if (result != null && result['confirmed'] == true) {
      await updateRequestStatus("approved", item, remarks: result['remarks'] ?? '');
    }
  }

  Future<void> rejectRequest(Map<String, String> item) async {
    final result = await showTimeActionConfirmationDialog(
      item['empName'] ?? 'Employee',
      false,
    );
    if (result != null && result['confirmed'] == true) {
      await updateRequestStatus("rejected", item, remarks: result['remarks'] ?? '');
    }
  }

  Future<void> updateRequestStatus(String status, Map<String, String> item, {String remarks = ''}) async {
    loading.value = true;
    try {
      final response = await timeProvider.postManagerAction(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        timeStatus: status,
        empTimeId: item['empTimeId'] ?? '',
        requestEmployeeId: item['systemEmployeeId'] ?? '',
        managerRemarks: remarks,
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        String message = "Status Updated Successfully";
        if (responseData['data'] != null &&
            responseData['data']['emp_view_details'] != null &&
            responseData['data']['emp_view_details'].isNotEmpty) {
          message = responseData['data']['emp_view_details'][0]['message'] ?? message;
        }
        
        appSnackBar(data: message, color: Colors.green);
        
        // Refresh the list to remove the item or update status
        await fetchData();
      } else {
        appSnackBar(data: responseData['message'] ?? "Failed to update status", color: AppColors.appRedColor);
      }
    } on CustomException catch (err) {
      debugPrint("updateRequestStatus CustomException: ${err.message}");
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, s) {
      debugPrint("updateRequestStatus Error: $e $s");
      appSnackBar(data: "Something went wrong", color: AppColors.appRedColor);
    } finally {
      loading.value = false;
    }
  }
  Future<void> fetchRouteList(Map<String, String> item) async {
    loading.value = true;
    try {
      String dateStr = item['date'] ?? '';
      if (dateStr.isNotEmpty) {
        try {
          DateTime parsedDate;
          if (dateStr.contains('T')) {
            parsedDate = DateTime.parse(dateStr);
          } else if (dateStr.contains('-') && dateStr.length == 10) {
            parsedDate = DateTime.parse(dateStr);
          } else {
            parsedDate = DateFormat('dd-MMM-yyyy').parse(dateStr);
          }
          dateStr = DateFormat('yyyy-MM-dd').format(parsedDate);
        } catch (e) {
          debugPrint("Date parse error: $e, using as-is: $dateStr");
        }
      } else {
        dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      }

      final response = await timeProvider.getRouteList(
        clientId:          userData.user?.clientId ?? '',
        companyId:         userData.user?.companyId ?? '',
        requestEmployeeId: item['systemEmployeeId'] ?? '',
        fromDate:          dateStr,
        toDate:            dateStr,
      );

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> geoDetailsList =
            responseData['data']['geo_details'] ?? [];

        // ── Navigate to read-only route view ──────────────────────────────
        Get.toNamed(
          AppRoutes.managerRouteViewPage,
          arguments: {
            'geoDetails': geoDetailsList,
            'empName':    item['empName'] ?? 'Employee',
            'date':       dateStr,
          },
        );
      } else {
        appSnackBar(
          data:  responseData['message'] ?? 'No route data available',
          color: AppColors.appRedColor,
        );
      }
    } on CustomException catch (err) {
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, s) {
      debugPrint("fetchRouteList Error: $e $s");
      appSnackBar(data: "Something went wrong", color: AppColors.appRedColor);
    } finally {
      loading.value = false;
    }
  }

  // /// Fetch route list (geo details) for a specific employee time entry
  // Future<void> fetchRouteList(Map<String, String> item) async {
  //   loading.value = true;
  //   try {
  //     // Format date for API (needs yyyy-MM-dd)
  //     String dateStr = item['date'] ?? '';
  //     if (dateStr.isNotEmpty) {
  //       try {
  //         // Try parsing various date formats to yyyy-MM-dd
  //         DateTime parsedDate;
  //         if (dateStr.contains('T')) {
  //           parsedDate = DateTime.parse(dateStr);
  //         } else if (dateStr.contains('-') && dateStr.length == 10) {
  //           // Already yyyy-MM-dd
  //           parsedDate = DateTime.parse(dateStr);
  //         } else {
  //           // Try dd-MMM-yyyy format
  //           parsedDate = DateFormat('dd-MMM-yyyy').parse(dateStr);
  //         }
  //         dateStr = DateFormat('yyyy-MM-dd').format(parsedDate);
  //       } catch (e) {
  //         debugPrint("Date parse error: $e, using as-is: $dateStr");
  //       }
  //     } else {
  //       dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
  //     }
  //
  //     final response = await timeProvider.getRouteList(
  //       clientId: userData.user?.clientId ?? '',
  //       companyId: userData.user?.companyId ?? '',
  //       requestEmployeeId: item['systemEmployeeId'] ?? '',
  //       fromDate: dateStr,
  //       toDate: dateStr,
  //     );
  //
  //     final responseData = jsonDecode(response.body);
  //     if (responseData['success'] == true && responseData['data'] != null) {
  //       final List<dynamic> geoDetailsList = responseData['data']['geo_details'] ?? [];
  //       final List<Map<String, dynamic>> geoDetails =
  //           geoDetailsList.map((e) => Map<String, dynamic>.from(e)).toList();
  //
  //       showRouteListPopup(geoDetails, item['empName'] ?? 'Employee');
  //     } else {
  //       appSnackBar(
  //         data: responseData['message'] ?? 'No route data available',
  //         color: AppColors.appRedColor,
  //       );
  //     }
  //   } on CustomException catch (err) {
  //     debugPrint("fetchRouteList CustomException: ${err.message}");
  //     appSnackBar(data: err.message, color: AppColors.appRedColor);
  //   } catch (e, s) {
  //     debugPrint("fetchRouteList Error: $e $s");
  //     appSnackBar(data: "Something went wrong", color: AppColors.appRedColor);
  //   } finally {
  //     loading.value = false;
  //   }
  // }
}
