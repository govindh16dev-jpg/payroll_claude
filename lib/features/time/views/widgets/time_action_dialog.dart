import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';

/// Internal StatefulWidget — controller lifecycle is fully managed by Flutter
class TimeActionDialog extends StatefulWidget {
  final String empName;
  final bool isApprove;

  const TimeActionDialog({
    required this.empName,
    required this.isApprove,
  });

  @override
  State<TimeActionDialog> createState() => TimeActionDialogState();
}

class TimeActionDialogState extends State<TimeActionDialog> {
  // Controller created in State — disposed by Flutter automatically via dispose()
  late final TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _remarksController.dispose(); // Safe: called when widget leaves the tree
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<ThemeController>().currentTheme;
    final Color actionColor = widget.isApprove ? Colors.green : Colors.red;
    final String actionLabel = widget.isApprove ? 'Approve' : 'Reject';
    final IconData actionIcon =
    widget.isApprove ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(    // ← Fixes the overflow error too
        child: Column(
          mainAxisSize: MainAxisSize.min,  // ← Prevents infinite height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: appTheme.buttonGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(actionIcon, color: Colors.white, size: 16.sp),
                      SizedBox(width: 1.w),
                      Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(result: null), // Cancel — no dispose() here
                  child: Icon(Icons.close, size: 24.sp, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Employee name
            Text(
              widget.empName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Are you sure you want to ${actionLabel.toLowerCase()} this request?',
              style: TextStyle(fontSize: 13.sp, color: Colors.black54),
            ),
            SizedBox(height: 2.h),

            // Remarks TextField
            Text(
              'Manager Remarks (optional)',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: appTheme.darkGrey,
              ),
            ),
            SizedBox(height: 0.5.h),
            TextField(
              controller: _remarksController,  // ← Tied to State, never manually disposed
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter remarks...',
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: appTheme.appColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  BorderSide(color: appTheme.appColor, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Confirm + Cancel buttons
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: null),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                // Confirm
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: actionColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Return result BEFORE widget leaves tree — safe
                        Get.back(result: {
                          'confirmed': true,
                          'remarks': _remarksController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      ),
                      child: Text(
                        'Confirm $actionLabel',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}