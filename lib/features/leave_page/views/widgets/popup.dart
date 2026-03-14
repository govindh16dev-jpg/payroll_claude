import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:payroll/features/leave_page/model/leave_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';

class ApplyLeaveSuccessPopup extends StatelessWidget {
  const ApplyLeaveSuccessPopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 95.w,
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
        shrinkWrap: true,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                  width: 30, // Adjust the size
                  height: 30, // Adjust the size
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appTheme
                        .gradientBlue, // Adjust the background color to match
                  ),
                  child: Icon(Icons.close, color: Colors.black54)),
            ),
          ),
          SizedBox(height: 1.h),
          Opacity(
            opacity: 0.8,
            child: Container(
                width: 95.w,
                height: 15.h,
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: appTheme.successBG,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.sp,
                        // Adjust size as needed
                        fontWeight: FontWeight.w500,
                        // Medium weight for normal text
                        color: Colors.white, // Default text color
                      ),
                      children: [
                        const TextSpan(text: "YOUR "),
                        TextSpan(
                          text: "LEAVE REQUEST",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, // Bold for emphasis
                              color: appTheme.appThemeLight,
                              fontSize: 16.sp // Orange color from the image
                              ),
                        ),
                        const TextSpan(text: " HAS BEEN SUBMITTED\n"),
                        TextSpan(
                          text: "SUCCESSFULLY",
                          style: TextStyle(
                            fontSize: 16.sp, // Same size as above
                            fontWeight: FontWeight.w600, // Slightly bolder
                            color: Colors.white, // White color
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

class HolidayPopup extends StatelessWidget {
  final List<Holiday> holidayList;

    HolidayPopup({
    super.key,
    required this.holidayList,
  });
  var appTheme = Get.find<ThemeController>().currentTheme;
  @override
  Widget build(BuildContext context) {
      appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 95.w,
      height: 58.h,
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
              Text(
                'List of Holidays',
                style: TextStyle(
                    color: appTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp),
              ),
              GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: CloseButtonWidget()),
            ],
          ),
          SizedBox(height: 0.5.h),
          Container(
            width: 95.w,
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: appTheme.popUp1Border),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: appTheme.popUpBG,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              width: 95.w,
              height: 50.h,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appTheme.leaveDetailsBG,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Scrollbar(
                thickness: 3, // Optional: Adjust thickness
                radius: const Radius.circular(10),
                child: ListView.separated(
                  itemCount: holidayList.length,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => GradientDivider(),
                  itemBuilder: (context, index) {
                    final holiday = holidayList[index];
                    return HolidayTile(
                      date:
                          DateFormat('dd/MM/yyyy').format(holiday.holidayDate!),
                      day: holiday.dayOfWeek ?? "",
                      event: holiday.holidayName ?? "",
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaveHistoryPopup extends StatelessWidget {
  final List<Map<String, String?>>? leaveHistory;
  final String label;

  const LeaveHistoryPopup({
    super.key,
    required this.leaveHistory,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 95.w,
      height: 58.h,
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
                child: Text(
                  '$label Leaves',
                  style: TextStyle(
                      color: appTheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp),
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
              child: Scrollbar(
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
                      date: holiday["created_at"] ?? '',
                      status: holiday["leave_status"] ?? '',
                      noOfDays: holiday["no_of_days"] ?? '',
                      leaveType: holiday["plan_type_name"] ?? '',
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HolidayTile extends StatelessWidget {
  final String date, day, event;

  const HolidayTile({
    super.key,
    required this.date,
    required this.day,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: appTheme.appColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.diversity_3, color: Colors.white, size: 18.sp),
        ),
        SizedBox(width: 4.w),
        Text(
          date,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: appTheme.black,
            fontSize: 16.sp,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: appTheme.buttonGradientApproved,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                event,
                style: TextStyle(
                  color: appTheme.black,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String formatDays(String daysString) {
  // Convert string to double
  double days = double.tryParse(daysString) ?? 0;

  // Convert to integer if needed
  int intDays = days.toInt();

  // Format output
  return intDays == 1 ? "1 day" : "$intDays days";
}
getStatusColor(label){
  var appTheme = Get.find<ThemeController>().currentTheme;
  switch (label) {
    case 'Approved':
       return appTheme.calendarApproved;
    case 'Rejected':
      return appTheme.calendarRejected;
    case 'Pending':
      return appTheme.calendarPending;
    default:
  return appTheme.calendarApproved;
  }
}
class LeaveHistoryTile extends StatelessWidget {
  final String date, status, noOfDays, leaveType;

  const LeaveHistoryTile({
    super.key,
    required this.date,
    required this.status,
    required this.noOfDays,
    required this.leaveType,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration:   BoxDecoration(
            color: appTheme.appColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.group, color: Colors.white, size: 18.sp),
        ),
        SizedBox(width: 4.w),
        Text(
          date,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: appTheme.black,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                leaveType,
                style: TextStyle(
                  color: appTheme.black,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                formatDays(noOfDays),
                style: TextStyle(
                  color: appTheme.black,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 0.5.h),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration:BoxDecoration(
                         color:  getStatusColor(status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showLeaveDetailsDialog(BuildContext context, Holiday holiday) {
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GradientDivider(),
                        infoRow(
                          holiday.status != null ? "FROM" : "Date",
                          DateFormat('dd/MM/yyyy').format(holiday.holidayDate!),
                        ),
                        if (holiday.status != null)
                          infoRow(
                            "TO",
                            DateFormat('dd/MM/yyyy').format(holiday.toDate!),
                          ),
                        if (holiday.status != null)
                          infoRow("No of Days", holiday.extractedDay!),
                        infoRow("Leave Type", holiday.holidayName ?? ""),
                        if (holiday.status != null)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Status",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w900)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: holiday.status == "Approved"
                                      ? BoxDecoration(
                                          gradient: LinearGradient(
                                            colors:
                                                appTheme.buttonGradientApproved,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        )
                                      : BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: appTheme.buttonGradient,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                  child: Text(
                                    holiday.status ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const GradientDivider(),
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

Widget infoRow(String title, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900)),
        Text(value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class GradientDivider extends StatelessWidget {
  const GradientDivider({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      height: 0.1.h, // Thickness of the divider
      margin: EdgeInsets.symmetric(vertical: 10), // Space around the divider
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: appTheme.dividerGradient, // Gradient colors
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(2), // Slightly rounded edges
      ),
    );
  }
}
