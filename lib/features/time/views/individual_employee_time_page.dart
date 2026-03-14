
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../controller/individual_employee_time_controller.dart';

class IndividualEmployeeTimePage extends GetView<IndividualEmployeeTimeController> {
  const IndividualEmployeeTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Scaffold(
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
                icon: FaIcon(FontAwesomeIcons.ellipsis),
                iconSize: 22.sp,
                color: appTheme.appThemeLight,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeader(title: 'Team Time'),
              SizedBox(height: 2.h),

              // Individual Dashboard Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: appTheme.buttonGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'Individual Dashboard',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: appTheme.white,
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              // Date Range Row
              Row(
                children: [
                  _buildDateSelector('From', context, true, appTheme),
                  SizedBox(width: 3.w),
                  _buildDateSelector('To', context, false, appTheme),
                ],
              ),
              SizedBox(height: 2.h),

              // Employee Selector
              _buildEmployeeSelector(context, appTheme),
              SizedBox(height: 2.h),

              // Shift Tabs
              _buildShiftTabs(appTheme),
              SizedBox(height: 2.h),

              // Details Table
              _buildDetailsTable(appTheme),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomBottomNaviBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildDateSelector(String label, BuildContext context, bool isFrom, dynamic appTheme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appTheme.buttonGradient,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: appTheme.white,
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          GestureDetector(
            onTap: () => controller.selectDate(context, isFrom),
            child: Row(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                      child: Obx(() => Text(
                        isFrom ? controller.formattedFromDate : controller.formattedToDate,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: appTheme.darkGrey,
                        ),
                      )),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.calendar_month,
                  color: appTheme.appColor,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSelector(BuildContext context, dynamic appTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appTheme.buttonGradient,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            'Select Emp',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: appTheme.white,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: GestureDetector(
            onTap: () => _showEmployeeDropdown(context, appTheme),
            child: Row(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      child: Obx(() => Text(
                        '${controller.selectedEmployee.value['empName']?? 'Select Employee'} (${controller.selectedEmployee.value['empNo']??""})' ,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: appTheme.darkGrey,
                        ),
                      )),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                _buildArrowIconDown(appTheme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrowIconDown(dynamic appTheme) {
    return Container(
      width: 8.w,
      height: 4.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: appTheme.appColor,
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.angleDown,
          color: Colors.white,
          size: 16.sp,
        ),
      ),
    );
  }

  void _showEmployeeDropdown(BuildContext context, dynamic appTheme) {
    final selectedEmp = controller.selectedEmployee.value;
    final initialIndex = controller.employeeList.indexWhere(
          (emp) => emp['empId'] == selectedEmp['empId'],
    );

    final scrollController = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : 0,
    );

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 30.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appTheme.darkGrey,
        ),
        child: Column(
          children: [
            Container(
              height: 5.h,
              color: Colors.white,
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.employeeList.isEmpty) {
                  return Center(
                    child: Text(
                      'No employees found',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  );
                }
                return CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 40,
                  scrollController: scrollController,
                  onSelectedItemChanged: (int index) {
                    controller.selectEmployee(controller.employeeList[index]);
                  },
                  children: controller.employeeList.map((emp) {
                    return Center(
                      child: Text(
                        emp['empName'] ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Build shift tabs row
  Widget _buildShiftTabs(dynamic appTheme) {
    return Obx(() {
      if (controller.shiftTabs.isEmpty) return SizedBox.shrink();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.shiftTabs.asMap().entries.map((entry) {
            final index = entry.key;
            final shift = entry.value;
            final isSelected = controller.selectedShiftIndex.value == index;

            return Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: GestureDetector(
                onTap: () => controller.selectShiftTab(index),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: appTheme.buttonGradient)
                        : null,
                    color: isSelected ? null : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(50),
                    border: isSelected
                        ? null
                        : Border.all(color: appTheme.appColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    shift['shiftName'] ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? appTheme.white : appTheme.darkGrey,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  /// Build the details table
  Widget _buildDetailsTable(dynamic appTheme) {
    return Obx(() {
      if (controller.detailsLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: CircularProgressIndicator(color: appTheme.appColor),
          ),
        );
      }

      final details = controller.filteredTimeDetails;

      if (details.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              'No records found',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
        );
      }

      return Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: appTheme.appColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // _buildTableHeader('EMP ID', appTheme, flex: 2),
                _buildTableHeader('Date', appTheme, flex: 2),
                _buildTableHeader('A.Entry', appTheme, flex: 2),
                _buildTableHeader('A.Exit', appTheme, flex: 2),
                _buildTableHeader('Break', appTheme, flex: 2),
              ],
            ),
          ),

          // Table Rows
          ...details.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> detail = entry.value;
            bool isLastRow = index == details.length - 1;
            return _buildDetailRow(detail, appTheme, isLastRow);
          }),
        ],
      );
    });
  }

  Widget _buildTableHeader(String label, dynamic appTheme, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: appTheme.appColor,
        ),
      ),
    );
  }

  Widget _buildDetailRow(Map<String, dynamic> detail, dynamic appTheme, bool isLastRow) {
    final empNo = detail['employee_no']?.toString() ?? '';
    final date = controller.formatApiDate(detail['date']?.toString());
    final actualEntry = detail['actual_start_time']?.toString() ?? '';
    final actualExit = detail['actual_end_time']?.toString() ?? '';
    final breakTime = detail['actual_break']?.toString() ?? '-';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: appTheme.appColor.withOpacity(0.3), width: 1),
          right: BorderSide(color: appTheme.appColor.withOpacity(0.3), width: 1),
          bottom: BorderSide(
            color: appTheme.appColor.withOpacity(0.3),
            width: isLastRow ? 1 : 0.5,
          ),
        ),
        borderRadius: isLastRow
            ? BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        )
            : null,
      ),
      child: Row(
        children: [
          // _buildTableCell(empNo, appTheme, flex: 2),
          _buildTableCell(date, appTheme, flex: 2),
          _buildTableCell(actualEntry, appTheme, flex: 2),
          _buildTableCell(actualExit, appTheme, flex: 2),
          _buildTableCell(breakTime, appTheme, flex: 2),
        ],
      ),
    );
  }

  Widget _buildTableCell(String value, dynamic appTheme, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: appTheme.black87,
        ),
      ),
    );
  }

}
