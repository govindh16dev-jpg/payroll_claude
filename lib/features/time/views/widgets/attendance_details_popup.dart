import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';

class AttendanceDetailsPopup extends StatelessWidget {
  final String date;
  final String startTime;
  final String endTime;
  final String breakTime;
  final String allottedHours;
  final String allottedStart;
  final String allottedEnd;
  final List<String> allottedBreaks;
  final String actualHours;
  final String actualStart;
  final String actualEnd;
  final List<String> actualBreaks;
  final String employeeId;
  final String reason;
  final String status;

  const AttendanceDetailsPopup({
    super.key,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.breakTime,
    required this.allottedHours,
    required this.allottedStart,
    required this.allottedEnd,
    required this.allottedBreaks,
    required this.actualHours,
    required this.actualStart,
    required this.actualEnd,
    required this.actualBreaks,
    required this.employeeId,
    required this.reason,
    required this.status,
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
                        'Shift Details Start: $startTime End: $endTime Break: $breakTime',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w900,
                          color: appTheme.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Employee Details Row (Date & Employee ID)
                   Align(
                     alignment: Alignment.topCenter,
                     child:  Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(
                           'Employee Id: ',
                           style: TextStyle(fontSize: 13.sp, color: appTheme.black87),
                         ),
                         Text(
                           employeeId,
                           style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: appTheme.black87),
                           overflow: TextOverflow.ellipsis,
                         ),
                         SizedBox(width: 8.w),
                         Text(
                           'Date: ',
                           style: TextStyle(fontSize: 13.sp, color: appTheme.black87),
                         ),
                         Text(
                           date,
                           style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: appTheme.black87),
                           overflow: TextOverflow.ellipsis,
                         ),
                       ],
                     ),
                   ),
                  SizedBox(height: 1.5.h),
                  Divider(color: Colors.grey.withOpacity(0.5)),
                  SizedBox(height: 1.5.h),


                  // Two Column Layout
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Column - Allotted Shift
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
                                  'Allotted Shift',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    color: appTheme.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              _buildDetailRow('Allotted Hours', allottedHours, appTheme),
                              _buildDetailRow('Allotted Start', allottedStart, appTheme),
                              _buildDetailRow('Allotted End', allottedEnd, appTheme),
                              ...allottedBreaks.asMap().entries.map((entry) {
                                return _buildDetailRow('Break ${entry.key + 1}', entry.value, appTheme);
                              }),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          width: 1.w,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: appTheme.buttonGradient,
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2), // Rounded ends
                          ),
                        ),

                        // Right Column - Actual Shift
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
                                  'Actual Shift',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    color: appTheme.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              _buildDetailRow('Actual Hours', actualHours, appTheme),
                              _buildDetailRow('Actual Start', actualStart, appTheme),
                              _buildDetailRow('Actual End', actualEnd, appTheme),
                              ...actualBreaks.asMap().entries.map((entry) {
                                return _buildDetailRow('Break ${entry.key + 1}', entry.value, appTheme);
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                    reason,
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
                          status,
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
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: appTheme.black87,
              ),
            ),
          ),
          SizedBox(width: 1.w),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.5.sp,
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
