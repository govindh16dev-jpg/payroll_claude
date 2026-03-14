import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payroll/features/manager/model/employee_leaves_list.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/theme_controller.dart';
import '../../leave_page/views/widgets/popup.dart';

Widget buildHeaderRow() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: buildHeaderItem('ID'),
        ),
        SizedBox(width: 1.w),
        Expanded(
          flex: 2,
          child: buildHeaderItem('Name'),
        ),
        SizedBox(width: 1.w),
        Expanded(
          flex: 3,
          child: buildHeaderItem('Leave Type'),
        ),
      ],
    ),
  );
}


Widget buildHeaderItem(String text) {
  var appTheme = Get.find<ThemeController>().currentTheme;

  return Container(
    width: 20.w,
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
        fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black87),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

Widget buildSimpleTextUnderLine(String text, {required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        decoration: TextDecoration.underline,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
Widget buildLeaveTypeWithBadge(String leaveType, String days, String status) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: getStatusColor(status),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 0.5.h),
      buildSimpleText(leaveType),
      buildSimpleText(
        '$days Days',
      )
    ],
  );
}

Widget buildExpandedContent(
    LeavesDetail item, {
      required VoidCallback onApprove,
      required VoidCallback onReject,
    }) {
  var appTheme = Get.find<ThemeController>().currentTheme;

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
      children: [
        // Row 1
        Row(
          children: [
            _buildExpandedItem('EMP ID', item.employeeNo??''),
            SizedBox(width: 8.w),
            _buildExpandedItem('Name', item.employeeName??''),
            SizedBox(width: 8.w),
            _buildExpandedItem('Leave Type', item.planTypeName??""),
          ],
        ),
        SizedBox(height: 2.h),

        // Row 2
        Row(
          children: [
            _buildExpandedItem('From', item.fromDateFormat??""),
            SizedBox(width: 8.w),
            _buildExpandedItem('To', item.toDateFormat??''),
            SizedBox(width: 8.w),
            _buildExpandedItem('Days', item.noOfDays??""),
          ],
        ),
        SizedBox(height: 1.h),

        // Row 3: Reason and Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 20.w,
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
                "Reason",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: appTheme.white,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                item.leaveActionReason??"",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),

            // Approve and Reject Buttons
          if(item.leaveStatus=="Pending")  Row(
              children: [
                Container(
                  width: 10.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.check, color: Colors.white),
                    onPressed: onApprove,
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  width: 10.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: onReject,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildExpandedItem(String title, String value) {
  var appTheme = Get.find<ThemeController>().currentTheme;
  return SizedBox(
    height: 6.h,
    width: 20.w,
    child: Column(
      children: [
        Container(
          width: 20.w,
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
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: appTheme.white,
            ),
          ),
        ),
        SizedBox(
          height: 0.5.h,
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )

      ],
    ),
  );
}


