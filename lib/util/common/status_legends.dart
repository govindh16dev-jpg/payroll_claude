

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../theme/theme_controller.dart';

class StatusLegend extends StatelessWidget {
  const StatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildStatusIndicator(appTheme.calendarApproved, "Approved"),
          _buildStatusIndicator(appTheme.calendarHoliday, "Holiday"),
          _buildStatusIndicator(appTheme.calendarPending, "Pending"),
          _buildStatusIndicator(appTheme.calendarRejected, "Rejected"),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: [
          Container(
            width:4.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
class StatusLegendManager extends StatelessWidget {
  const StatusLegendManager({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildStatusIndicator(appTheme.calendarHoliday, "Holiday"),
          _buildStatusIndicator(appTheme.calendarPending, "Team Leave"),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: [
          Container(
            width:4.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
class StatusLegendTime extends StatelessWidget {
  const StatusLegendTime({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildStatusIndicator(appTheme.calendarHoliday, "Holiday"),
          _buildStatusIndicator(appTheme.calendarPending, "Short Hours"),
          _buildStatusIndicator(appTheme.calendarOvertime, "Overtime"),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: [
          Container(
            width:4.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}