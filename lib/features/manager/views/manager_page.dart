// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:payroll/features/leave_page/views/widgets/leave_card.dart';
import 'package:payroll/features/leave_page/views/widgets/popup.dart'
    hide LeaveHistoryPopup;
import 'package:payroll/features/manager/controller/manager_page_controller.dart';
import 'package:payroll/features/manager/views/apply_delegate_page.dart';
import 'package:payroll/features/manager/views/team_leave_history_page.dart';
import 'package:payroll/features/manager/views/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/common/status_legends.dart';
import '../../../util/custom_widgets.dart';
import '../../leave_page/model/leave_model.dart';
import 'leaves_item.dart';

class ManagerPage extends GetView<ManagerPageController> {
  ManagerPage({super.key});
  var appTheme = Get.find<ThemeController>().currentTheme;
  @override
  Widget build(BuildContext context) {
    appTheme = Get.find<ThemeController>().currentTheme;
    return RefreshIndicator(
      onRefresh: () async {
        // await controller.fetchData();
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
                      CustomHeader(
                        title: 'Teams Leave',
                      ),
                      GetBuilder<ManagerPageController>(
                        builder: (snapshot) {
                          if (snapshot.loading.value == Loading.loading) {
                            return Center(
                                child:
                                CircularProgressIndicator()); // Show loading
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2.h),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text("Manager",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Switch(
                                          value: true,
                                          thumbColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.white),
                                          onChanged: (v) {
                                            controller.toggleSwitch(v);
                                          }),
                                      Text("Employee",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
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
                                          padding:
                                          EdgeInsets.symmetric(vertical: 6),
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                        ),
                                        onPressed: () async {
                                          if (controller
                                              .isHavingDelegate.value) {
                                            final confirmed =
                                            await showRevokeConfirmationDialog();
                                            if (confirmed) {
                                              controller.removeDelegate();
                                            } else {
                                              return; // Stop here if user cancels
                                            }
                                          } else {
                                            controller.getCurrentDelegateData();
                                            Get.to(() => ApplyDelegatePage());
                                          }
                                        },
                                        child: Obx(
                                              () => Text(
                                            controller.isHavingDelegate.value
                                                ? "Revoke"
                                                : "Delegate",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w900,
                                              color: appTheme.white,
                                            ),
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              IgnorePointer(
                                ignoring: false,
                                child: TableCalendar(
                                  firstDay:
                                  DateTime(DateTime.now().year - 1, 10, 1),
                                  lastDay:
                                  DateTime(DateTime.now().year + 1, 3, 31),
                                  focusedDay: DateTime.now(),
                                  holidayPredicate: (day) {
                                    List<Holiday> holidays = snapshot.getCalendarDays();
                                    return holidays.any((holiday) =>
                                        isSameDay(holiday.holidayDate, day));
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    markerBuilder: (context, day, events) {
                                      List<Holiday> holidays = snapshot.getCalendarDays();
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
                                                color: Colors.black,
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
                                  onDaySelected: (selectedDay, focusedDay) async {
                                    // Set the selected date and get leave list
                                    controller.fromDate.value = selectedDay;
                                    await controller.getCalendarLeaveList();

                                    // Show leave list for the selected day
                                    String selectedDate = DateFormat('dd-MMM-yyyy').format(selectedDay);
                                    String selectedDayName = DateFormat('EEEE').format(selectedDay);

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            insetPadding: EdgeInsets.all(0),
                                            child: CalendarLeavePopup(
                                                selectedDate: selectedDate,
                                                selectedDay: selectedDayName,
                                                leaveHistory: controller.selectedDayLeaves ?? []
                                            )
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(child: StatusLegendManager()),
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
                                          padding:
                                          EdgeInsets.symmetric(vertical: 6),
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                        ),
                                        onPressed: () async {
                                          Get.to(() => TeamLeaveHistoryPage());
                                        },
                                        child: Text(
                                              "Leave History",
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
                              SizedBox(height: 1.h),
                              Text(
                                  textAlign: TextAlign.start,
                                  'Action Needed',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                  width: double.infinity,
                                  height: 70.h,
                                  child: leaveActionList())
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
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget leaveActionList() {
    return Column(
      children: [
        // Column Headers
        buildHeaderRow(),
        Expanded(
            child: Obx(() {
              final pendingItems = controller.leaveItems
                  .where((item) => item.leaveStatus?.toLowerCase() == 'pending')
                  .toList();
              return ListView.builder(
              itemCount: pendingItems.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item =  pendingItems[index];

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 0.5.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: appTheme.popUp2Border),
                    borderRadius:
                    BorderRadius.circular(8), // Outer border radius
                  ),
                  child: Column(
                    children: [
                      // Main Row
                      Container(
                        padding: EdgeInsets.all(0.5.h),
                        child: Row(
                          children: [
                            // EMPLOYEE NO.
                            Expanded(
                              flex:
                              3, // Choose flex according to desired width (ID smallest)
                              child: GestureDetector(
                                  onTap: () {
                                    controller.toggleExpanded(index);
                                  },
                                  child: buildSimpleText(item.employeeNo ?? "")),
                            ),
                            SizedBox(width: 1.w),

                            // NAME (clickable)
                            Expanded(
                              flex: 2, // Name is wider, more space
                              child: buildSimpleTextUnderLine(
                                item.employeeName ?? "",
                                onTap: () {
                                  // Filter leave history for the specific employee before showing dialog
                                  controller.filterAndSetLeaveHistory(item.employeeNo ?? "");

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          insetPadding: EdgeInsets.all(0),
                                          child: LeaveHistoryPopup(
                                            leaveHistory: controller.employeeLeaveHistory ?? [],
                                            empName:item.employeeName??"" ,
                                            empNo:item.employeeNo ??'' ,
                                          )
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            SizedBox(width: 1.w),

                            // LEAVE TYPE WITH BADGE
                            Expanded(
                              flex: 3, // Leave type also gets decent space
                              child: GestureDetector(
                                onTap: () {
                                  controller.toggleExpanded(index);
                                },
                                child: buildLeaveTypeWithBadge(
                                  item.planTypeName ?? '',
                                  item.noOfDays ?? '',
                                  item.leaveStatus ?? '',
                                ),
                              ),
                            ),

                            InkWell(
                              onTap: () {
                                controller.toggleExpanded(index);
                              },
                              child: Obx(() =>
                              controller.expandedIndex.value == index
                                  ? arrowIconUp()
                                  : arrowIconDown()),
                            ),
                          ],
                        ),
                      ),
                      // Expanded Content
                      Obx(() => controller.expandedIndex.value == index
                          ? AnimatedCrossFade(
                        firstChild: SizedBox.shrink(),
                        secondChild: buildExpandedContent(
                          item,
                          onApprove: () async {
                            final result =
                            await showLeaveConfirmationDialog(
                                item.employeeName ?? "", true);
                            if (result != null && result['confirmed'] == true) {
                              controller.updateLeaveStatus(item, true, remarks: result['remarks'] ?? '');
                            }
                          },
                          onReject: () async {
                            final result =
                            await showLeaveConfirmationDialog(
                                item.employeeName ?? "", false);
                            if (result != null && result['confirmed'] == true) {
                              controller.updateLeaveStatus(item, false, remarks: result['remarks'] ?? '');
                            }
                          },
                        ),
                        crossFadeState:
                        controller.expandedIndex.value == index
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: Duration(milliseconds: 300),
                      )
                          : SizedBox.shrink())
                    ],
                  ),
                );
              },
            );
            })),
      ],
    );
  }
}
