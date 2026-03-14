import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../controller/time_page_controller.dart';

class OvertimePage extends StatelessWidget {
  OvertimePage({super.key});

  final controller = Get.find<TimePageController>();
  var appTheme = Get.find<ThemeController>().currentTheme;

  @override
  Widget build(BuildContext context) {
    appTheme = Get.find<ThemeController>().currentTheme;

    // Initialize data with selected date
    if (Get.arguments != null && Get.arguments['date'] != null) {
      controller.initOvertimeData(Get.arguments['date']);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHeader(title: 'Apply Overtime'),
                  SizedBox(height: 4.h),

                  _buildRowField("Date", controller.overtimeDateController,
                      isReadOnly: true,
                      hasIcon: true,
                      icon: Icons.calendar_month,
                      onTap: () => controller.selectOvertimeDate(context)),
                  _buildRowField("Clocked In", controller.overtimeClockInController,
                      hasIcon: true,
                      icon: Icons.access_time_rounded,
                      onTap: () => controller.selectOvertimeTime(context, 'clockIn')),
                  _buildRowField("Clocked Out", controller.overtimeClockOutController,
                      hasIcon: true,
                      icon: Icons.access_time_rounded,
                      onTap: () => controller.selectOvertimeTime(context, 'clockOut')),
                  _buildRowField("Over Time", controller.overtimeOvertimeController,
                      isReadOnly: true,
                      width: 25),
                  _buildRowField("Base rate", controller.overtimeBaseRateController,
                      width: 25),
                  _buildRowField("Reason", controller.overtimeReasonController,
                      isReason: true,
                      isMandatory: true),

                  SizedBox(height: 3.h),
                  _buildActionButton(context),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
          Obx(() => Visibility(
            visible: controller.loading.value == Loading.loading,
            child: loadingIndicator(),
          )),
        ],
      ),
      floatingActionButton: CustomBottomNaviBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildRowField(
      String label,
      TextEditingController textController, {
        bool isReadOnly = false,
        bool hasIcon = false,
        IconData? icon,
        bool isReason = false,
        bool isMandatory = false,
        double? width,
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16.0),
      child: Row(
        crossAxisAlignment: isReason ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 25.w,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      color: appTheme.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
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
            ),
          ),
          SizedBox(width: 2.w),
          if (isReason)
            Expanded(
              child: CustomPaint(
                painter: DottedBorderPainter(),
                child: TextField(
                  controller: textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    hintStyle: TextStyle(fontSize: 16.sp),
                    hintText: 'Type in the reason',
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: SizedBox(
                    width: width != null ? width.w : 40.w,
                    child: CustomPaint(
                      painter: DottedBorderPainter(),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        height: 4.h,
                        alignment: Alignment.centerLeft,
                        child: AbsorbPointer(
                          child: TextField(
                            controller: textController,
                            readOnly: isReadOnly || onTap != null,
                            textAlign: width != null ? TextAlign.center : TextAlign.start,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              hintStyle: TextStyle(fontSize: 16.sp),
                              hintText: label == "Date" ? 'dd/mm/yyyy' : label == "Base rate" ? '1.5x' : '00:00:00',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasIcon)
                  GestureDetector(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Icon(
                        icon,
                        color: appTheme.appThemeLight,
                        size: 22.sp,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
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
          onPressed: () => controller.submitOvertime(),
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
    );
  }
}
