import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';


class TeamAttendanceDetailsPopup extends StatelessWidget {
  final Map<String, String> item;

  const TeamAttendanceDetailsPopup({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Container(
      width: 95.w,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CloseButtonWidget(),
            ),
          ),
          SizedBox(height: 1.h),

          // Main content container
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: appTheme.popUp1Border),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(3),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appTheme.leaveDetailsBG,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - Shift Details
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: appTheme.buttonGradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'Shift Details Start: ${item['shiftStart']} End: ${item['shiftEnd']} Break: ${item['break']}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: appTheme.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Two Column Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column - Check In
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: appTheme.buttonGradient,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                'Check In',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            _buildDetailRow('Date', item['checkInDate'] ?? '', appTheme),
                            _buildDetailRow('First In', item['checkInFirstIn'] ?? '', appTheme),
                            _buildDetailRow('Last out', item['checkInLastOut'] ?? '', appTheme),
                            _buildDetailRow('Break hours', item['checkInBreakHours'] ?? '', appTheme),
                            _buildDetailRow('Short hours', item['checkInShortHours'] ?? '', appTheme),
                            _buildDetailRow('Over time', item['checkInOverTime'] ?? '', appTheme),
                          ],
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1.w,
                        height: 25.h,
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: appTheme.buttonGradient,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Right Column - Check Out
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: appTheme.buttonGradient,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                'Check Out',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            _buildDetailRow('Date', item['checkOutDate'] ?? '', appTheme),
                            _buildDetailRow('First In', item['checkOutFirstIn'] ?? '', appTheme),
                            _buildDetailRow('Last out', item['checkOutLastOut'] ?? '', appTheme),
                            _buildDetailRow('Break hours', item['checkOutBreakHours'] ?? '', appTheme),
                            _buildDetailRow('Short hours', item['checkOutShortHours'] ?? '', appTheme),
                            _buildDetailRow('Over time', item['checkOutOverTime'] ?? '', appTheme),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Reason Section
                  Text(
                    'Reason',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: appTheme.black87,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    item['reason'] ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: appTheme.black87,
                    ),
                  ),

                  SizedBox(height: 1.5.h),

                  // Status Badge
                  Row(
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.black87,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          item['requestStatus'] ?? 'Pending',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: appTheme.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, dynamic appTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: appTheme.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: appTheme.black87,
            ),
          ),
        ],
      ),
    );
  }
}
