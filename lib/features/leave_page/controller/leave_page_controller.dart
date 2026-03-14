import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:payroll/features/leave_page/data/repository/leave_provider.dart';
import 'package:payroll/features/leave_page/views/widgets/popup.dart';
import 'package:payroll/features/login/domain/model/login_model.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:payroll/util/custom_widgets.dart';
import 'package:sizer/sizer.dart';

import '../../../routes/app_pages.dart';
import '../../../theme/theme_controller.dart';
import '../../homepage/views/widgets/carosel.dart';
import '../../manager/controller/manager_page_controller.dart';
import '../../profile_page/data/model/profile_model.dart';
import '../model/apply_leave.dart';
import '../model/leave_model.dart';
import '../views/widgets/leave_card.dart';

class LeavePageController extends GetxController {
  var loading = Loading.initial.obs;
  RxList bannerItems = [].obs;
  RxList sortedEarnings = [].obs;
  RxList pendingLeaves = <LeaveData>[].obs;

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
  final TextEditingController reasonController = TextEditingController();
  var selectedLeaveType = LeaveDetail(
    leavePlanTypeName: "Select Leave",
    leavePlanTypeId: "",
    availableLeaves: "",
  ).obs;
  RxString selectedLeaveTypeID = "12".obs;
  RxString selectedDayTypeIDFromDate = "1".obs;
  RxString selectedDayTypeIDToDate = "1".obs;
  RxString selectedLeaveRemaining = "0".obs;
  RxString totalLeaveDays = "0".obs;
  List<LeaveDetail>? leaveDetails;
  List<Holiday>? holidayList;
  List<Map<String, String?>>? leaveHistory;
  final labelWidth=20.w;
  final  inputWidth=40.w;
  RxList<LeaveDetail>? leaveTypeDropdown = <LeaveDetail>[
    LeaveDetail(leavePlanTypeName: "casual", leavePlanTypeId: "12")
  ].obs;
  RxList<LeaveType>? leaveDayDropdown = <LeaveType>[
    LeaveType(leaveName: "Full day", leavePlanTypeId: "1"),
    LeaveType(leaveName: "Less than a day", leavePlanTypeId: "2"),
  ].obs;

  void toggleSwitch(bool value) {
    isManager.value = value;
    if (value) {
      if (Get.isRegistered<ManagerPageController>()) {
        Get.delete<ManagerPageController>();
      }
      Get.put(ManagerPageController(),permanent: false);
      Get.toNamed(AppRoutes.managerPage);
    }
  }

  void showHolidayDialog(BuildContext context, Holiday holiday) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Holiday ${holiday.status} "),
          content: Text(
              "${holiday.holidayName} on ${holiday.holidayDate!.toLocal()}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, String?>>? getApprovedLeaves() {
    return leaveHistory?.where((leave) => leave["leave_status"] == "Approved").toList();
  }
  List<Map<String, String?>>? getPendingLeaves() {
    return leaveHistory?.where((leave) => leave["leave_status"] == "Pending").toList();
  }

  List<Map<String, String?>>? getRejectedLeaves() {
    return leaveHistory?.where((leave) => leave["leave_status"] == "Rejected").toList();
  }

  @override
  void onInit() {
    super.onInit();
    isManager = false.obs;
    bannerItems.value = [
      LeaveCardOverAll(
        title: "Leave balance",
        sickLeave: '10',
        earnedLeave: '8',
        compOff: '6',
        upcomingHoliday: 'Upcoming Holiday : ${appStateController.upcomingHoliday.value}',
      ),
      LeaveCard(
        title: 'Earned Leave',
        eligible: '10',
        applied: '10',
        balance: '7',
        upcomingHoliday: 'Upcoming Holiday : 25 Feb 2025',
      ),
      LeaveCard(
        title: 'Sick Leave',
        eligible: '12',
        applied: '3',
        balance: '9',
        upcomingHoliday: 'Upcoming Holiday : 25 Feb 2025',
      ),
      LeaveCard(
        title: 'Paid Leave',
        eligible: '5',
        applied: '3',
        balance: '2',
        upcomingHoliday: 'Upcoming Holiday : 25 Feb 2025',
      ),
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
    getUserData();
  }

  setRemainingLeaves() {
    var leave = leaveTypeDropdown?.firstWhere(
      (leave) => leave.leavePlanTypeId == selectedLeaveTypeID.value,
      orElse: () => LeaveDetail(
          leavePlanTypeName: "",
          leavePlanTypeId: "",
          availableLeaves: "0"), // Default if not found
    );
    selectedLeaveRemaining.value = leave?.availableLeaves ?? '0';
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? DateTime.now() : fromDate.value,
      firstDate: isFromDate
          ? DateTime.now().subtract(const Duration(days: 1))
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
      calculateLeaveDays(
          isWeekendDays: selectedLeaveType.value.considerWeekendLeaves == "No"
              ? false
              : true,
          holidayList: holidayList,
          considerHolidays:
              selectedLeaveType.value.considerHolidays == "No" ? false : true);
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

  int calculateLeaveDays({
    required bool isWeekendDays,
    required bool considerHolidays,
    required List<Holiday>? holidayList,
  }) {
    if (fromDate.value == null || toDate.value == null) {
      totalLeaveDays.value = '0';
      return 0;
    }

    int totalDays = toDate.value!.difference(fromDate.value!).inDays + 1;
    int excludedDays = 0;
    DateTime currentDate = fromDate.value!;

    // Convert holidays to a Set<DateTime> for fast lookup
    Set<DateTime> holidayDates = {};
    if (considerHolidays && holidayList != null) {
      holidayDates = holidayList.map((holiday) => holiday.holidayDate!).toSet();
    }

    while (currentDate.isBefore(toDate.value!) ||
        currentDate.isAtSameMomentAs(toDate.value!)) {
      bool isWeekend = (currentDate.weekday == DateTime.saturday ||
          currentDate.weekday == DateTime.sunday);
      bool isHoliday = holidayDates.contains(currentDate);

      if ((!isWeekendDays && isWeekend) || (considerHolidays && isHoliday)) {
        excludedDays++;
      }

      currentDate = currentDate.add(Duration(days: 1));
    }

    totalDays -= excludedDays;
    totalLeaveDays.value = totalDays.toString();
    return totalDays;
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

      fetchLeaveData();
    }

    return userData;
  }
//todo handle leave details
//todo leave history on tap
  onLeaveRequest(context) async {
    if (fromDate.value != null &&
        toDate.value != null &&
        reasonController.text.isNotEmpty) {
      try {
        loading.value = Loading.loading;
        ApplyLeavePostData leavePostData = ApplyLeavePostData(
          addressToContact: "",
          alternativeContactNumber: "",
          attachmentUrl: "",
          clientId: int.parse(userData.user!.clientId!),
          companyId: int.parse(userData.user!.companyId!),
          employeeId: int.parse(userData.user!.employeeId!),
          expectedDate: "",
          toDate: toDate.value!,
          fromDate: fromDate.value!,
          leaveDetails: [
            if(selectedDayTypeIDFromDate.value == '2')LeaveDetailApply(
              date: fromDate.value,
              leaveDayType: selectedDayTypeIDFromDate.value == '2'?'half day':"full day",
              halfDayType:"",
              startTime:  selectedDayTypeIDFromDate.value == '2'?'half day':"full day",
              endTime: selectedDayTypeIDFromDate.value == '2'?'half day':"full day",
            )
          ],
          leavePlanTypeId: int.tryParse(selectedLeaveTypeID.value) ?? 0,
          // leavePlanId: selectedDayTypeIDFromDate.value ?? '2',
          leaveReason: reasonController.text,
          noOfDays:
              '${calculateLeaveDays(isWeekendDays: selectedLeaveType.value.considerWeekendLeaves == "No" ? false : true, holidayList: holidayList, considerHolidays: selectedLeaveType.value.considerHolidays == "No" ? false : true)}',
        );
        await leaveProvider.applyLeave(leavePostData).then((value) {
          loading.value = Loading.loaded;

          final responseData = jsonDecode(value.body);

          if (responseData['success'] == true) {
            // appSnackBar(
            //     data: responseData['data']['leave_details'][0]['message'],
            //     color: AppColors.textGreenColor);

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                    backgroundColor: Colors.transparent,
                    // Transparent background
                    elevation: 0,
                    insetPadding: EdgeInsets.all(0),
                    child: ApplyLeaveSuccessPopup());
              },
            );
            Get.toNamed(AppRoutes.leavePage);
          } else {
            String cleanedError =
                responseData['data'][0]['error_msg'].split("]").last.trim();
            appSnackBar(data: cleanedError, color: AppColors.appRedColor);
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
    } else {
      if (fromDate.value == null) {
        messageAlert('Select From Date', "Date Error", true, Get.context);
      }
      if (toDate.value == null) {
        messageAlert('Select To Date', "Date Error", true, Get.context);
      }
      if (reasonController.text.isEmpty) {
        messageAlert(
            'Enter Leave Reason', "Leave Reason Error", true, Get.context);
      }
    }
  }

  getRemainingLeaves(leaveType){
    LeaveDetail? leaveData = leaveDetails?.firstWhere(
            (record) => record.leaveKey == leaveType
    );
    return  leaveData?.availableLeaves??"";
  }

  fetchLeaveData() async {
    try {
      loading.value = Loading.loading;
      ProfilePostData employeeData = ProfilePostData(
          employeeId: userData.user?.employeeId,
          companyId: userData.user?.companyId,
          clientId: userData.user?.clientId);
      await leaveProvider.getLeave(employeeData).then((value) {
        final responseData = jsonDecode(value.body);
        if (responseData['success'] == true) {
          final leaveData = leaveDataFromJson(value.body);

          leaveDetails = leaveData.data!.leaveDetails!;
          holidayList = leaveData.data!.holidays!;
          leaveHistory = leaveData.data!.leaveHistory!.reversed.toList();
          if (leaveDetails != null) {
            bannerItems.clear();
            leaveTypeDropdown?.clear();


            for (var leaveType in leaveDetails!) {
              if (leaveType.isGraph == '1') {
                bannerItems.add(
                  LeaveCard(
                    title: leaveType.leavePlanTypeName ?? '',
                    eligible: leaveType.totalLeaveDays ?? '',
                    applied: leaveType.takenLeaveDays ?? '',
                    balance: leaveType.availableLeaves ?? '',
                    upcomingHoliday:   'Upcoming Holiday : ${appStateController.upcomingHoliday.value}',
                  ),
                );
              }
              leaveTypeDropdown?.add(leaveType);
            }

            bannerItems.insert(
              0,
              LeaveCardOverAll(
                title: "Leave balance",
                sickLeave: getRemainingLeaves("sick_leave"),
                earnedLeave: getRemainingLeaves("earned_leave"),
                compOff: getRemainingLeaves("casual_leave"),
                upcomingHoliday: 'Upcoming Holiday : ${appStateController.upcomingHoliday.value}',
              ),
            );

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

   List<Holiday> getCalendarDays()   {
    DateFormat format = DateFormat("dd MMM yyyy");
// "10 Jan 2025"


    try {

      List<Holiday> leaveDays = [];
      String? dateRange = "";

      if (leaveHistory != null) {
        for (var leave in leaveHistory!) {
          dateRange= leave["from_date"]??'';
          List<String> dates = dateRange.split(" - ");
          String fromDate = dates[0];
          String toDate = dates[1];
          leaveDays.add(
            Holiday(
              isLeave: true,
              status: leave['leave_status'],
              extractedDay: leave['no_of_days'],
              holidayName: leave['plan_type_name'],
              holidayDate: fromDate==""?null: format.parse(fromDate),
              toDate:  toDate==""?null:format.parse(toDate),
            ),
          );
        }
      }
      List<Holiday> calendarDays = [...?holidayList, ...leaveDays];
      return calendarDays;
    } catch (e) {
      print("Error fetching calendar days: $e");
      return []; // Return an empty list on error
    }
  }
  Color getHolidayColor(String type) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    switch (type) {
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
    Get.delete<LeavePageController>();
    super.dispose();
  }
}
