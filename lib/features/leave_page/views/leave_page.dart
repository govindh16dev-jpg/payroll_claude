// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:payroll/features/leave_page/controller/leave_page_controller.dart';
import 'package:payroll/features/leave_page/views/widgets/leave_card.dart';
import 'package:payroll/features/leave_page/views/widgets/popup.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/common/status_legends.dart';
import '../../../util/custom_widgets.dart';
import '../model/leave_model.dart';
import 'apply_leave_page.dart';

class LeavePage extends GetView<LeavePageController> {
  final bool fromHome;

    LeavePage({required this.fromHome, super.key});
  var appTheme = Get.find<ThemeController>().currentTheme;
  @override
  Widget build(BuildContext context) {
    appTheme = Get.find<ThemeController>().currentTheme;
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      final isMobile =
          sizingInformation.deviceScreenType == DeviceScreenType.mobile;
      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchLeaveData();
        },
        child: Scaffold(
          drawer: CustomDrawer(),
          drawerEnableOpenDragGesture: false,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(5.h),
            child: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child:  Builder(
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
                onHorizontalDragEnd: (details) {
                  // if (details.primaryVelocity! > 0) {
                  //   controller.onSwipeLeft();
                  // } else if (details.primaryVelocity! < 0) {
                  //   controller.onSwipeRight();
                  //   // _onSwipeLeft();
                  // }
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        CustomHeader(title: 'Your Leave',),
                        BannerCarousel(),
                        GetBuilder<LeavePageController>(
                          builder: ( snapshot)   {
                            if (snapshot.loading.value==
                                Loading.loading) {
                              return Center(
                                  child:
                                      CircularProgressIndicator()); // Show loading
                            }
                            List<Holiday> holidays =   snapshot.getCalendarDays();
                            return Column(
                              children: [
                                SizedBox(height: 2.h),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text("Manager",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)),

                                            Obx(() => Switch(
                                              value: controller.isManager.value,
                                              thumbColor: WidgetStateProperty.all<Color>(Colors.white),
                                              inactiveThumbColor:  Colors.green,
                                              onChanged: controller.toggleSwitch,
                                            )),
                                            Text("Employee",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        // Container(
                                        //   width: 35.w,
                                        //   height: 4.h,
                                        //   decoration: BoxDecoration(
                                        //     gradient: LinearGradient(
                                        //       colors: appTheme.buttonGradient,
                                        //       begin: Alignment.centerLeft,
                                        //       end: Alignment.centerRight,
                                        //     ),
                                        //     borderRadius: BorderRadius.circular(50),
                                        //   ),
                                        //   child: ElevatedButton(
                                        //     style: ElevatedButton.styleFrom(
                                        //       padding: EdgeInsets.symmetric(vertical: 6),
                                        //       backgroundColor: Colors.transparent,
                                        //       shadowColor: Colors.transparent,
                                        //     ),
                                        //     onPressed: () {
                                        //       showDialog(
                                        //         context: context,
                                        //         builder: (BuildContext context) {
                                        //           return Dialog(
                                        //               backgroundColor: Colors.transparent,
                                        //               // Transparent background
                                        //               elevation: 0,
                                        //               insetPadding: EdgeInsets.all(0),
                                        //               child: LeaveHistoryPopup(
                                        //                   leaveHistory:
                                        //                       controller.leaveHistory!));
                                        //         },
                                        //       );
                                        //     },
                                        //     child: Text(
                                        //       "Leave History",
                                        //       style: TextStyle(
                                        //         fontSize: 16.sp,
                                        //         fontWeight: FontWeight.w900,
                                        //         color: appTheme.white,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Get.to(() => ApplyLeavePage());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: appTheme.appThemeLight,
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(10),
                                              ),
                                              child: Icon(Icons.add,
                                                  color: appTheme.white),
                                            ),
                                            Text("Apply Leave",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Text("Leave Status",
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildStatusCircle(
                                            controller.leaveHistory?.length
                                                .toString() ??
                                                '',
                                            "Applied",
                                            context,
                                            controller.leaveHistory),
                                        buildStatusCircle(
                                            controller
                                                .getApprovedLeaves()
                                                ?.length
                                                .toString() ??
                                                "",
                                            "Approved",
                                            context,
                                            controller.getApprovedLeaves()),
                                        buildStatusCircle(
                                            controller
                                                .getPendingLeaves()
                                                ?.length
                                                .toString() ??
                                                "",
                                            "Pending",
                                            context,
                                            controller.getPendingLeaves()),
                                        buildStatusCircle(
                                            controller
                                                .getRejectedLeaves()
                                                ?.length
                                                .toString() ??
                                                "",
                                            "Rejected",
                                            context,
                                            controller.getRejectedLeaves()),
                                      ],
                                    ),
                                    SizedBox(height: 20),
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
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                  backgroundColor: Colors.transparent,
                                                  // Transparent background
                                                  elevation: 0,
                                                  insetPadding: EdgeInsets.all(0),
                                                  child: HolidayPopup(
                                                      holidayList:
                                                      controller.holidayList!));
                                            },
                                          );
                                        },
                                        child: Text(
                                          "Holidays List",
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
                                SizedBox(height: 2.h),
                                TableCalendar(
                                  firstDay: DateTime(DateTime.now().year - 1, 10, 1),
                                  lastDay: DateTime(DateTime.now().year + 1, 3, 31),
                                  focusedDay: DateTime.now(),
                                  holidayPredicate: (day) {
                                    return holidays.any((holiday) =>
                                        isSameDay(holiday.holidayDate, day));
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    markerBuilder: (context, day, events) {
                                      Holiday? holiday = holidays.firstWhere(
                                        (holiday) =>
                                            isSameDay(holiday.holidayDate, day),
                                        orElse: () => Holiday(
                                          holidayName: "",
                                          holidayDate: DateTime(2000, 1, 1),
                                        ),
                                      );

                                      if (holiday.holidayName!.isNotEmpty) {
                                        return Container(
                                          width: 10.w,
                                          height: 10.h,
                                          decoration: BoxDecoration(
                                            color: controller.getHolidayColor(
                                                holiday.status ?? ''),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${day.day}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
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
                                  onDaySelected: (selectedDay, focusedDay) {
                                    // Check if selected day is a holiday
                                    Holiday? holiday = holidays.firstWhere(
                                      (holiday) => isSameDay(
                                          holiday.holidayDate, selectedDay),
                                      orElse: () => Holiday(
                                          holidayName: "",
                                          holidayDate: DateTime(2000, 1, 1)),
                                    );

                                    if (holiday.holidayName!.isNotEmpty) {
                                      showLeaveDetailsDialog(context, holiday);
                                    }
                                  },
                                ),
                                StatusLegend()
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 15.h),
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.startFloat,
        ),
      );
    });
  }
}
