import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:payroll/features/leave_page/controller/leave_page_controller.dart';
import 'package:payroll/features/leave_page/data/repository/leave_provider.dart';
import 'package:payroll/features/login/domain/model/login_model.dart';
import 'package:payroll/features/manager/model/check_delagate.dart';
import 'package:payroll/features/manager/model/leave_action.dart';
import 'package:payroll/features/manager/model/manager_delegate.dart';
import 'package:payroll/features/manager/model/managers_dropdown.dart';
import 'package:sizer/sizer.dart';

import '../../../routes/app_pages.dart';
import '../../../routes/app_route.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/custom_widgets.dart';
import '../../../util/getUserdata.dart';
import '../../leave_page/model/leave_model.dart';
import '../../profile_page/data/model/profile_model.dart';
import '../data/repository/manager_provider.dart';
import '../model/employee_leaves_list.dart';
import '../views/leaves_item.dart';

class ManagerPageController extends GetxController {
  var loading = Loading.initial.obs;
  late Future<void> _initDone;
  RxList sortedEarnings = [].obs;
  RxBool isHavingDelegate = false.obs;
  String currentDelegateId = '';
  RxList<LeavesDetail> leaveItems = [LeavesDetail()].obs;
  RxList<Calendar> teamLeaves = [Calendar()].obs;
  RxnInt expandedIndex = RxnInt();
  RxString offset = '0'.obs;
  final appStateController = Get.put(AppStates());
  UserData userData = UserData();
  RxBool isManager = false.obs;
  Rxn<DateTime?> fromDate = Rxn<DateTime?>();
  Rxn<DateTime?> toDate = Rxn<DateTime?>();
  Rxn<TimeOfDay?> fromDateStart = Rxn<TimeOfDay?>();
  Rxn<TimeOfDay?> fromDateEnd = Rxn<TimeOfDay?>();
  Rxn<TimeOfDay?> toDateStart = Rxn<TimeOfDay?>();
  Rxn<TimeOfDay?> toDateEnd = Rxn<TimeOfDay?>();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final LeaveProvider leaveProvider = Get.put(LeaveProvider());
  final ManagerProvider managerProvider = Get.put(ManagerProvider());
  final TextEditingController reasonController = TextEditingController();

  RxString selectedLeaveTypeID = "12".obs;
  RxString selectedDayTypeIDFromDate = "1".obs;
  RxString selectedDayTypeIDToDate = "1".obs;
  RxString selectedLeaveRemaining = "0".obs;
  RxString totalLeaveDays = "0".obs;

  List<Map<String, String?>>? employeeLeaveHistory;
  List<Map<String, String?>>? selectedDayLeaves;

  var selectedManager = ManagerData(
      employeeId: "", employeeName: "", dropDownId: "", employeeNo: "")
      .obs;
  var currentDelegateData = DelegateData().obs;
  RxList<ManagerData>? managerDropdownList = <ManagerData>[
    ManagerData(
        employeeId: "", employeeName: "", dropDownId: "", employeeNo: "")
  ].obs;
  final labelWidth = 20.w;
  final inputWidth = 40.w;

  void toggleExpanded(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = null;
    } else {
      expandedIndex.value = index;
    }
    notifyChildrens();
  }

  void setSelectedManager(String dropDownId) {
    final index =
    managerDropdownList?.indexWhere((doc) => doc.employeeId == dropDownId);
    if (index != null && index != -1) {
      selectedManager.value = managerDropdownList![index];
    } else {
      if (kDebugMode) {
        print("Manager type not found.");
      }
    }
  }

  void toggleSwitch(bool value) {
    isManager.value = value;
    if (!value) {
      if (Get.isRegistered<LeavePageController>()) {
        Get.delete<LeavePageController>();
      }
      Get.toNamed(AppRoutes.leavePage);
    }
  }

  @override
  void onInit() {
    super.onInit();
    employeeLeaveHistory = [
      {
        "type": "Sick Leave",
        "from": "20-Jan-25",
        "to": "23-Jan-25",
        "days": '3',
      },
      {
        "type": "Sick Leave",
        "from": "2-Feb-25",
        "to": "3-Feb-25",
        "days": '1',
      },
      {
        "type": "Causal Leave",
        "from": "13-Jun-25",
        "to": "14-Jun-25",
        "days": '2',
      },
      {
        "type": "Paternity Leave",
        "from": "11-Sep-25",
        "to": "16-Sep-25",
        "days": '5',
      },
    ];
    selectedDayLeaves = [
      {
        'empId': 'EMP00100',
        'name': 'Chandrasekar Ramasubramanian',
        'type': 'Sick Leave',
        'days': '3',
      },
      {
        'empId': 'EMP231100',
        'name':
        'Donald J Trump', // Fixed character encoding
        'type': 'Causal',
        'days': '1',
      },
      {
        'empId': 'EMP31130',
        'name': 'Malli Arjun Maddapli',
        'type': 'Sick Leave',
        'days': '1',
      },
      {
        'empId': 'EMP232100',
        'name': 'John Smith',
        'type': 'Sick Leave',
        'days': '5',
      },
    ];
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });

    _initDone = _init();
  }

  void filterAndSetLeaveHistory(String employeeNo) {
    List<Map<String, String?>> filteredLeaves = [];

    // Filter leaves_details from your JSON data for the specific employee
    for (var leave in leaveItems) {
      if (leave.employeeNo == employeeNo) {
        filteredLeaves.add({
          "type": leave.planTypeName,
          "from": leave.fromDateFormat,
          "to": leave.toDateFormat,
          "days": leave.noOfDays != null
              ? leave.noOfDays!.split('.')[0] // Remove decimal part
              : '0',
          // Optional: Add more fields if needed
          "leave_status": leave.leaveStatus,
          "from_date": leave.fromDateFormat,
          "plan_type_name": leave.planTypeName,
        });
      }
    }

    // Update the leaveHistory with filtered data
    employeeLeaveHistory = filteredLeaves;
    update(); // Notify listeners about the change
  }

  Future<void> _init() async {
    await getUserData();
    await checkDelegate();
    await getEmployeeLeaveList();
  }

  Future<void> waitUntilReady() => _initDone;

  checkDelegate() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await managerProvider.checkDelegate(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final delegate = checkDelegateFromJson(value.body);
          isHavingDelegate.value = delegate.data?.leaves?.isNotEmpty ?? false;
          if (isHavingDelegate.value) {
            currentDelegateId = delegate.data?.leaves?.first.delicateId ?? '';
          }
          fetchManagerDropdown();
          loading.value = Loading.loaded;
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  getCurrentDelegateData() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await managerProvider.getDelegateData(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final delegate = delegateDataResponseFromJson(value.body);
          loading.value = Loading.loaded;
          if (delegate.data?.leaves?.isNotEmpty ?? false) {
            currentDelegateData.value = delegate.data!.leaves!.first;
            DateFormat format = DateFormat("MM-dd-yyyy");
            fromDate.value = format.parse(currentDelegateData.value.fromDate!);
            toDate.value = format.parse(currentDelegateData.value.toDate!);
            setSelectedManager(currentDelegateData.value.delicateEmployeeId!);
          }
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  removeDelegate() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await managerProvider.removeDelegate(employeeData, '7').then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final delegate = checkDelegateFromJson(value.body);
          loading.value = Loading.loaded;
          appSnackBar(
            data: (delegate.message?.isNotEmpty ?? false)
                ? delegate.message!
                : 'Leave Revoked Successfully',
            color: AppColors.textGreenColor,
          );
          checkDelegate();
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  fetchManagerDropdown() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await managerProvider.getManagersDropdown(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final docData = managersDropDownFromJson(value.body);
          if (docData.data != null) {
            managerDropdownList?.value = docData.data?.leaves ?? [];
          }
          loading.value = Loading.loaded;
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error) {
      loading.value = Loading.loaded;
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  createDelegate() async {
    if (fromDate.value != null &&
        toDate.value != null &&
        selectedManager.value.employeeId!.isNotEmpty) {
      try {
        loading.value = Loading.loading;
        DelegateData delegateData = DelegateData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId,
          fromDate: fromDate.value != null
              ? dateTimeToString(fromDate.value!, format: "yyyy-MM-dd")
              : null,
          toDate: toDate.value != null
              ? dateTimeToString(toDate.value!, format: "yyyy-MM-dd")
              : null,
          employeeNo: selectedManager.value.employeeNo,
          delicateEmployeeId: selectedManager.value.employeeId,
          employeeNotification: selectedManager.value.employeeId,
        );
        await managerProvider.createDelegate(delegateData).then((value) {
          final responseData = jsonDecode(value.body);
          if (responseData['success'] == true) {
            final delegate = delegateDataResponseFromJson(value.body);
            appSnackBar(
              data: (delegate.message?.isNotEmpty ?? false)
                  ? delegate.message!
                  : 'Something went wrong',
              color: AppColors.textGreenColor,
            );
            loading.value = Loading.loaded;
            Get.offAllNamed(AppRoutes.homePage);
          } else {
            appSnackBar(
                data: responseData['message'] ?? 'Something went wrong',
                color: AppColors.textGreenColor);
          }
        });
        update();
      } on CustomException catch (err) {
        loading.value = Loading.loaded;
        appSnackBar(data: err.message, color: AppColors.appRedColor);
      } catch (error, st) {
        loading.value = Loading.loaded;
        print(error.toString());
        print(st.toString());
        appSnackBar(
            data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
      }
    } else {
      if (fromDate.value == null) {
        messageAlert('Select From Date', "Date Error", true, Get.context);
      }
      if (toDate.value == null) {
        messageAlert('Select To Date', "Date Error", true, Get.context);
      }
      if (selectedManager.value.employeeId == "") {
        messageAlert('Select Manager', "Manager Error", true, Get.context);
      }
    }
  }

  updateDelegate() async {
    if (fromDate.value != null &&
        toDate.value != null &&
        selectedManager.value.employeeId!.isNotEmpty) {
      try {
        loading.value = Loading.loading;
        DelegateData delegateData = DelegateData(
          delicateId: currentDelegateData.value.delicateId,
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId,
          fromDate: fromDate.value != null
              ? dateTimeToString(fromDate.value!, format: "yyyy-MM-dd")
              : null,
          toDate: toDate.value != null
              ? dateTimeToString(toDate.value!, format: "yyyy-MM-dd")
              : null,
          employeeNo: selectedManager.value.employeeNo,
          delicateEmployeeId: selectedManager.value.employeeId,
          employeeNotification: selectedManager.value.employeeId,
        );
        await managerProvider.updateDelegate(delegateData).then((value) {
          final responseData = jsonDecode(value.body);
          if (responseData['success'] == true) {
            final delegate = delegateDataResponseFromJson(value.body);
            appSnackBar(
              data: (delegate.message?.isNotEmpty ?? false)
                  ? delegate.message!
                  : 'Something went wrong',
              color: AppColors.textGreenColor,
            );
            loading.value = Loading.loaded;
            Get.offAllNamed(AppRoutes.homePage);
          } else {
            appSnackBar(
                data: responseData['message'] ?? 'Something went wrong',
                color: AppColors.textGreenColor);
          }
        });
        update();
      } on CustomException catch (err) {
        loading.value = Loading.loaded;
        appSnackBar(data: err.message, color: AppColors.appRedColor);
      } catch (error, st) {
        loading.value = Loading.loaded;
        print(error.toString());
        print(st.toString());
        appSnackBar(
            data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
      }
    } else {
      if (fromDate.value == null) {
        messageAlert('Select From Date', "Date Error", true, Get.context);
      }
      if (toDate.value == null) {
        messageAlert('Select To Date', "Date Error", true, Get.context);
      }
      if (selectedManager.value.employeeId == "") {
        messageAlert('Select Manager', "Manager Error", true, Get.context);
      }
    }
  }

  getEmployeeLeaveList() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await managerProvider.getLeaveData(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final employeeLeavesList = employeeLeavesListFromJson(value.body);
          final List<LeavesDetail> leaves = employeeLeavesList.data?.leavesDetails ?? [];
          final List<Calendar> calendar = employeeLeavesList.data?.calendar ?? [];
          leaveItems.value = leaves;
          teamLeaves.value = calendar;
          loading.value = Loading.loaded;
        } else {
          appSnackBar(
              data: responseData['message'] ?? 'Something went wrong',
              color: AppColors.textGreenColor);
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error, st) {
      loading.value = Loading.loaded;
      print(error.toString());
      print(st.toString());
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  getCalendarLeaveList() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await managerProvider.getCalendarLeaveData(employeeData, fromDate.value!).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          // Parse the new response format
          List<Map<String, String?>> todayLeavesList = [];

          if (responseData['data'] != null && responseData['data']['leaves'] != null) {
            final List<dynamic> leaves = responseData['data']['leaves'];

            for (var leave in leaves) {
              String days = '0';
              if (leave["no_of_days"] != null) {
                // Convert to int to remove decimal, then back to string
                days = int.parse(double.parse(leave["no_of_days"]).round().toString()).toString();
              }

              todayLeavesList.add({
                'empId': leave['employee_no'] ?? '',
                'name': leave['name'] ?? leave['first_name'] ?? '',
                'type': leave['plan_type_name'] ?? '',
                'days': days,
                // Additional fields if needed
                'employeeId': leave['employee_id'] ?? '',
                'date': leave['date'] ?? '',
                'reason': leave['leave_reason'] ?? '',
              });
            }
          }

          // Update selectedDayLeaves with the new data
          selectedDayLeaves = todayLeavesList;
          loading.value = Loading.loaded;
        } else {
          appSnackBar(
              data: responseData['message'] ?? 'Something went wrong',
              color: AppColors.textGreenColor);
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error, st) {
      loading.value = Loading.loaded;
      print(error.toString());
      print(st.toString());
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  updateLeaveStatus(LeavesDetail leaveDetail, isApprove, {String remarks = ''}) async {
    try {
      loading.value = Loading.loading;
      LeaveActionPostData leaveData = LeaveActionPostData(
          leaveActionReason: remarks,
          requestEmployeeId: int.parse(leaveDetail.employeeId ?? '0'),
          actionFlag: isApprove ? 'Approved' : 'Rejected',
          employeeId: int.parse(userData.user?.employeeId ?? '0'),
          companyId: userData.user?.companyId,
          leavePlanTypeId: int.parse(leaveDetail.leavePlanTypeId ?? '0'),
          employeeLeaveId: int.parse(leaveDetail.employeeLeaveId ?? '0'),
          noOfDays: leaveDetail.noOfDays,
          clientId: userData.user?.clientId);
      await managerProvider.updateLeaveStatus(leaveData).then((value) async {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          appSnackBar(
              data: responseData['data']['leaves'][0]['message'],
              color: AppColors.textGreenColor);
          await getEmployeeLeaveList();
          loading.value = Loading.loaded;
        } else {
          appSnackBar(
              data: responseData['message'] ?? 'Something went wrong',
              color: AppColors.textGreenColor);
        }
      });
      update();
    } on CustomException catch (err) {
      loading.value = Loading.loaded;
      appSnackBar(data: err.message, color: AppColors.appRedColor);
    } catch (error, st) {
      loading.value = Loading.loaded;
      print(error.toString());
      print(st.toString());
      appSnackBar(
          data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
    }
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? fromDate.value ?? DateTime.now().add(const Duration(days: 1))
          : fromDate.value,
      firstDate: isFromDate
          ? DateTime.now().add(const Duration(days: 1))
          : fromDate.value!,
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      if (isFromDate) {
        fromDate.value = picked;
        toDate.value = picked;
      } else {
        toDate.value = picked;
      }
    }
  }

  Future<void> selectTime(
      BuildContext context, bool isFromDate, bool isStartTime) async {
    var appTheme = Get.find<ThemeController>().currentTheme;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: fromDateStart.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? appTheme.white
                  : Colors.black),
              dayPeriodColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? appTheme.appColor
                  : Colors.grey.shade300),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isFromDate) {
        (isStartTime ? fromDateStart : fromDateEnd).value = picked;
      } else {
        (isStartTime ? toDateStart : toDateEnd).value = picked;
      }
    }
  }

  /// Convert TimeOfDay to a formatted string (HH:mm)
  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
    DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dateTime); // 24-hour format
  }

  Future<UserData>? getUserData() async {
    const storage = FlutterSecureStorage();
    final String? userDataLocalStr =
    await storage.read(key: PrefStrings.userData);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
    if (userDataLocalStr != null) {
      final UserData userDataLocal = userDataFromJson(userDataLocalStr);
      userData = userDataLocal;
    }

    return userData;
  }

  List<Holiday> getCalendarDays() {
    try {
      List<Holiday> leaveDays = [];
      for (var leave in teamLeaves) {
        leaveDays.add(
          Holiday(
            isLeave: true, // Mark as team leave
            status: "TeamLeave", // Custom status for team leaves
            extractedDay: leave.employeeCount,
            holidayName: "Team Leave",
            holidayDate: leave.start,
            toDate: leave.end,
          ),
        );
      }

      return leaveDays;
    } catch (e) {
      print("Error fetching calendar days: $e");
      return []; // Return an empty list on error
    }
  }

  Color getHolidayColor(String type) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    switch (type) {
      case "TeamLeave":
        return  appTheme.calendarPending;
      case "Approved":
        return appTheme.calendarApproved;
      case "Rejected":
        return appTheme.calendarRejected;
      case "Pending":
        return appTheme.calendarPending;
      default:
        return appTheme.calendarHoliday;
    }
  }

  List<Map<String, dynamic>> sortAttendance(List<dynamic> earningsData) {
    List<Map<String, dynamic>> earningsList = [];

    earningsList = earningsData
        .where((earning) => earning['data_type'] == 'list')
        .map<Map<String, dynamic>>((earning) => {
      'leave_plan_type_name': earning['leave_plan_type_name'],
      'total_leave_days': earning['total_leave_days'],
      'taken_leave_days': earning['taken_leave_days'],
    })
        .toList();

    earningsList.sort((a, b) => double.parse(a['total_leave_days'])
        .compareTo(double.parse(b['total_leave_days'])));

    return earningsList;
  }

  @override
  void dispose() {
    Get.delete<ManagerPageController>();
    super.dispose();
  }
}
