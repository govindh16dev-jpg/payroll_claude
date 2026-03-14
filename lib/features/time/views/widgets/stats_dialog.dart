import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';

class StatsDialog extends StatelessWidget {
  final String title;
  final List<Map<String, String>> data;

  const StatsDialog({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Container(
      width: 95.w,
      height: 70.h,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10.w), // Spacer
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

          // Table Container
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: appTheme.popUp1Border),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(3),
            child: Container(
              height: 60.h,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appTheme.leaveDetailsBG,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  // Table Header
                  _buildTableHeader(appTheme),
                  Divider(color: appTheme.appColor, thickness: 0.8),

                  // Table Content - Scrollable
                  Expanded(
                    child: data.isEmpty
                        ? Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: appTheme.black87,
                        ),
                      ),
                    )
                        : Scrollbar(
                      thickness: 3,
                      radius: Radius.circular(10),
                      child: ListView.separated(
                        itemCount: data.length,
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


  Widget _buildTableHeader(dynamic appTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'EMP ID',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'EMP Name',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Shift Starts',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Entry',
              style: TextStyle(
                fontSize: 14.sp,
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
              item['empId'] ?? '',
              style: TextStyle(
                fontSize: 13.sp,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              item['empName'] ?? '',
              style: TextStyle(
                fontSize: 13.sp,
                color: appTheme.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item['shiftStarts'] ?? '',
              style: TextStyle(
                fontSize: 13.sp,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item['entry'] ?? '',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: appTheme.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
