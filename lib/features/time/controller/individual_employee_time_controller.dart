import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../login/domain/model/login_model.dart';
import '../../time/data/repository/time_provider.dart';
import '../../../routes/app_pages.dart';

class IndividualEmployeeTimeController extends GetxController {
  final TimeProvider timeProvider = TimeProvider();
  UserData userData = UserData();

  var loading = false.obs;
  var detailsLoading = false.obs;
  var selectedEmployee = Rx<Map<String, String>>({});
  var fromDate = Rx<DateTime?>(null);
  var toDate = Rx<DateTime?>(null);

  // Employee dropdown list - fetched from API
  final RxList<Map<String, String>> employeeList = <Map<String, String>>[].obs;

  // Shift tabs from API response
  final RxList<Map<String, String>> shiftTabs = <Map<String, String>>[].obs;
  var selectedShiftIndex = 0.obs;

  // Employee time details from API response
  final RxList<Map<String, dynamic>> empTimeDetails = <Map<String, dynamic>>[].obs;

  // Map: shiftId -> alloted time range key (e.g. "09:00 AM|06:00 PM")
  final Map<String, String> _shiftTimeMapping = {};

  /// Get filtered time details based on selected shift tab
  List<Map<String, dynamic>> get filteredTimeDetails {
    if (shiftTabs.isEmpty || empTimeDetails.isEmpty) return [];

    final selectedShift = shiftTabs[selectedShiftIndex.value];
    final shiftId = selectedShift['shiftId'] ?? '';

    if (shiftId == 'all') return empTimeDetails;

    // Filter by matching alloted time range
    final timeKey = _shiftTimeMapping[shiftId];
    if (timeKey == null) return [];

    return empTimeDetails.where((detail) {
      final detailKey = '${detail['alloted_start_time']}|${detail['alloted_end_time']}';
      return detailKey == timeKey;
    }).toList();
  }

  String get formattedFromDate => fromDate.value != null
      ? DateFormat('dd/MM/yyyy').format(fromDate.value!)
      : 'Select Date';

  String get formattedToDate => toDate.value != null
      ? DateFormat('dd/MM/yyyy').format(toDate.value!)
      : 'Select Date';

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    try {
      const storage = FlutterSecureStorage();
      String? userDataString = await storage.read(key: 'userData');
      if (userDataString != null) {
        userData = UserData.fromJson(jsonDecode(userDataString));
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }

    // Set default date range to current month
    final now = DateTime.now();
    fromDate.value = DateTime(now.year, now.month, 1);
    toDate.value = DateTime(now.year, now.month + 1, 0);

    // Fetch employee dropdown from API
    await fetchEmployeeDropdown();
  }

  /// Fetch employee dropdown from API
  Future<void> fetchEmployeeDropdown() async {
    loading.value = true;
    try {
      final fromDateStr = fromDate.value != null
          ? DateFormat('yyyy-MM-dd').format(fromDate.value!)
          : '';
      final toDateStr = toDate.value != null
          ? DateFormat('yyyy-MM-dd').format(toDate.value!)
          : '';

      final response = await timeProvider.getEmployeeDropdown(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        fromDate: fromDateStr,
        toDate: toDateStr,
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true &&
          responseData['data'] != null &&
          responseData['data']['dropdown'] != null) {
        final List<dynamic> dropdownData = responseData['data']['dropdown'];

        final List<Map<String, String>> newEmployeeList = [];

        for (var item in dropdownData) {
          newEmployeeList.add({
            'empId': item['employee_id']?.toString() ?? '',
            'empName': item['employee_name']?.toString() ?? '',
            'empNo': item['employee_no']?.toString() ?? '',
          });
        }

        employeeList.assignAll(newEmployeeList);

        // Set default selected employee & fetch details
        if (employeeList.isNotEmpty) {
          selectedEmployee.value = employeeList.first;
          await fetchEmployeeDetails();
        }
      }
    } on CustomException catch (err) {
      debugPrint("fetchEmployeeDropdown CustomException: ${err.message}");
    } catch (e, s) {
      debugPrint("fetchEmployeeDropdown Error: $e $s");
    } finally {
      loading.value = false;
    }
  }

  /// Fetch employee details (time records + shift info) from API
  Future<void> fetchEmployeeDetails() async {
    if (selectedEmployee.value.isEmpty) return;

    detailsLoading.value = true;
    try {
      final fromDateStr = fromDate.value != null
          ? DateFormat('yyyy-MM-dd').format(fromDate.value!)
          : '';
      final toDateStr = toDate.value != null
          ? DateFormat('yyyy-MM-dd').format(toDate.value!)
          : '';

      final response = await timeProvider.getEmployeeDetails(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        requestEmployeeId: selectedEmployee.value['empId'] ?? '',
        fromDate: fromDateStr,
        toDate: toDateStr,
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        // Parse emp_time_details
        final List<dynamic> details = responseData['data']['emp_time_details'] ?? [];
        empTimeDetails.assignAll(
          details.map((e) => Map<String, dynamic>.from(e)).toList(),
        );

        // Parse shift_details and build tabs
        final List<dynamic> shifts = responseData['data']['shift_details'] ?? [];
        _buildShiftTabs(shifts);
      } else {
        empTimeDetails.clear();
        shiftTabs.assignAll([
          {'shiftId': 'all', 'shiftName': 'All'},
        ]);
      }
    } on CustomException catch (err) {
      debugPrint("fetchEmployeeDetails CustomException: ${err.message}");
    } catch (e, s) {
      debugPrint("fetchEmployeeDetails Error: $e $s");
    } finally {
      detailsLoading.value = false;
    }
  }

  /// Build shift tabs and map shift IDs to alloted time ranges
  void _buildShiftTabs(List<dynamic> shiftDetails) {
    _shiftTimeMapping.clear();

    // Analyze emp_time_details to find unique alloted time ranges
    final Map<String, Set<String>> timeRangeToShiftGuess = {};
    for (var detail in empTimeDetails) {
      final startTime = detail['alloted_start_time']?.toString() ?? '';
      final endTime = detail['alloted_end_time']?.toString() ?? '';
      final timeKey = '$startTime|$endTime';
      timeRangeToShiftGuess.putIfAbsent(timeKey, () => {});
    }

    // Build shift tab list with "All" first
    final List<Map<String, String>> tabs = [
      {'shiftId': 'all', 'shiftName': 'All'},
    ];

    // Get unique alloted time ranges
    final uniqueTimeRanges = timeRangeToShiftGuess.keys.toList();

    // Map shifts to time ranges
    // Strategy: if we have the same number of shifts and unique time ranges,
    // map them in order. Otherwise, use shift_details as-is for tabs.
    for (var shift in shiftDetails) {
      final shiftId = shift['shift_id']?.toString() ?? '';
      final shiftName = shift['shift_name']?.toString() ?? '';
      tabs.add({
        'shiftId': shiftId,
        'shiftName': shiftName,
      });
    }

    // Try to map shift IDs to time ranges by analyzing data
    // Group records by their alloted time range
    final Map<String, List<Map<String, dynamic>>> recordsByTimeRange = {};
    for (var detail in empTimeDetails) {
      final startTime = detail['alloted_start_time']?.toString() ?? '';
      final endTime = detail['alloted_end_time']?.toString() ?? '';
      final timeKey = '$startTime|$endTime';
      recordsByTimeRange.putIfAbsent(timeKey, () => []);
      recordsByTimeRange[timeKey]!.add(detail);
    }

    // Assign each unique time range to a shift
    // Sort time ranges and shifts, then map them
    if (shiftDetails.length == uniqueTimeRanges.length) {
      // Direct mapping by order
      for (int i = 0; i < shiftDetails.length; i++) {
        final shiftId = shiftDetails[i]['shift_id']?.toString() ?? '';
        _shiftTimeMapping[shiftId] = uniqueTimeRanges[i];
      }
    } else {
      // Best-effort mapping based on common patterns
      // The "Leave" shift is likely "12:00 AM|12:00 AM"
      // Other shifts map to actual work schedules
      final leaveTimeKey = '12:00 AM|12:00 AM';
      final workTimeRanges = uniqueTimeRanges.where((k) => k != leaveTimeKey).toList();
      int workIndex = 0;

      for (var shift in shiftDetails) {
        final shiftId = shift['shift_id']?.toString() ?? '';
        final shiftName = (shift['shift_name']?.toString() ?? '').toLowerCase();

        if (shiftName.contains('leave') && uniqueTimeRanges.contains(leaveTimeKey)) {
          _shiftTimeMapping[shiftId] = leaveTimeKey;
        } else if (workIndex < workTimeRanges.length) {
          _shiftTimeMapping[shiftId] = workTimeRanges[workIndex];
          workIndex++;
        }
      }
    }

    shiftTabs.assignAll(tabs);
    selectedShiftIndex.value = 0; // Default to "All"
  }

  /// Format date from API (yyyy-MM-dd) to display format (dd/MM/yyyy)
  String formatApiDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (fromDate.value ?? DateTime.now())
          : (toDate.value ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (isFromDate) {
        fromDate.value = picked;
      } else {
        toDate.value = picked;
      }
      // Re-fetch when date changes
      await fetchEmployeeDropdown();
    }
  }

  void selectEmployee(Map<String, String> employee) {
    selectedEmployee.value = employee;
    // Fetch details for the newly selected employee
    fetchEmployeeDetails();
  }

  void selectShiftTab(int index) {
    selectedShiftIndex.value = index;
  }
}
