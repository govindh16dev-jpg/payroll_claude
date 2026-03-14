// ignore_for_file: library_private_types_in_public_api, empty_catches

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sizer/sizer.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../controller/leave_page_controller.dart';
import '../model/leave_model.dart';

class ApplyLeavePage extends GetView<LeavePageController> {
    ApplyLeavePage({super.key});
  var appTheme = Get.find<ThemeController>().currentTheme;
  @override
  Widget build(BuildContext context) {
     appTheme = Get.find<ThemeController>().currentTheme;
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      final isMobile =
          sizingInformation.deviceScreenType == DeviceScreenType.mobile;
      return Scaffold(
        resizeToAvoidBottomInset: false,
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
            SingleChildScrollView(
              controller: controller.scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomHeader(
                      title: 'Apply Leave',
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    _buildRowDateSelect("From", context, isMandatory: true),
                    _buildRowDateSelect("To", context, isMandatory: true),
                    _buildRowLabelField("Leave", context, isDropdown: true),
                    Obx(() => Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 12.0),
                          child: Text(
                            'Remaining leaves ${controller.selectedLeaveRemaining.value} days',
                            style: TextStyle(
                                color: appTheme.appThemeLight, fontSize: 14.sp),
                          ),
                        )),
                    _buildRowDateSelect("No of days", context, isFilled: true),
                    _buildRowLabelDropdown("Date", context, true),
                    Obx(() => controller.selectedDayTypeIDFromDate.value == '2'
                        ? _buildRowLabelField("From", context, isFromDate: true)
                        : SizedBox.shrink()),
                    Obx(() {
                      final totalLeaveDays = int.tryParse(controller.totalLeaveDays.value) ?? 0;
                      final showToField = controller.selectedDayTypeIDToDate.value == '2';

                      return Column(
                        children: [
                          if (totalLeaveDays > 1) _buildRowLabelDropdown("Date", context, false),
                          if (totalLeaveDays > 1 && showToField)
                            _buildRowLabelField("To", context),
                        ],
                      );
                    }),

                    _buildRowLabelField("Reason", context, isReason: true),
                    SizedBox(height: 3.h),
                    _buildActionButtons(context),
                    SizedBox(
                      height: 30.h,
                    ),
                  ],
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
      );
    });
  }

  Widget _buildRowLabelDropdown(
      String label, BuildContext context, bool isFromDate) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 20.w,
              child: Text(
                label,
                style: TextStyle(
                    color: appTheme.darkGrey, fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 2.w,
          ),
          _buildDateWithButtonDay(context, true, isFromDate),
        ],
      ),
    );
  }

  Widget _buildRowLabelField(String label, BuildContext context,
      {bool isDropdown = false,
      bool isFromDate = false,
      bool isReason = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width:controller.labelWidth,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: TextStyle(
                          color: appTheme.darkGrey,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
          SizedBox(
            width: 2.w,
          ),
          isReason
              ? SizedBox(
                  width: 60.w,
                  child: CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            maxLines: 4,
                            controller: controller.reasonController,
                            focusNode: controller.focusNode,
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
                )
              : isDropdown
                  ? _buildDropdown(context)
                  : Expanded(child: _buildTimeRange(isFromDate, context)),
        ],
      ),
    );
  }
//todo fix extra border
  Widget _buildRowDateSelect(
    String label,
    BuildContext context, {
    bool isMandatory = false,
    bool isFilled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: controller.labelWidth,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: TextStyle(
                          color: appTheme.darkGrey,
                          fontWeight: FontWeight.bold),
                    ),
                    if (isMandatory)
                      TextSpan(
                        text: " *",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              )),
          SizedBox(
            width: 2.w,
          ),
          GestureDetector(
            onTap: () {
              controller.selectDate(context, label == 'From');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: isFilled ? 20.w : controller.inputWidth,
                  child: CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          height: 4.h,
                          alignment: Alignment.centerLeft,
                          child: Obx(() => TextField(
                                readOnly: true,
                                textAlign: isFilled
                                    ? TextAlign.center
                                    : TextAlign.start,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  hintStyle: TextStyle(fontSize: 16.sp),
                                  hintText: isFilled
                                      ? controller.totalLeaveDays.value
                                      : label == 'From'
                                          ? controller.fromDate.value != null
                                              ? DateFormat('dd/MM/yyyy').format(
                                                  controller.fromDate.value!)
                                              : 'Select Date'
                                          : controller.toDate.value != null
                                              ? DateFormat('dd/MM/yyyy').format(
                                                  controller.toDate.value!)
                                              : 'Select Date',
                                  filled: isFilled,
                                  fillColor: appTheme.appGradient,
                                ),
                              ))),
                    ),
                  ),
                ),
                if (!isFilled)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Icon(
                      Icons.calendar_month,
                      color: appTheme.appThemeLight,
                      size: 22.sp,
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDottedBorderTextFieldTime(
      bool isFromDate, context, bool isStartDate) {
    return GestureDetector(
      onTap: (){
        controller.selectTime(context, isFromDate, isStartDate);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 20.w,
            child: CustomPaint(
              painter: DottedBorderPainter(),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  height: 4.h,
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                        hintStyle: TextStyle(fontSize: 16.sp, color: appTheme.darkGrey),
                        hintText: controller.formatTimeOfDay((isFromDate
                                    ? (isStartDate
                                        ? controller.fromDateStart.value
                                        : controller.fromDateEnd.value)
                                    : (isStartDate
                                        ? controller.toDateStart.value
                                        : controller.toDateEnd.value)) ??
                                TimeOfDay(hour: 0, minute: 0) // Default fallback
                            ),
                        fillColor: appTheme.greyBox,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              Icons.access_time_rounded,
              color: appTheme.appThemeLight,
              size: 20.sp,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDottedBorderTextFieldDate(
      bool isFilled, context, bool isFromDate) {
    return CustomPaint(
      painter: DottedBorderPainter(),
      child: Align(
        alignment: Alignment.center,
        child: Container(
            height: 4.h,
            padding: EdgeInsets.symmetric(horizontal: 0),

            child: Obx(() => TextField(
                  readOnly: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14.sp),
                    contentPadding: EdgeInsets.only(bottom: 10),
                    hintText: isFromDate
                        ? controller.fromDate.value != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(controller.fromDate.value!)
                            : 'Select Date'
                        : controller.toDate.value != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(controller.toDate.value!)
                            : 'Select Date',
                    filled: isFilled,
                    fillColor: appTheme.greyBox,
                  ),
                ))),
      ),
    );
  }
//todo handle the vertical padding fix
  Widget _buildDropdown(context) {
    return GestureDetector(
      onTap: () {
        _buildDropdownScroll(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: controller.inputWidth,
            child: CustomPaint(
              painter: DottedBorderPainter(),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 4.h,
                  alignment: Alignment.centerLeft,
                  child: Obx(
                    () => Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      controller.selectedLeaveType.value.leavePlanTypeName ??
                          'Select leave',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  )),
            ),
          ),
          arrowIconDown()
        ],
      ),
    );
  }

  Widget arrowIconDown(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: 7.w,
        height: 7.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appTheme.appColor, // Background color
        ),
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.angleDown, // FontAwesome down-arrow icon
            color: Colors.white,
            size: 16.sp,
          ),
        ),
      ),
    );
  }
  _buildDropdownScroll(BuildContext context) {
    final selectedLeave = controller.selectedLeaveType.value;

    final initialIndex =   controller.leaveTypeDropdown!
        .indexWhere((item) => item.leavePlanTypeId == selectedLeave.leavePlanTypeId);

    final scrollController = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : 0,
    );

    return showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 30.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appTheme.darkGrey,
        ),
        child: Column(
          children: [
            // Done Button
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
                  var selectedLeave = controller.leaveTypeDropdown![index];
                  controller.selectedLeaveTypeID.value = selectedLeave.leavePlanTypeId!;
                  controller.selectedLeaveType.value = selectedLeave;
                  controller.setRemainingLeaves();
                },
                children: controller.leaveTypeDropdown!
                    .map((LeaveDetail leave) {
                  return Text(leave.leavePlanTypeName ?? '');
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDateWithButtonDay(
      BuildContext context, bool isFilled, bool isFromDate) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 25.w,
            child:
                _buildDottedBorderTextFieldDate(isFilled, context, isFromDate)),
        SizedBox(width: 2.w),
          _buildDayDropdown(context,isFromDate,)
      ],
    );
  }
  _buildDayDropdownScroll(BuildContext context, bool isFromDate) {
    // Get selected ID based on isFromDate
    final selectedId = isFromDate
        ? controller.selectedDayTypeIDFromDate.value
        : controller.selectedDayTypeIDToDate.value;

    // Find index of selected ID in the dropdown list
    final initialIndex = controller.leaveDayDropdown?.indexWhere(
          (item) => item.leavePlanTypeId == selectedId,
    ) ?? 0;

    final scrollController = FixedExtentScrollController(
      initialItem: (initialIndex >= 0) ? initialIndex : 0,
    );

    return showCupertinoModalPopup(
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
                  final selectedLeaveId =
                      controller.leaveDayDropdown?[index].leavePlanTypeId ?? "";
                  if (isFromDate) {
                    controller.selectedDayTypeIDFromDate.value = selectedLeaveId;
                  } else {
                    controller.selectedDayTypeIDToDate.value = selectedLeaveId;
                  }
                  controller.setRemainingLeaves();
                },
                children: controller.leaveDayDropdown?.map((LeaveType leave) {
                  return Center(
                    child: Text(
                      leave.leaveName ?? '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList() ??
                    [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDropdown(BuildContext context,isFromDate) {
    return GestureDetector(
      onTap: (){
        _buildDayDropdownScroll(context,isFromDate);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 25.w,
            child: Container(
              width: double.infinity,
              height: 4.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: appTheme.buttonGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {},
                  child: Obx(
                    () => Text(
                      isFromDate
                          ? controller.selectedDayTypeIDFromDate.value=="1"?"Full day":"Less than a day"
                          : controller.selectedDayTypeIDToDate.value=="1"?"Full day":"Less than a day",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: appTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ),
          ),
          arrowIconDown()
        ],
      ),
    );
  }

  Widget _buildTimeRange(bool isFromDate, context) {
    return Row(
      children: [
        Expanded(
            child: _buildDottedBorderTextFieldTime(isFromDate, context, true)),
        SizedBox(width: 2.w),
        Text("To"),
   SizedBox(width: 2.w),
       Expanded(
            child: _buildDottedBorderTextFieldTime(isFromDate, context, false)),
      ],
    );
  }

  Widget _buildActionButtons(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 35.w,
          height: 5.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appTheme.bannerGradient,
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
              // showDialog(
              //   context: context,
              //   builder: (BuildContext context) {
              //     return Dialog(
              //         backgroundColor: Colors.transparent, // Transparent background
              //         elevation: 0,
              //         insetPadding: EdgeInsets.all(0),
              //         child: ApplyLeaveSuccessPopup());
              //   },
              // );
            },
            child: Text(
              "Upload",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: appTheme.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 5.w),
        Container(
          width: 35.w,
          height: 5.h,
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
              controller.onLeaveRequest(context);
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
      ],
    );
  }
}
