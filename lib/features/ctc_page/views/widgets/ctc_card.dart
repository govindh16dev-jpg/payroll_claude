import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/appstates.dart';
import '../../../../theme/theme_controller.dart';
import '../../controller/ctc_page_controller.dart';

class CTCBannerProfile extends GetView<CTCPageController> {
  final appStateController = Get.put(AppStates());

  CTCBannerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appTheme.bannerGradient, // Use appTheme gradient
        ),
      ),
      child: Obx(() {
        if (controller.employeeInfo.isEmpty) {
          return SizedBox(height: 15.h);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top row with name and financial year
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.getFormattedEmployeeName(),
                  style: TextStyle(
                    color: appTheme.white, // Use appTheme white
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //   decoration: BoxDecoration(
                //     color: appTheme.white.withOpacity(0.2), // Use appTheme white with opacity
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Text(
                //     controller.selectedYear.value.financialLabel ?? '2024-2025',
                //     style: TextStyle(
                //       color: appTheme.white, // Use appTheme white
                //       fontSize: 12.sp,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 8),

            // Designation and Department
            Text(
              controller.getEmployeeDesignationDepartment(),
              style: TextStyle(
                color: appTheme.white, // Use appTheme white with opacity
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),

            // DOB and DOJ row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.getFormattedDOB(),
                  style: TextStyle(
                    color: appTheme.white, // Use appTheme white with opacity
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  "  |  ",
                  style: TextStyle(
                    color: appTheme.white, // Use appTheme white with opacity
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  controller.getFormattedDOJ(),
                  style: TextStyle(
                    color: appTheme.white, // Use appTheme white with opacity
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
