// ignore_for_file: library_private_types_in_public_api, empty_catches

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:payroll/features/manager/views/leaves_item.dart';
import 'package:payroll/features/manager/views/widgets.dart';
import 'package:sizer/sizer.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../controller/manager_page_controller.dart';

class TeamLeaveHistoryPage extends GetView<ManagerPageController> {
  TeamLeaveHistoryPage({super.key});
  var appTheme = Get.find<ThemeController>().currentTheme;
  @override
  Widget build(BuildContext context) {
    appTheme = Get.find<ThemeController>().currentTheme;
    return  Scaffold(
        resizeToAvoidBottomInset: false,
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
              controller: controller.scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomHeader(
                      title: 'Teams Leave History',
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Text(
                        textAlign: TextAlign.start,
                        'Team Leave History',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                        width: double.infinity,
                        height: 70.h,
                        child: leaveActionList())
                  ],
                ),
              ),
            ),
            Obx(
              () => Visibility(
                  visible: controller.loading.value == Loading.loading,
                  child: loadingIndicator()),
            )
          ],
        ),
        floatingActionButton: CustomBottomNaviBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      );

  }

  Widget leaveActionList() {
    return Column(
      children: [
        // Column Headers
        buildHeaderRow(),
        Expanded(
            child: Obx(() {
              final pendingItems = controller.leaveItems
                  .where((item) => item.leaveStatus?.toLowerCase() != 'pending')
                  .toList();
              return ListView.builder(
                itemCount: pendingItems.length,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item =  pendingItems[index];

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 0.5.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: appTheme.popUp2Border),
                      borderRadius:
                      BorderRadius.circular(8), // Outer border radius
                    ),
                    child: Column(
                      children: [
                        // Main Row
                        Container(
                          padding: EdgeInsets.all(0.5.h),
                          child: Row(
                            children: [
                              // EMPLOYEE NO.
                              Expanded(
                                flex:
                                3, // Choose flex according to desired width (ID smallest)
                                child: GestureDetector(
                                    onTap: () {
                                      controller.toggleExpanded(index);
                                    },
                                    child: buildSimpleText(item.employeeNo ?? "")),
                              ),
                              SizedBox(width: 1.w),

                              // NAME (clickable)
                              Expanded(
                                flex: 2, // Name is wider, more space
                                child: buildSimpleTextUnderLine(
                                  item.employeeName ?? "",
                                  onTap: () {
                                    // Filter leave history for the specific employee before showing dialog
                                    controller.filterAndSetLeaveHistory(item.employeeNo ?? "");

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            insetPadding: EdgeInsets.all(0),
                                            child: LeaveHistoryPopup(
                                              leaveHistory: controller.employeeLeaveHistory ?? [],
                                              empName:item.employeeName??"" ,
                                              empNo:item.employeeNo ??'' ,
                                            )
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),

                              SizedBox(width: 1.w),

                              // LEAVE TYPE WITH BADGE
                              Expanded(
                                flex: 3, // Leave type also gets decent space
                                child: GestureDetector(
                                  onTap: () {
                                    controller.toggleExpanded(index);
                                  },
                                  child: buildLeaveTypeWithBadge(
                                    item.planTypeName ?? '',
                                    item.noOfDays ?? '',
                                    item.leaveStatus ?? '',
                                  ),
                                ),
                              ),

                              InkWell(
                                onTap: () {
                                  controller.toggleExpanded(index);
                                },
                                child: Obx(() =>
                                controller.expandedIndex.value == index
                                    ? arrowIconUp()
                                    : arrowIconDown()),
                              ),
                            ],
                          ),
                        ),
                        // Expanded Content
                        Obx(() => controller.expandedIndex.value == index
                            ? AnimatedCrossFade(
                          firstChild: SizedBox.shrink(),
                          secondChild: buildExpandedContent(
                            item,
                            onApprove: () async {
                              final result =
                              await showLeaveConfirmationDialog(
                                  item.employeeName ?? "", true);
                              if (result != null && result['confirmed'] == true) {
                                controller.updateLeaveStatus(item, true, remarks: result['remarks'] ?? '');
                              }
                            },
                            onReject: () async {
                              final result =
                              await showLeaveConfirmationDialog(
                                  item.employeeName ?? "", false);
                              if (result != null && result['confirmed'] == true) {
                                controller.updateLeaveStatus(item, false, remarks: result['remarks'] ?? '');
                              }
                            },
                          ),
                          crossFadeState:
                          controller.expandedIndex.value == index
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: Duration(milliseconds: 300),
                        )
                            : SizedBox.shrink())
                      ],
                    ),
                  );
                },
              );
            })),
      ],
    );
  }
}
