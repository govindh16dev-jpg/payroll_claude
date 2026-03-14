import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../login/domain/model/login_model.dart';
import '../../time/data/repository/time_provider.dart';
import '../../time/data/shift_filter_model.dart';
import '../../time/data/shift_detail_model.dart';
import '../../../routes/app_pages.dart';

class ShiftFilterController extends GetxController {
  final TimeProvider timeProvider = Get.put(TimeProvider());
  UserData userData = UserData();

  var loading = false.obs;
  var selectedShift = Rx<Map<String, String>>({});
  var fromDate = Rx<DateTime?>(DateTime.now().subtract(const Duration(days: 15)));
  var toDate = Rx<DateTime?>(DateTime.now());

  // Shift dropdown list with "All" option
  final RxList<Map<String, String>> shiftList = <Map<String, String>>[
    {
      'shiftId': 'all',
      'shiftTime': 'All',
      'shiftName': 'All Shifts',
    },
  ].obs;

  // Employee shift details data
  final RxList<Map<String, String>> employeeShiftList = <Map<String, String>>[].obs;

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
    
    // Fetch dropdown
    await fetchShiftDropdown();
    
    // Set default shift to "All" initially
    if (shiftList.isNotEmpty) {
      selectedShift.value = shiftList.first; // "All" is always first
    }
    
    // Set date range to current month
    final now = DateTime.now();
    fromDate.value = DateTime(now.year, now.month, 1);
    toDate.value = DateTime(now.year, now.month + 1, 0); // Last day of current month
    await fetchShiftDetails();
  }

  Future<void> fetchShiftDetails() async {
    loading.value = true;
    try {
      final fromDateStr = fromDate.value != null 
          ? DateFormat('yyyy-MM-dd').format(fromDate.value!) 
          : '';
      final toDateStr = toDate.value != null 
          ? DateFormat('yyyy-MM-dd').format(toDate.value!) 
          : '';
      
      final String shiftId = selectedShift.value['shiftId'] ?? 'all';

      if (shiftId == 'all') {
        // "All" selected: API requires shift_id, so call once per shift and merge
        final List<Map<String, String>> allResults = [];
        
        for (var shift in shiftList) {
          if (shift['shiftId'] == 'all') continue; // Skip the "All" entry
          
          try {
            final response = await timeProvider.getShiftDetails(
              clientId: userData.user?.clientId ?? '',
              companyId: userData.user?.companyId ?? '',
              employeeId: userData.user?.employeeId ?? '',
              shiftId: shift['shiftId'] ?? '',
              fromDate: fromDateStr,
              toDate: toDateStr,
            );

            final responseData = jsonDecode(response.body);
            if (responseData['success'] == true &&
                responseData['data'] != null &&
                responseData['data']['shift_details'] != null) {
              final List<dynamic> details = responseData['data']['shift_details'];
              for (var item in details) {
                final model = ShiftDetailModel.fromJson(item);
                allResults.add(model.toUiMap(
                  overrideShiftId: shift['shiftId'],
                  overrideShiftName: shift['shiftTime'] ?? shift['shiftName'] ?? '',
                ));
              }
            }
          } catch (e) {
            debugPrint("fetchShiftDetails for shift ${shift['shiftId']} Error: $e");
          }
        }
        
        employeeShiftList.assignAll(allResults);
      } else {
        // Specific shift selected: call API once
        final response = await timeProvider.getShiftDetails(
          clientId: userData.user?.clientId ?? '',
          companyId: userData.user?.companyId ?? '',
          employeeId: userData.user?.employeeId ?? '',
          shiftId: shiftId,
          fromDate: fromDateStr,
          toDate: toDateStr,
        );

        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true &&
            responseData['data'] != null &&
            responseData['data']['shift_details'] != null) {
          final List<dynamic> details = responseData['data']['shift_details'];
          final List<Map<String, String>> newList = [];
          
          // Find shift name from shiftList
          final shiftName = selectedShift.value['shiftTime'] ?? 
                            selectedShift.value['shiftName'] ?? '';
          
          for (var item in details) {
            final model = ShiftDetailModel.fromJson(item);
            newList.add(model.toUiMap(
              overrideShiftId: shiftId,
              overrideShiftName: shiftName,
            ));
          }
          
          employeeShiftList.assignAll(newList);
        } else {
          employeeShiftList.clear();
        }
      }
    } on CustomException catch (err) {
      debugPrint("fetchShiftDetails CustomException: ${err.message}");
    } catch (e, s) {
      debugPrint("fetchShiftDetails Error: $e $s");
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchShiftDropdown() async {
    loading.value = true;
    try {
      final fromDateStr = fromDate.value != null 
          ? DateFormat('yyyy-MM-dd').format(fromDate.value!) 
          : '';
      final toDateStr = toDate.value != null 
          ? DateFormat('yyyy-MM-dd').format(toDate.value!) 
          : '';

      final response = await timeProvider.getShiftFilterDropdown(
        clientId: userData.user?.clientId ?? '',
        companyId: userData.user?.companyId ?? '',
        employeeId: userData.user?.employeeId ?? '',
        fromDate: fromDateStr,
        toDate: toDateStr,
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null && responseData['data']['dropdown'] != null) {
        final List<dynamic> dropdownData = responseData['data']['dropdown'];
        
        // Clear existing (except 'All')? Or just rebuild.
        // Let's rebuild to be safe
        final List<Map<String, String>> newShiftList = [
          {
            'shiftId': 'all',
            'shiftTime': 'All',
            'shiftName': 'All Shifts',
          }
        ];

        for (var item in dropdownData) {
          final model = ShiftFilterModel.fromJson(item);
          newShiftList.add(model.toUiMap());
        }
        
        shiftList.assignAll(newShiftList);
        
        // Reset selected if it's not in the list anymore?
        // Or keep 'All'
        if (selectedShift.value.isEmpty || !shiftList.any((s) => s['shiftId'] == selectedShift.value['shiftId'])) {
             selectedShift.value = shiftList.first;
        }
      }
    } on CustomException catch (err) {
      debugPrint("fetchShiftDropdown CustomException: ${err.message}");
      // appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (e, s) {
      debugPrint("fetchShiftDropdown Error: $e $s");
    } finally {
      loading.value = false;
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
      // Re-fetch dropdown when date changes
      fetchShiftDropdown();
      // Also fetch details
      fetchShiftDetails();
    }
  }

  void selectShift(Map<String, String> shift) {
    selectedShift.value = shift;
    // Fetch details for selected shift
    fetchShiftDetails();
  }
}
