import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payroll/features/manager/model/employee_leaves_list.dart';
import 'package:payroll/features/manager/controller/manager_page_controller.dart';
import 'package:payroll/features/time/views/widgets/time_action_dialog.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/theme_controller.dart';
import '../../../util/custom_widgets.dart';

import '../../leave_page/views/widgets/popup.dart';

void showReasonPopup(BuildContext context, bool isApprove,
    ManagerPageController controller, LeavesDetail leaveDetail) {
  var appTheme = Get.find<ThemeController>().currentTheme;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
          backgroundColor: Colors.transparent, // Transparent background
          elevation: 0,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            width: 95.w,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: appTheme.popUpBG,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: CloseButtonWidget()),
                ),
                SizedBox(height: 1.h),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: appTheme.popUp1Border),
                    borderRadius:
                        BorderRadius.circular(16), // Outer border radius
                  ),
                  padding: EdgeInsets.all(3),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: appTheme.leaveDetailsBG,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 30.w,
                            height: 4.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.8.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: appTheme.buttonGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              "Enter Reason",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: appTheme.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: SizedBox(
                              width: 70.w,
                              child: CustomPaint(
                                painter: DottedBorderPainter(),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        maxLines: 3,
                                        controller: controller.reasonController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                          hintStyle: TextStyle(fontSize: 16.sp),
                                          hintText: 'Enter reason',
                                          fillColor: appTheme.greyBox,
                                        ),
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 35.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: appTheme.buttonGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                controller.updateLeaveStatus(
                                    leaveDetail, isApprove);
                              },
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
    },
  );
}

Future<bool> showLeaveConfirmationDialog(String empName, bool isApprove) async {
  final ManagerPageController controller = Get.find<ManagerPageController>();

  final result = await showDialog<bool>(
    context: Get.context!,
    builder: (BuildContext context) {
      var appTheme = Get.find<ThemeController>().currentTheme;
      return AlertDialog(
        title: Text(
          "${isApprove ? 'Approve' : 'Reject'} Leave",
          style: TextStyle(
            fontSize: 16.sp,
            color: appTheme.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
            "Are you sure you want to ${isApprove ? 'approve' : 'reject'} the $empName leave?"),
        actions: [
          TextButton(
            child: Text("No",
                style: TextStyle(fontSize: 14.sp, color: appTheme.black87)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text("Yes",
                style: TextStyle(fontSize: 14.sp, color: appTheme.black87)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );

  return result ??
      false; // if null (e.g. user dismissed dialog), treat as false
}

/// Confirmation dialog for time manager approve/reject actions with a remarks text field.
/// Returns a map with 'confirmed' (bool) and 'remarks' (String), or null if dismissed.
Future<Map<String, dynamic>?> showTimeActionConfirmationDialog(
    String empName,
    bool isApprove,
    ) async {
  return await Get.dialog<Map<String, dynamic>>(
    Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 16),
      child: TimeActionDialog(empName: empName, isApprove: isApprove),
    ),
    barrierDismissible: true,
  );
}

Future<bool> showRevokeConfirmationDialog() async {
  final result = await showDialog<bool>(
    context: Get.context!,
    builder: (BuildContext context) {
      var appTheme = Get.find<ThemeController>().currentTheme;
      return AlertDialog(
        title: Text(
          "Revoke Leave",
          style: TextStyle(
            fontSize: 16.sp,
            color: appTheme.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text("Are you sure you want to revoke the leaves?"),
        actions: [
          TextButton(
            child: Text("No",
                style: TextStyle(fontSize: 14.sp, color: appTheme.black87)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text("Yes",
                style: TextStyle(fontSize: 14.sp, color: appTheme.black87)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );

  return result ??
      false; // if null (e.g. user dismissed dialog), treat as false
}

class LeaveHistoryPopup extends StatelessWidget {
  final List<Map<String, String?>>? leaveHistory;
  final String empNo;
  final String empName;

  const LeaveHistoryPopup({
    super.key,
    required this.leaveHistory,
    required this.empNo,
    required this.empName,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 95.w,
      height: 68.h,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: 30.w,
                  height: 4.h,
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: appTheme.buttonGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    empNo,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: appTheme.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: CloseButtonWidget()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: 30.w,
                  height: 4.h,
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: appTheme.buttonGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    empName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: appTheme.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: appTheme.popUp1Border),
              borderRadius: BorderRadius.circular(16), // Outer border radius
            ),
            padding: EdgeInsets.all(3),
            child: Container(
              width: 95.w,
              height: 50.h,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appTheme.leaveDetailsBG,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  LeaveHistoryHeader(),
                  Scrollbar(
                    thickness: 3, // Optional: Adjust thickness
                    radius: const Radius.circular(10),
                    child: ListView.separated(
                      itemCount: leaveHistory!.length,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(
                        color: appTheme.appColor,
                        thickness: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final holiday = leaveHistory![index];
                        return LeaveHistoryTile(
                          leaveType: holiday["type"] ?? '',
                          fromDate: holiday["from"] ?? '',
                          toDate: holiday["to"] ?? '',
                          noOfDays: holiday["days"] ?? '',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaveHistoryHeader extends StatelessWidget {
  const LeaveHistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'From',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'To',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Days',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaveHistoryTile extends StatelessWidget {
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String noOfDays;

  const LeaveHistoryTile({
    super.key,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.noOfDays,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              leaveType,
              style: TextStyle(
                fontSize: 14.sp,
                color: appTheme.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fromDate,
              style: TextStyle(
                fontSize: 14.sp,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              toDate,
              style: TextStyle(
                fontSize: 14.sp,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              noOfDays,
              style: TextStyle(
                fontSize: 14.sp,
                color: appTheme.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarLeavePopup extends StatelessWidget {
  final List<Map<String, String?>>? leaveHistory;
  final String selectedDate;
  final String selectedDay;

  const CalendarLeavePopup({
    super.key,
    required this.leaveHistory,
    required this.selectedDate,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 95.w,
      height: 68.h,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: 30.w,
                  height: 4.h,
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: appTheme.buttonGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    selectedDate,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: appTheme.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: 30.w,
                  height: 4.h,
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: appTheme.buttonGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    selectedDay,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: appTheme.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: CloseButtonWidget()),
            ],
          ),
          SizedBox(height: 0.5.h),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: appTheme.popUp1Border),
              borderRadius: BorderRadius.circular(16), // Outer border radius
            ),
            padding: EdgeInsets.all(3),
            child: Container(
              width: 95.w,
              height: 50.h,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appTheme.leaveDetailsBG,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CalendarLeaveHeader(),
                  Scrollbar(
                    thickness: 3, // Optional: Adjust thickness
                    radius: const Radius.circular(10),
                    child: ListView.separated(
                      itemCount: leaveHistory!.length,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(
                        color: appTheme.appColor,
                        thickness: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final holiday = leaveHistory![index];
                        return CalendarLeaveTile(
                          leaveType: holiday["empId"] ?? '',
                          fromDate: holiday["name"] ?? '',
                          toDate: holiday["type"] ?? '',
                          noOfDays: holiday["days"] ?? '',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarLeaveHeader extends StatelessWidget {
  const CalendarLeaveHeader({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Emp ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Days',
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarLeaveTile extends StatelessWidget {
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String noOfDays;

  const CalendarLeaveTile({
    super.key,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.noOfDays,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              leaveType,
              style: TextStyle(
                fontSize: 14.sp,
                color: appTheme.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              fromDate,
              style: TextStyle(
                fontSize: 14.sp,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              toDate,
              style: TextStyle(
                fontSize: 14.sp,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              noOfDays,
              style: TextStyle(
                fontSize: 14.sp,
                color: appTheme.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
