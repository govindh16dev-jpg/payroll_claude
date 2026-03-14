import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:payroll/features/time/views/widgets/time_items.dart'
    hide arrowIconDown, arrowIconUp;
import 'package:sizer/sizer.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../controller/manager_time_controller.dart';

class ManagerTimePage extends GetView<ManagerTimeController> {
  const ManagerTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Scaffold(
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
                icon: FaIcon(FontAwesomeIcons.ellipsis),
                iconSize: 22.sp,
                color: appTheme.appThemeLight,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeader(title: 'Team Time'),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: appTheme.buttonGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Team Dashboard',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: appTheme.white,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Manager',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Obx(() => Switch(
                            value: controller.isManagerView.value,
                            thumbColor: WidgetStateProperty.all(Colors.white),
                            activeThumbColor: appTheme.appColor,
                            onChanged: (value) => controller.toggleView(value),
                          )),
                      SizedBox(width: 2.w),
                      Text(
                        'Employee',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: appTheme.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Select Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Date',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color:appTheme.appColor,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () => controller.selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: appTheme.appColor, width: 1.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Obx(() => Text(
                            controller.formattedDate,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: appTheme.darkGrey,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () => controller.selectDate(context),
                    child: Icon(
                      Icons.calendar_month,
                      color: appTheme.appColor,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Dashboard Stats Grid
              Obx(() => _buildDashboardStats(appTheme)),
              SizedBox(height: 2.h),

              // Need to know specific about tabs
              _buildTabs(appTheme),
              SizedBox(height: 2.h),

              // Action Needed Section
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
                  'Action Needed',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: appTheme.white,
                  ),
                ),
              ),
              SizedBox(height: 1.h),

              // Action Needed List
              SizedBox(
                height: 60.h,
                child: _buildActionNeededList(appTheme),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomBottomNaviBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildDashboardStats(dynamic appTheme) {
    // Helper to safely get data
    String getData(String key) => controller.statsData[key] ?? '0';

    return Container(
      width: double.infinity,
      height: 25.h,
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: appTheme.appColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section 1: Full Hours & On-time ---
          Expanded(
            child: _buildStatGroup(
              appTheme,
              top: MapEntry('Full Hours', getData('Full Hours')),
              bottomLeft: MapEntry('On-time(Entry)', getData('On-time(Entry)')),
              bottomRight: MapEntry('On-time(Exit)', getData('On-time(Exit)')),
            ),
          ),

          // Vertical Dashed Divider
          _buildDashedLine(appTheme),

          // --- Section 2: Extended Breaks & Late ---
          Expanded(
            child: _buildStatGroup(
              appTheme,
              top: MapEntry('Extended Breaks', getData('Extended Breaks')),
              bottomLeft: MapEntry('Late Entry', getData('Late Entry')),
              bottomRight: MapEntry('Late Exit', getData('Late Exit')),
            ),
          ),

          // Vertical Dashed Divider
          _buildDashedLine(appTheme),

          // --- Section 3: Leave & Short/Over ---
          Expanded(
            child: _buildStatGroup(
              appTheme,
              top: MapEntry('Leave', getData('Leave')),
              bottomLeft: MapEntry('Short Hours', getData('Short Hours')),
              bottomRight: MapEntry('Over Time', getData('Over Time')),
            ),
          ),
        ],
      ),
    );
  }

// Helper to build the "Pyramid" shape (1 Top, 2 Bottom)
  Widget _buildStatGroup(
    dynamic appTheme, {
    required MapEntry<String, String> top,
    required MapEntry<String, String> bottomLeft,
    required MapEntry<String, String> bottomRight,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Item
        _buildStatItem(top, appTheme),

        SizedBox(height: 1.5.h), // Spacing between top and bottom row

        // Bottom Row of 2 items
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: _buildStatItem(bottomLeft, appTheme, isSmall: true)),
            Expanded(
                child: _buildStatItem(bottomRight, appTheme, isSmall: true)),
          ],
        ),
      ],
    );
  }

// Helper for the vertical dashed separator
  Widget _buildDashedLine(dynamic appTheme) {
    return Container(
      width: 2,
      height: 20.h, // Fixed height for the dashed line
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(15, (index) {
          return Container(
            width: 2,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appTheme.buttonGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatItem(MapEntry<String, String> entry, dynamic appTheme,
      {bool isSmall = false}) {
    // Scaling factor for bottom items to make them fit better side-by-side
    final double circleSize = isSmall ? 12.w : 15.w;
    final double circleHeight = isSmall ? 7.h : 8.h;
    final double fontSize = isSmall ? 16.sp : 20.sp;
    final double labelSize = isSmall ? 11.sp : 12.5.sp;

    return GestureDetector(
      onTap: () {
        controller.showStatsDialog(entry.key);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circleSize,
            height: circleHeight,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: appTheme.buttonGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: appTheme.buttonGradient[0].withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: appTheme.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.5.w),
            child: Text(
              entry.key,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w600,
                color: appTheme.black87,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(dynamic appTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Need to know specific about',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: appTheme.black87,
          ),
        ),
        SizedBox(width: 3.w),
        _buildTabButton('Employees', appTheme, () {
          // Navigate to individual employee selection page
          controller.navigateToEmployeeSelectionPage();
        }),
        SizedBox(width: 2.w),
        _buildTabButton('Shift', appTheme, () {
          // Navigate to shift details page
          controller.navigateToShiftDetailsPage();
        }),
      ],
    );
  }

  Widget _buildTabButton(String title, dynamic appTheme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.8.h),
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
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
            color: appTheme.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionNeededList(dynamic appTheme) {
    return Column(
      children: [
        buildTimeHeaderRow(),
        SizedBox(height: 1.h),
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemCount: controller.teamAttendanceList.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = controller.teamAttendanceList[index];
                return GestureDetector(
                  onTap: () => controller.toggleExpanded(index),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 0.5.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: appTheme.popUp2Border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Main Row
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          decoration: BoxDecoration(
                            color: appTheme.appColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // Name
                              Expanded(
                                flex: 4,
                                child: buildSimpleText(item['empName'] ?? ''),
                              ),
                              SizedBox(width: 1.w),
                              // Time Request Badge
                              Expanded(
                                flex: 4,
                                child: buildTimeRequestBadge(
                                  item['status'] ?? '',
                                  item['statusType'] ?? '',
                                  item['requestStatus'] ?? 'Pending', // Add this parameter
                                  appTheme,
                                ),
                              ),
                              SizedBox(width: 1.w),

                              // Details button
                              // GestureDetector(
                              //   onTap: () => controller.showAttendanceDetails(item),
                              //   child: Icon(
                              //     Icons.chat_bubble,
                              //     color: appTheme.appColor,
                              //     size: 20.sp,
                              //   ),
                              // ),
                              // Expand button
                              InkWell(
                                onTap: () => controller.toggleExpanded(index),
                                child: Obx(() =>
                                    controller.expandedIndex.value == index
                                        ? arrowIconUp()
                                        : arrowIconDown()),
                              ),
                            ],
                          ),
                        ),
                        // Expanded Content
                        Obx(
                          () => controller.expandedIndex.value == index
                              ? AnimatedCrossFade(
                                  firstChild: SizedBox.shrink(),
                                  secondChild: buildExpandedTimeContent(
                                    item,
                                    appTheme,
                                    onApprove: () => controller.approveRequest(item),
                                    onReject: () => controller.rejectRequest(item),
                                    onViewRoute: () => controller.fetchRouteList(item),
                                  ),
                                  crossFadeState:
                                      controller.expandedIndex.value == index
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                  duration: Duration(milliseconds: 300),
                                )
                              : SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
