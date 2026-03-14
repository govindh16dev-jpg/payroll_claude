// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:payroll/features/manager/views/widgets.dart';
import 'package:payroll/features/time/controller/time_page_controller.dart';
import 'package:payroll/features/time/views/widgets/attendance_details_popup.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../config/constants.dart';
import '../../../routes/app_route.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/common/status_legends.dart';
import '../../../util/custom_widgets.dart';
import '../../leave_page/model/leave_model.dart';
import 'leaves_item.dart';

class TimePage extends GetView<TimePageController> {
  TimePage({super.key});
  var appTheme = Get.find<ThemeController>().currentTheme;

  @override
  Widget build(BuildContext context) {
    appTheme = Get.find<ThemeController>().currentTheme;
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchEmployeeTimeView();
      },
      child: Scaffold(
        drawer: CustomDrawer(),
        drawerEnableOpenDragGesture: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(5.h),
          child: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: FaIcon(FontAwesomeIcons.ellipsis,
                      size: 22.sp, color: appTheme.appThemeLight),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Image.asset('assets/logos/app_icon.png'),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            GestureDetector(
              onHorizontalDragEnd: (details) {},
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      CustomHeader(
                        title: 'Your Time',
                      ),
                      GetBuilder<TimePageController>(
                        builder: (snapshot) {
                          if (snapshot.loading.value == Loading.loading) {
                            return Center(child: CircularProgressIndicator());
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 2.h),
                              _buildTimeTrackingBody(),
                              IgnorePointer(
                                ignoring: false,
                                child: // Update the calendar section in your build method
                                    TableCalendar(
                                  firstDay:
                                      DateTime(DateTime.now().year - 1, 10, 1),
                                  lastDay:
                                      DateTime(DateTime.now().year + 1, 3, 31),
                                  focusedDay: controller.currentMonth.value,
                                  holidayPredicate: (day) {
                                    List<Holiday> holidays =
                                        snapshot.getCalendarDays();
                                    return holidays.any((holiday) =>
                                        isSameDay(holiday.holidayDate, day));
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    markerBuilder: (context, day, events) {
                                      List<Holiday> holidays = snapshot.getCalendarDays();
                                      Holiday? holiday = holidays.firstWhere(
                                            (h) => isSameDay(h.holidayDate, day),
                                        orElse: () => Holiday(holidayName: '', holidayDate: DateTime(2000, 1, 1)),
                                      );

                                      bool isShortHours = controller.hasShortHours(day);
                                      bool isOvertime = controller.hasOvertime(day);

                                      // ✅ Check statusKey (not holidayName) — statusKey is always set even when status display name is ""
                                      if (holiday.status != null && holiday.status!.isNotEmpty) {
                                        return Container(
                                          width: 10.w,
                                          height: 10.h,
                                          decoration: BoxDecoration(
                                            color: controller.getHolidayColor(holiday.status), // use statusKey directly
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${day.day}',
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      } else if (isShortHours) {
                                        return Container(
                                          width: 10.w,
                                          height: 10.h,
                                          decoration: BoxDecoration(color: appTheme.calendarPending, shape: BoxShape.circle),
                                          alignment: Alignment.center,
                                          child: Text('${day.day}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        );
                                      } else if (isOvertime) {
                                        return Container(
                                          width: 10.w,
                                          height: 10.h,
                                          decoration: BoxDecoration(color: appTheme.calendarOvertime, shape: BoxShape.circle),
                                          alignment: Alignment.center,
                                          child: Text('${day.day}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        );
                                      }
                                      return null;
                                    },
                                  ),
                                  calendarStyle: CalendarStyle(
                                    todayDecoration: BoxDecoration(
                                      color: appTheme.appColor,
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    weekendTextStyle: TextStyle(
                                      color: appTheme.appColor,
                                    ),
                                    defaultTextStyle:
                                        TextStyle(color: Colors.black),
                                    outsideDaysVisible: false,
                                  ),
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    titleTextStyle: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: appTheme.appColor,
                                    ),
                                  ),
                                      onDaySelected: (selectedDay, focusedDay) async {
                                        final calendarData = controller.getTimeCalendarModelForDay(selectedDay);

                                        if (calendarData != null) {
                                          if (calendarData.isRegularize == '1') {
                                            Get.toNamed(AppRoutes.regularizePage, arguments: {'date': selectedDay, 'data': calendarData});
                                          } else {
                                            controller.showAttendanceDetailsPopup(selectedDay, calendarData);
                                          }
                                        }
                                      },

                                      onPageChanged: (focusedDay) async {
                                    controller.currentMonth.value = focusedDay;
                                    await controller.fetchEmployeeTimeView();
                                  },
                                ),
                              ),
                              StatusLegendTime(),
                              SizedBox(height: 15.h),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                  visible: controller.loading.value == Loading.loading,
                  child: loadingIndicator()),
            )
          ],
        ),
        floatingActionButton: CustomBottomNaviBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'half_day':
        return 'Half Day';
      case 'full_hours':
        return 'Full Hours';
      case 'absent':
        return 'Absent';
      case 'week_holiday':
        return 'Week Off';
      case 'holiday':
        return 'Holiday';
      case 'leave':
        return 'Leave';
      case 'short_hours':
        return 'Short Hours';
      case 'over_time':
        return 'Over Time';
      default:
        // Capitalize first letter of each word and replace underscores
        return status.replaceAll('_', ' ').split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '').join(' ');
    }
  }

  void _showFullScreenImageDialog(BuildContext context, File imageFile) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(0),
          child: Container(
            width: 95.w,
            padding: EdgeInsets.all(8),
            child: ListView(
              shrinkWrap: true,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: CloseButtonWidget(),
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: appTheme.popUp1Border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(3),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: appTheme.leaveDetailsBG,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Obx(() => Container(
                                width: 40.w,
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
                                  controller.isConfirmingClockOut.value
                                      ? "Clock-out Photo"
                                      : "Clock-in Photo",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    color: appTheme.white,
                                  ),
                                ),
                              )),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          height: 50.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: appTheme.appColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: InteractiveViewer(
                              panEnabled: true,
                              boundaryMargin: EdgeInsets.all(10),
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: Image.file(
                                imageFile,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: appTheme.greyBox.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: appTheme.appColor,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 2.w),
                                  Obx(() => Text(
                                        'Captured at: ${controller.isConfirmingClockOut.value ? controller.clockOutTime.value : controller.clockInTime.value}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: appTheme.darkGrey,
                                        ),
                                      )),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: appTheme.appColor,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Obx(() => Text(
                                          controller.currentAddress.value
                                                  .isNotEmpty
                                              ? controller.currentAddress.value
                                              : 'Location unavailable',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: appTheme.darkGrey,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 35.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: appTheme.appColor,
                                  width: 1.5,
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
                                  controller.capturePhoto();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.refresh,
                                      color: appTheme.appColor,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      "Retake",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w900,
                                        color: appTheme.appColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
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
                                },
                                child: Text(
                                  "Done",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w900,
                                    color: appTheme.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeTrackingBody() {
    return Obx(() {
      // For biometric employees - show only dashboard
      if (controller.isBiometricEnabled.value) {
        return _buildBiometricDashboard();
      }

      // For non-biometric employees - show clock in/out functionality
      if (controller.isCapturingRoute.value) {
        return _buildRouteCaptureView();
      } else if (controller.isConfirmingClockIn.value) {
        return _buildClockedInView(isClockOut: false);
      } else if (controller.isConfirmingClockOut.value) {
        return _buildClockedInView(isClockOut: true);
      } else if (controller.isClockedIn.value) {
        return _buildWorkingView();
      } else {
        return _buildClockInView();
      }
    });
  }

// New method for biometric employees - Just dashboard
  Widget _buildBiometricDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleSwitch(),
        SizedBox(height: 2.h),

        // Time Dashboard title
        Text(
          'Time Dashboard',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: appTheme.darkGrey,
          ),
        ),
        SizedBox(height: 1.h),

        Text(
          '${controller.shiftStartTime.value} to ${controller.shiftEndTime.value} (${controller.shiftName.value})',
          style: TextStyle(
            fontSize: 12.sp,
            color: appTheme.darkGrey,
          ),
        ),

        SizedBox(height: 2.h),
        Divider(thickness: 1, color: appTheme.appColor),

        // Stats sections
        _buildTodayStats(),
        Divider(thickness: 1, color: appTheme.appColor),

        _buildYesterdayStats(),
        Divider(thickness: 1, color: appTheme.appColor),

        _buildWeeklyStats(),
        Divider(thickness: 1, color: appTheme.appColor),

        SizedBox(height: 0.5.h),
        _buildMonthlyStats(),
        Divider(thickness: 1, color: appTheme.appColor),
      ],
    );
  }


  Widget _buildWorkingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleSwitch(),
        SizedBox(height: 0.5.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: appTheme.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                controller.isOnBreak.value ? 'On Break' : 'Currently Working',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: controller.isOnBreak.value ? Colors.red : appTheme.darkGrey,
                ),
              )),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clocked in at:',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: appTheme.darkGrey,
                                ),
                              ),
                              Obx(() => Text(
                                    controller.clockInTime.value.isNotEmpty
                                        ? controller.clockInTime.value
                                        : 'N/A',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: appTheme.appColor,
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(width: 3.w),
                          Obx(() => controller.capturedImage.value != null
                              ? GestureDetector(
                                  onTap: () {
                                    _showFullScreenImageDialog(Get.context!,
                                        controller.capturedImage.value!);
                                  },
                                  child: Container(
                                    width: 8.w,
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: appTheme.appColor),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        controller.capturedImage.value!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink()),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Working time:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: appTheme.darkGrey,
                        ),
                      ),
                      Obx(() => Text(
                            controller.todayWorkedHours.value.isNotEmpty
                                ? controller.todayWorkedHours.value
                                : '0h 00m',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: appTheme.appColor,
                            ),
                          )),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => Container(
                          height: 5.h,
                          decoration: BoxDecoration(
                            gradient:
                                LinearGradient(colors: appTheme.buttonGradient),
                            borderRadius: BorderRadius.circular(10),
                            // gradient: controller.isOnBreak.value
                            //     ? LinearGradient(
                            //     colors: [Colors.orange, Colors.deepOrange])
                            //     : LinearGradient(
                            //     colors: appTheme.buttonGradient),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              if (controller.isOnBreak.value) {
                                controller.endBreak();
                              } else {
                                controller.startBreak();
                              }
                            },
                            child: Text(
                              controller.isOnBreak.value
                                  ? 'End Break'
                                  : 'Start Break',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: appTheme.white,
                              ),
                            ),
                          ),
                        )),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Container(
                      height: 5.h,
                      decoration: BoxDecoration(
                        gradient:
                            LinearGradient(colors: appTheme.buttonGradient),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          controller.toggleClockInOut();
                        },
                        child: Text(
                          'Clock Out',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: appTheme.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // CENTERED LOCATION
              Center(
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: appTheme.appThemeLight,
                          size: 16.sp,
                        ),
                        SizedBox(width: 2.w),
                        Flexible(
                          child: Text(
                            controller.currentAddress.value.isNotEmpty
                                ? controller.currentAddress.value
                                : 'Location unavailable',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: appTheme.darkGrey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )),
              ),

              SizedBox(height: 1.h),
              Divider(thickness: 1, color: appTheme.appColor),

              // SHIFT INFO
              _buildShiftInfo(),

              SizedBox(height: 1.h),

              // CAPTURE ROUTE BUTTON
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Capture your next',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appTheme.darkGrey,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 25.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: appTheme.buttonGradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: controller.handleLocationCaptureTap,
                        child: Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: appTheme.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        // TODAY STATS (after clocking out or when showing stats)
        Obx(() {
          // Show today's stats if we have worked hours data
          if (controller.todayWorkedHours.value.isNotEmpty &&
              controller.todayWorkedHours.value != '0h 00m') {
            return Column(
              children: [
                Divider(thickness: 1, color: appTheme.appColor),
                _buildTodayStats(),
                SizedBox(height: 1.h),
              ],
            );
          }
          return SizedBox.shrink();
        }),
        Divider(thickness: 1, color: appTheme.appColor),
        _buildYesterdayStats(),
        Divider(thickness: 1, color: appTheme.appColor),
        _buildWeeklyStats(),
        Divider(thickness: 1, color: appTheme.appColor),
        SizedBox(height: 0.5.h),
        _buildMonthlyStats(),
        Divider(thickness: 1, color: appTheme.appColor),
      ],
    );
  }

  Widget _buildClockInView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleSwitch(),
        SizedBox(height: 0.2.h),
        _buildTimeRecordSection(),
        SizedBox(height: 0.5.h),
        // Only show clock in button if not already clocked out for the day
        Obx(() {
          // Hide button if user has clocked out for the day (completed work)
          // Show if currently clocked in (to allow clock out) or hasn't clocked in yet (no clock out time)
          if (!controller.isClockedIn.value && controller.clockOutTime.value.isNotEmpty) {
            return SizedBox.shrink();
          }
          return _buildClockInButton();
        }),
        SizedBox(height: 0.5.h),
        _buildLocationInfo(),
        SizedBox(height: 0.5.h),

        // ADD TODAY STATS HERE AS WELL
        Obx(() {
          // Show today's stats if we have worked hours data from previous clock out
          if (controller.todayWorkedHours.value.isNotEmpty &&
              controller.todayWorkedHours.value != '0h 00m') {
            return Column(
              children: [
                Divider(thickness: 1, color: appTheme.appColor),
                _buildTodayStats(),
                SizedBox(height: 1.h),
              ],
            );
          }
          return SizedBox.shrink();
        }),
        Divider(thickness: 1, color: appTheme.appColor),
        _buildYesterdayStats(),
        Divider(thickness: 1, color: appTheme.appColor),
        _buildWeeklyStats(),
        Divider(thickness: 1, color: appTheme.appColor),
        SizedBox(height: 0.5.h),
        _buildMonthlyStats(),
        Divider(thickness: 1, color: appTheme.appColor),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Do you want to replay the',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: appTheme.darkGrey,
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 25.w,
                height: 3.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: appTheme.buttonGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    controller.navigateToRouteReplay();
                  },
                  child: Text(
                    'Route',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: appTheme.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClockedInView({bool isClockOut = false}) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: appTheme.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClockingInHeader(isClockOut: isClockOut),
          Divider(thickness: 1, color: appTheme.appColor),
          _buildLocationSection(),
          Divider(thickness: 1, color: appTheme.appColor),
          _buildShiftInfo(),
          Divider(thickness: 1, color: appTheme.appColor),
          Obx(() => (isClockOut
                  ? controller.isClockOutPhotoUpload.value
                  : controller.isPhotoUpload.value)
              ? _buildPhotoSection()
              : SizedBox.shrink()),
          SizedBox(height: 1.h),

          // COLUMN LAYOUT FOR BUTTONS
          Column(
            children: [
              // Confirm Button (Full Width)
              Container(
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: appTheme.buttonGradient,
                    // colors: isClockOut
                    //     ? [Colors.red, Colors.red.shade700]
                    //     : appTheme.buttonGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (isClockOut) {
                      controller.confirmClockOut();
                    } else {
                      controller.confirmClockIn();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: appTheme.white,
                        size: 18.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        isClockOut ? 'Confirm Clock Out' : 'Confirm Clock In',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 1.5.h),

              // Cancel Button (Full Width)
              Container(
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: appTheme.appColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (isClockOut) {
                      controller.cancelClockOutConfirmation();
                    } else {
                      controller.cancelClockInConfirmation();
                    }
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: appTheme.appColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),
          _buildGoogleMap(),
        ],
      ),
    );
  }

  Widget _buildConfirmButton({bool isClockOut = false}) {
    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isClockOut
              ? [Colors.red, Colors.red.shade700]
              : appTheme.buttonGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          if (isClockOut) {
            controller.confirmClockOut();
          } else {
            controller.confirmClockIn();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: appTheme.white,
              size: 18.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              isClockOut ? 'Confirm Clock Out' : 'Confirm Clock In',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: appTheme.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo Verification',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: appTheme.darkGrey,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Container(
              width: 15.w,
              height: 6.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: appTheme.buttonGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => controller.capturePhoto(),
                child: Icon(
                  Icons.camera_alt,
                  color: appTheme.white,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Obx(() {
              // Determine which image to show based on state
              File? displayImage = controller.isConfirmingClockOut.value
                  ? controller.capturedImageClockOut.value
                  : controller.capturedImage.value;

              return displayImage != null
                  ? GestureDetector(
                      onTap: () {
                        _showFullScreenImageDialog(Get.context!, displayImage);
                      },
                      child: Container(
                        width: 15.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: appTheme.appColor),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            displayImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Visibility(
                      visible: false,
                      child: Container(
                        width: 15.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade100,
                        ),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.grey.shade400,
                          size: 16.sp,
                        ),
                      ),
                    );
            }),
            SizedBox(width: 3.w),
            Expanded(
              child: Obx(() {
                File? displayImage = controller.isConfirmingClockOut.value
                    ? controller.capturedImageClockOut.value
                    : controller.capturedImage.value;

                return Text(
                  displayImage != null
                      ? 'Photo captured ✓'
                      : 'Tap camera to take photo',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                        displayImage != null ? Colors.green : appTheme.darkGrey,
                    fontWeight: displayImage != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              }),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Divider(thickness: 1, color: appTheme.appColor),
      ],
    );
  }

  // ==================== ROUTE CAPTURE VIEW ====================

  Widget _buildRouteCaptureView() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: appTheme.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Capturing Route',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: appTheme.darkGrey,
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: appTheme.darkGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(thickness: 1, color: appTheme.appColor),

          // Location
          _buildLocationSection(),
          Divider(thickness: 1, color: appTheme.appColor),

          // Shift Info
          _buildShiftInfo(),
          Divider(thickness: 1, color: appTheme.appColor),

          // Photo Section for Route
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Route Photo',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: appTheme.darkGrey,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Container(
                    width: 15.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: appTheme.buttonGradient),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => controller.captureRoutePhoto(),
                      child: Icon(
                        Icons.camera_alt,
                        color: appTheme.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Obx(() {
                    final displayImage = controller.capturedRouteImage.value;
                    return displayImage != null
                        ? GestureDetector(
                            onTap: () {
                              _showFullScreenImageDialog(Get.context!, displayImage);
                            },
                            child: Container(
                              width: 15.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: appTheme.appColor),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  displayImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink();
                  }),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Obx(() {
                      final displayImage = controller.capturedRouteImage.value;
                      return Text(
                        displayImage != null
                            ? 'Photo captured ✓'
                            : 'Tap camera to take photo',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: displayImage != null ? Colors.green : appTheme.darkGrey,
                          fontWeight: displayImage != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Divider(thickness: 1, color: appTheme.appColor),
            ],
          ),

          SizedBox(height: 1.h),

          // Buttons
          Column(
            children: [
              // Confirm Route Button
              Obx(() => Container(
                    width: double.infinity,
                    height: 6.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: appTheme.buttonGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: controller.isAddingRoute.value
                          ? null
                          : () => controller.confirmRouteCapture(),
                      child: controller.isAddingRoute.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: appTheme.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: appTheme.white,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Confirm Route',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: appTheme.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )),

              SizedBox(height: 1.5.h),

              // Cancel Button
              Container(
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: appTheme.appColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => controller.cancelRouteCapture(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: appTheme.appColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),
          _buildGoogleMap(),
        ],
      ),
    );
  }

  Widget _buildClockingInHeader({bool isClockOut = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isClockOut ? 'Clocking Out' : 'Clocking In',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: appTheme.darkGrey,
          ),
        ),
        SizedBox(height: 0.5.h),
        Obx(() => Text(
              isClockOut
                  ? (controller.clockOutTime.value.isNotEmpty
                      ? controller.clockOutTime.value
                      : DateFormat('MMM d \'at\' h:mm a')
                          .format(DateTime.now()))
                  : (controller.clockInTime.value.isNotEmpty
                      ? controller.clockInTime.value
                      : DateFormat('MMM d \'at\' h:mm a')
                          .format(DateTime.now())),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: appTheme.darkGrey,
              ),
            )),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: appTheme.darkGrey,
          ),
        ),
        SizedBox(height: 0.5.h),
        Obx(() => Row(
              children: [
                Icon(
                  Icons.location_pin,
                  color: appTheme.appThemeLight,
                  size: 18.sp,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    controller.currentAddress.value.isNotEmpty
                        ? controller.currentAddress.value
                        : 'Fetching location...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: appTheme.darkGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildShiftInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Shift',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: appTheme.darkGrey,
          ),
        ),
        SizedBox(height: 0.5.h),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.start, // CENTERED
              children: [
                Icon(
                  Icons.access_time,
                  color: appTheme.appThemeLight,
                  size: 18.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${controller.shiftStartTime.value} - ${controller.shiftEndTime.value} (${controller.shiftName.value})',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildGoogleMap() {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Obx(() {
          if (controller.currentPosition.value == null) {
            return Center(
              child: CircularProgressIndicator(
                color: appTheme.appColor,
              ),
            );
          }

          return GoogleMap(
            onMapCreated: controller.onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                controller.currentPosition.value!.latitude,
                controller.currentPosition.value!.longitude,
              ),
              zoom: 16.0,
            ),
            markers: controller.markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          );
        }),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Obx(() => Visibility(
          visible: controller.isManager.value,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text("Manager",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                      value: true,
                      thumbColor: WidgetStateProperty.all<Color>(Colors.white),
                      onChanged: (v) {
                        controller.toggleSwitch(v);
                      }),
                  Text("Employee",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildTimeRecordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Record your Time',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: appTheme.darkGrey,
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          '9:00 AM to 5:30 PM (Regular shift)',
          style: TextStyle(
            fontSize: 12.sp,
            color: appTheme.darkGrey,
          ),
        ),
        SizedBox(height: 0.5.h),
        Obx(() => Text(
              controller.todayWorkedHours.value.isNotEmpty
                  ? '${controller.todayWorkedHours.value} Today'
                  : '0h 00m Today',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: appTheme.darkGrey,
              ),
            )),
      ],
    );
  }

  Widget _buildClockInButton() {
    return Center(
      child: Obx(() => Container(
            width: 40.w,
            height: 6.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appTheme.buttonGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: controller.isLoadingLocation.value
                  ? null
                  : () {
                      controller.toggleClockInOut();
                    },
              child: controller.isLoadingLocation.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: appTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: appTheme.white,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          controller.isClockedIn.value
                              ? 'Clock Out'
                              : 'Clock In',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: appTheme.white,
                          ),
                        ),
                      ],
                    ),
            ),
          )),
    );
  }

  Widget _buildLocationInfo() {
    return Obx(() {
      // Only show if we have a valid clock-out time and location
      bool hasClockOutData = controller.clockOutTime.value.isNotEmpty;
      bool hasLocationData = controller.currentAddress.value.isNotEmpty &&
          controller.currentAddress.value != 'Fetching location...' &&
          controller.currentAddress.value != 'Location unavailable';

      // Don't show if no data available
      if (!hasClockOutData && !hasLocationData) {
        return SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_pin,
                  color: appTheme.appThemeLight,
                  size: 18.sp,
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (hasClockOutData)
                        Text(
                          'Clocked Out: ${controller.clockOutTime.value}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: appTheme.darkGrey,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (hasLocationData)
                        Text(
                          controller.currentAddress.value,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: appTheme.darkGrey.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTodayStats() {
    return GestureDetector(
      onTap: () => controller.showTimeDetailsDialog('today'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.w,
            height: 3.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appTheme.buttonGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child:Center(
              child: Text(
                'Today',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: appTheme.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() => _buildStatItem(
                    controller.todayWorkedHours.value.isNotEmpty
                        ? controller.todayWorkedHours.value
                        : '0h 00m',
                    'Worked hours',
                  )),
              Obx(() => _buildStatItem(
                    controller.todayBreakHours.value.isNotEmpty
                        ? controller.todayBreakHours.value
                        : '0h 00m',
                    'Break hours',
                  )),
              Obx(() => _buildStatItem(
                    controller.todayOverTime.value.isNotEmpty
                        ? controller.todayOverTime.value
                        : '0h 00m',
                    'Over Time',
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYesterdayStats() {
    return GestureDetector(
      onTap: () => controller.showTimeDetailsDialog('yesterday'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.w,
            height: 3.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appTheme.buttonGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'Yesterday',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: appTheme.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(controller.yesterdayWorkedHours.value.isNotEmpty ? controller.yesterdayWorkedHours.value : '0h 00m', 'Worked hours'),
                  _buildStatItem(controller.yesterdayShortHours.value.isNotEmpty ? controller.yesterdayShortHours.value : '0h 00m', 'Short hours'),
                  _buildStatItem(controller.yesterdayOverTime.value.isNotEmpty ? controller.yesterdayOverTime.value : '0h 00m', 'Over Time'),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats() {
    return GestureDetector(
      onTap: () => controller.showTimeDetailsDialog('week'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.w,
            height: 3.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appTheme.buttonGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'This Week',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: appTheme.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(controller.weekWorkedHours.value.isNotEmpty ? controller.weekWorkedHours.value : '0h 00m', 'Worked hours'),
                  _buildStatItem(controller.weekShortHours.value.isNotEmpty ? controller.weekShortHours.value : '0h 00m', 'Short hours'),
                  _buildStatItem(controller.weekOverTime.value.isNotEmpty ? controller.weekOverTime.value : '0h 00m', 'Over Time'),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return GestureDetector(
      onTap: () => controller.showTimeDetailsDialog('month'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.w,
            height: 3.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appTheme.buttonGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'This Month',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: appTheme.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(controller.monthWorkedHours.value.isNotEmpty ? controller.monthWorkedHours.value : '0h 00m', 'Worked hours'),
                  _buildStatItem(controller.monthShortHours.value.isNotEmpty ? controller.monthShortHours.value : '0h 00m', 'Short hours'),
                  _buildStatItem(controller.monthOverTime.value.isNotEmpty ? controller.monthOverTime.value : '0h 00m', 'Over Time'),
                ],
              )),
        ],
      ),
    );
  }


  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: appTheme.darkGrey,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: TextStyle(
              fontSize: 12.sp,
              color: appTheme.appColor,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
