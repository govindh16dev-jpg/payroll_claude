import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';

class TimeDetailsPopup extends StatelessWidget {
  final List<Map<String, String>> data;
  final String title;
  final String workedHours;
  final String shortHours;
  final String overTime;

  const TimeDetailsPopup({
    super.key,
    required this.data,
    required this.title,
    required this.workedHours,
    required this.shortHours,
    required this.overTime,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Container(
      width: 95.w,
      height: 75.h,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),

      ),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10.w), // Spacer to balance the close button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: appTheme.buttonGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: appTheme.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: CloseButtonWidget(),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Worked Hours', workedHours, appTheme),
              _buildStatColumn('Short Hours', shortHours, appTheme),
              _buildStatColumn('Over Time', overTime, appTheme),
            ],
          ),
          SizedBox(height: 2.h),

          // Table Container
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: appTheme.popUp1Border),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(3),
            child: Container(
              width: 95.w,
              height: 55.h,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appTheme.leaveDetailsBG,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Table Header
                  _buildTableHeader(appTheme),
                  Divider(color: appTheme.appColor, thickness: 0.8),

                  // Table Content - Scrollable
                  Expanded(
                    child: Scrollbar(
                      thickness: 3,
                      radius: Radius.circular(10),
                      child: ListView.separated(
                        itemCount: data.length,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Divider(
                          color: appTheme.appColor,
                          thickness: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return _buildTableRow(item, appTheme);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, dynamic appTheme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: appTheme.darkGrey,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: appTheme.appColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(dynamic appTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: TextStyle(
                fontSize: 12.sp,  // +2pt bigger
                fontWeight: FontWeight.bold,
                color: appTheme.black87,
              ),
            ),
          ),
          SizedBox(width: 2.w,),
          Expanded(
            flex: 2,
            child: Text(
              'First In',
              style: TextStyle(
                fontSize: 13.sp,  // +2pt bigger
                fontWeight: FontWeight.bold,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Last out',
              style: TextStyle(
                fontSize: 13.sp,  // +2pt bigger
                fontWeight: FontWeight.bold,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Break Hours',
              style: TextStyle(
                fontSize: 13.sp,  // +2pt bigger
                fontWeight: FontWeight.bold,
                color: appTheme.black87,
              ),
            ),
          ),
          SizedBox(width: 2.w,),
          Expanded(
            flex: 3,
            child: Text(
              'Shift details',
              style: TextStyle(
                fontSize: 13.sp,  // +2pt bigger
                fontWeight: FontWeight.bold,
                color: appTheme.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, String> item, dynamic appTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item['date'] ?? '',
              style: TextStyle(
                fontSize: 12.sp,  // +2pt bigger (was 11sp)
                color: appTheme.black87,
              ),
            ),
          ),
          SizedBox(width: 2.w,),
          Expanded(
            flex: 2,
            child: Text(
              item['firstIn'] ?? '',
              style: TextStyle(
                fontSize: 12.sp,  // +2pt bigger
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item['lastOut'] ?? '',
              style: TextStyle(
                fontSize: 12.sp,  // +2pt bigger
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                color: appTheme.appColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['breakHours'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,  // +2pt bigger (was 10sp)
                  color: appTheme.appColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width:2.w,),
          Expanded(
            flex: 3,
            child: Text(
              item['shiftDetails'] ?? '',
              style: TextStyle(
                fontSize: 11.sp,  // +2pt bigger (was 10sp)
                color: appTheme.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
