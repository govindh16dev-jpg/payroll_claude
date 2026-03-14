import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../controller/shift_filter_controller.dart';

class ShiftFilterPage extends GetView<ShiftFilterController> {
  const ShiftFilterPage({super.key});

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

              // Shift Selector
              _buildShiftSelector(context, appTheme),
              SizedBox(height: 2.h),

              // Selected Shift Display
              Obx(() => _buildShiftDisplay(appTheme)),
              SizedBox(height: 1.h),

              // Employee Cards Section
              Obx(() => _buildEmployeeList(appTheme)),
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

  Widget _buildShiftSelector(BuildContext context, dynamic appTheme) {
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
            'Shift',
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
            onTap: () => _showShiftDropdown(context, appTheme),
            child: Row(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      child: Obx(() => Text(
                        controller.selectedShift.value['shiftId'] == 'all'
                            ? 'All'
                            : controller.selectedShift.value['shiftTime'] ?? 'Select Shift',
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
                Container(
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showShiftDropdown(BuildContext context, dynamic appTheme) {
    final selectedShift = controller.selectedShift.value;
    final initialIndex = controller.shiftList.indexWhere(
          (shift) => shift['shiftId'] == selectedShift['shiftId'],
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
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 40,
                scrollController: scrollController,
                onSelectedItemChanged: (int index) {
                  controller.selectShift(controller.shiftList[index]);
                },
                children: controller.shiftList.map((shift) {
                  return Center(
                    child: Text(
                      shift['shiftTime'] ?? '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftDisplay(dynamic appTheme) {
    final shift = controller.selectedShift.value;
    if (shift.isEmpty) return SizedBox.shrink();

    // Don't show shift badge if "All" is selected, show in selector
    if (shift['shiftId'] == 'all') return SizedBox.shrink();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appTheme.buttonGradient,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            'Shift    ${shift['shiftTime'] ?? ''}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: appTheme.white,
            ),
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildEmployeeList(dynamic appTheme) {
    if (controller.loading.value) {
      return Center(child: CircularProgressIndicator());
    }

    final employees = controller.employeeShiftList;

    if (employees.isEmpty) {
      return Center(
        child: Text(
          'No employees found for this shift',
          style: TextStyle(
            fontSize: 14.sp,
            color: appTheme.darkGrey,
          ),
        ),
      );
    }

    final selectedShiftId = controller.selectedShift.value['shiftId'];

    // Grouping Logic for "All" shifts
    if (selectedShiftId == 'all' || selectedShiftId == '' || selectedShiftId == null) {
       // Group by shiftId
       Map<String, List<Map<String, String>>> grouped = {};
       for (var emp in employees) {
         String sid = emp['shiftId'] ?? 'Unknown';
         if (!grouped.containsKey(sid)) grouped[sid] = [];
         grouped[sid]!.add(emp);
       }
       
       List<Widget> children = [];
       grouped.forEach((sid, list) {
          // Use shiftName from the data (populated by controller)
          String sName = list.first['shiftName'] ?? 'Shift $sid';
          if (sName.isEmpty) {
            // Fallback: find name from dropdown list
            try {
              final match = controller.shiftList.firstWhere((s) => s['shiftId'] == sid);
              sName = match['shiftTime'] ?? match['shiftName'] ?? 'Shift $sid';
            } catch (e) {
              sName = 'Shift $sid';
            }
          }

           children.add(_buildSectionHeader(sName, appTheme));
           children.add(_buildListHeader(appTheme));
           children.addAll(list.map((e) => _buildEmployeeRow(e, appTheme)));
           children.add(SizedBox(height: 2.h)); // Spacing between groups
       });
       return Column(children: children);
    }

    // Default View (Specific Shift)
    return Column(
      children: [
        _buildListHeader(appTheme),
        SizedBox(height: 1.h),
        ...employees.map((emp) => _buildEmployeeRow(emp, appTheme)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, dynamic appTheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.h, top: 1.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: appTheme.buttonGradient,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
          color: appTheme.white,
        ),
      ),
    );

  }

  Widget _buildListHeader(dynamic appTheme) {
    // Helper for Header Text
    Widget headerText(String text, {TextAlign align = TextAlign.left}) {
      return Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7B61FF), // Purple/Blue color from screenshot
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        children: [
          // EMP ID Header
          Expanded(
            flex: 3, // Increased flex for ID
            child: headerText('EMP ID'),
          ),
          // Name Header
          Expanded(
            flex: 4,
            child: headerText('Name'),
          ),
          // FROM Header
          Expanded(
            flex: 2,
            child: headerText('FROM', align: TextAlign.center),
          ),
          // TO Header
          Expanded(
            flex: 2,
            child: headerText('TO', align: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(Map<String, String> emp, dynamic appTheme) {
    return Container(
      // Padding for the row content
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align top for multi-line names
            children: [
              // EMP ID Data
              Expanded(
                flex: 3, // Match header flex
                child: Text(
                  emp['empId'] ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: appTheme.black87,
                  ),
                ),
              ),

              // Name Data
              Expanded(
                flex: 4,
                child: Text(
                  emp['empName'] ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: appTheme.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // A.Entry (FROM) Data
              Expanded(
                flex: 2,
                child: Text(
                  emp['from'] ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: appTheme.black87.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // A.Exit (TO) Data
              Expanded(
                flex: 2,
                child: Text(
                  emp['to'] ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: appTheme.black87.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // Custom Gradient Divider
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.3), // Light start
                  Colors.pinkAccent.withOpacity(0.5), // Pink end
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          )
        ],
      ),
    );
  }

}
