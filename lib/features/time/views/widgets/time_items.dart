import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';


// Header Row
Widget buildTimeHeaderRow() {
  var appTheme = Get.find<ThemeController>().currentTheme;
  return Container(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: buildTimeHeaderItem('Name'),
        ),
        SizedBox(width: 1.w),
        Expanded(
          flex: 4,
          child: buildTimeHeaderItem('Time Req'),
        ),
        SizedBox(width: 1.w),
        Expanded(
          flex: 2,
          child: buildTimeHeaderItem('Details'),
        ),
      ],
    ),
  );
}

Widget buildTimeHeaderItem(String text) {
  var appTheme = Get.find<ThemeController>().currentTheme;
  return Container(
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
      textAlign: TextAlign.center,
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w900,
        color: appTheme.white,
      ),
    ),
  );
}

Widget buildSimpleText(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

Widget buildTimeRequestBadge(String status, String statusType, String requestStatus, dynamic appTheme) {
  // Color for the main status type badge
  Color badgeColor;
  if (status == 'Regularization') {
    badgeColor = Colors.red;
  } else if (status == 'Over Time') {
    badgeColor = Colors.orange;
  } else {
    badgeColor = Colors.green;
  }

  // Color for request status (Pending/Approved/Rejected)
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return appTheme.calendarApproved ?? Colors.green;
      case 'rejected':
        return appTheme.calendarRejected ?? Colors.red;
      case 'pending':
        return appTheme.calendarPending ?? Colors.orange;
      default:
        return Colors.grey;
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Request Status Badge (Pending/Approved/Rejected)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: getStatusColor(requestStatus),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          requestStatus,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 0.3.h),
      // Status Type text
      Text(
        status,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      Text(
        statusType,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    ],
  );
}


// Expanded Content
Widget buildExpandedTimeContent(
    Map<String, String> item,
    dynamic appTheme, {
      required VoidCallback onApprove,
      required VoidCallback onReject,
      VoidCallback? onViewRoute,
    }) {
  return Container(
    padding: EdgeInsets.all(2.h),
    decoration: BoxDecoration(
      color:  appTheme.appColor.withValues(alpha:0.05),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Shift Details
        Row(
          children: [
            buildExpandedItemSmall('Shift start', item['shiftStart'] ?? '', appTheme),
            SizedBox(width: 2.w),
            buildExpandedItemSmall('A.start', item['actualStart'] ?? '', appTheme),
            SizedBox(width: 2.w),
            buildExpandedItemSmall('M.Entry', item['checkInFirstIn'] ?? '', appTheme),
          ],
        ),
        SizedBox(height: 1.h),

        // Row 2: End and Exit times
        Row(
          children: [
            buildExpandedItemSmall('Shift End', item['shiftEnd'] ?? '', appTheme),
            SizedBox(width: 2.w),
            buildExpandedItemSmall('A.End', item['actualEnd'] ?? '', appTheme),
            SizedBox(width: 2.w),
            buildExpandedItemSmall('M.Exit', item['checkInLastOut'] ?? '', appTheme),
          ],
        ),
        SizedBox(height: 1.h),

        // Row 3: Break times with Pending badge
        Row(
          children: [
            buildExpandedItemSmall('Break', item['break'] ?? '', appTheme),
            SizedBox(width: 2.w),
            buildExpandedItemSmall('A.Break', item['checkInBreakHours'] ?? '', appTheme),
            SizedBox(width: 2.w),
            buildExpandedItemSmall('M.Break', item['checkInOverTime'] ?? '', appTheme),
            // L.Exit with Pending/Overtime badge
            // Expanded(
            //   child: Column(
            //     children: [
            //       Container(
            //         width: double.infinity,
            //         padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
            //         decoration: BoxDecoration(
            //           gradient: LinearGradient(
            //             colors: appTheme.buttonGradient,
            //             begin: Alignment.centerLeft,
            //             end: Alignment.centerRight,
            //           ),
            //           borderRadius: BorderRadius.circular(50),
            //         ),
            //         child: Text(
            //           textAlign: TextAlign.center,
            //           'E.Break',
            //           style: TextStyle(
            //             fontSize: 12.sp,
            //             fontWeight: FontWeight.w900,
            //             color: appTheme.white,
            //           ),
            //         ),
            //       ),
            //       SizedBox(height: 0.5.h),
            //
            //       Text(
            //         item['checkInOverTime'] ?? '',
            //         style: TextStyle(
            //           fontSize: 11.sp,
            //           fontWeight: FontWeight.w600,
            //           color: Colors.black87,
            //         ),
            //       ),
            //       Text(
            //         item['status'] == 'Over Time' ? 'Overtime' : '',
            //         style: TextStyle(
            //           fontSize: 10.sp,
            //           fontWeight: FontWeight.w500,
            //           color: Colors.black54,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
        SizedBox(height: 2.h),

        // Reason Section with Attachment
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                'Reason',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: appTheme.white,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['reason'] ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  // Attachment link
                  Row(
                    children: [
                      Icon(
                        Icons.attach_email,
                        color: appTheme.appColor,
                        size: 16.sp,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Attachment',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: appTheme.appColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      if (onViewRoute != null) ...[
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: onViewRoute,
                          child: Row(
                            children: [
                              Icon(
                                Icons.route,
                                color: appTheme.appColor,
                                size: 16.sp,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'View Route',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: appTheme.appColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),

        // Approve and Reject Buttons
        if (item['requestStatus'] == 'Pending')
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 10.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.check, color: Colors.white, size: 20.sp),
                  onPressed: onApprove,
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                width: 10.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
                  onPressed: onReject,
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

void showReasonDialog(String reason) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: Get.find<ThemeController>().currentTheme.buttonGradient,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Reason',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 24.sp),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              reason,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    ),
  );
}

Widget buildExpandedItemSmall(String title, String value, dynamic appTheme) {
  return Expanded(
    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color:appTheme.appColor,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// Arrow Icons
Widget arrowIconDown() {
  var appTheme = Get.find<ThemeController>().currentTheme;
  return Container(
    padding: EdgeInsets.all(0.5.h),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: appTheme.buttonGradient,
      ),
    ),
    child: Icon(
      Icons.keyboard_arrow_down,
      color: Colors.white,
      size: 18.sp,
    ),
  );
}

Widget arrowIconUp() {
  var appTheme = Get.find<ThemeController>().currentTheme;
  return Container(
    padding: EdgeInsets.all(0.5.h),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: appTheme.buttonGradient,
      ),
    ),
    child: Icon(
      Icons.keyboard_arrow_up,
      color: Colors.white,
      size: 18.sp,
    ),
  );
}

/// Show route list popup with geo details
void showRouteListPopup(List<Map<String, dynamic>> geoDetails, String empName) {
  var appTheme = Get.find<ThemeController>().currentTheme;
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(0),
      child: Container(
        width: 95.w,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: appTheme.popUpBG,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
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
                      textAlign: TextAlign.center,
                      'Route Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: appTheme.white,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: CloseButtonWidget(),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: appTheme.popUp1Border),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(3),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appTheme.leaveDetailsBG,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Action',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Latitude',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Longitude',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Table Rows
                    if (geoDetails.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        child: Text(
                          'No route data available',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      ...geoDetails.asMap().entries.map((entry) {
                        final detail = entry.value;
                        final actionType = _formatActionType(detail['action_type']?.toString() ?? '');
                        final actionTime = detail['action_time']?.toString() ?? '--';
                        final latitude = detail['latitude']?.toString() ?? '--';
                        final longitude = detail['longitude']?.toString() ?? '--';

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: appTheme.appColor.withOpacity(0.2),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  actionType,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: appTheme.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  actionTime,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: appTheme.appColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  latitude == 'null' ? '--' : latitude,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: appTheme.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  longitude == 'null' ? '--' : longitude,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: appTheme.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Format action type (e.g. "clock_in" -> "Clock In")
String _formatActionType(String actionType) {
  return actionType
      .split('_')
      .map((word) => word.isNotEmpty
      ? '${word[0].toUpperCase()}${word.substring(1)}'
      : word)
      .join(' ');
}

