import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:payroll/features/payslip_page/views/widgets/expansion_tile.dart';
import 'package:payroll/features/payslip_page/views/widgets/net_pay.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:sizer/sizer.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/common/zoom_wrapper.dart';
import '../../../util/custom_widgets.dart';
import '../../login/domain/model/login_model.dart';
import '../../support/freshdesk_ticketing.dart';
import '../controller/payslip_page_controller.dart';
import 'widgets/dropdown.dart';

class PayslipPage extends GetView<PayslipPageController> {
    PayslipPage({super.key});
  var appTheme = Get.find<ThemeController>().currentTheme;
  @override
  Widget build(BuildContext context) {
      appTheme = Get.find<ThemeController>().currentTheme;
    return ZoomWrapper(
      child: FutureBuilder<UserData?>(
          future: controller.getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final userData = snapshot.data;
              final name = userData?.user?.name;
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
                    PageView(
                      controller: controller.pageController,
                      onPageChanged: (index) {
                        if (controller.hasPageInitialized.value) {
                          controller.onSwipeLeft();
                        } else {
                          controller.hasPageInitialized.value = true;
                        }
                      },
                      children: [
                        GestureDetector(
                          key: controller.swipeAreaKey,
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity! > 0) {
                              controller.onSwipeLeft();
                            } else if (details.primaryVelocity! < 0) {
                              controller.onSwipeRight();
                              // _onSwipeLeft();
                            }
                          },
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.toNamed(AppRoutes.profilePage);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: CircleAvatar(
                                                  radius: 30,
                                                  child: Obx(
                                                    () => ClipOval(
                                                        child: controller
                                                                    .appStateController
                                                                    .userProfileData
                                                                    .value
                                                                    .img !=
                                                                null
                                                            ? Image.memory(
                                                                base64Decode(controller
                                                                    .appStateController
                                                                    .userProfileData
                                                                    .value
                                                                    .img!),
                                                                width: 25.w,
                                                                height: 30.h,
                                                                fit: BoxFit.cover,
                                                              )
                                                            : FaIcon(
                                                                FontAwesomeIcons
                                                                    .user)),
                                                  )),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Your Payslip',
                                                style: TextStyle(
                                                    fontSize:
                                                      14.sp ,
                                                    fontWeight: FontWeight.w900,
                                                    color: appTheme.darkGrey),
                                              ),
                                              Text(
                                                '$name'.toUpperCase(),
                                                style: TextStyle(
                                                    fontSize:
                                                        20.sp ,
                                                    fontWeight: FontWeight.w900,
                                                    color: appTheme.darkGrey),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.crown,
                                                    color: appTheme.green,
                                                    size: 14.sp,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Text(
                                                      'Active',
                                                      style: TextStyle(
                                                        color: appTheme.green,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Visibility(
                                            visible:false,
                                            maintainSize: true,
                                            maintainAnimation: true,
                                            maintainState: true,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FreshdeskSupportScreen(token:controller.appStateController.userData.value.accessToken??"")),
                                                );
                                              },
                                              child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 10.0),
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: appTheme.appColor,
                                                          width: 2),
                                                    ),
                                                    child: FaIcon(
                                                      FontAwesomeIcons.headset,
                                                      color: appTheme.appColor,
                                                      size: 18.sp,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              controller.isMasked.value =
                                                  !controller.isMasked.value;
                                            },
                                            icon: Obx(() => Icon(
                                                color: appTheme.appGradient,
                                                controller.isMasked.value
                                                    ? Icons.visibility_off
                                                    : Icons.visibility)),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),

                                  Obx(
                                        () => SizedBox(
                                      height: 18.h,
                                      child: PayslipBannerDivided(
                                        workedDaysValue:
                                        controller.totals.value.daysWorked ??
                                            '',
                                        monthYear:
                                        '${controller.selectedMonth.isNotEmpty?controller.selectedMonth.value.substring(0, 3):""} ${controller.selectedYear.value}',
                                        netPayAmount:
                                        controller.totals.value.netPay ?? '0',
                                        lopJanValue: controller
                                            .userProfilePaySlip.noOfLopDays ??
                                             '1',
                                        plopDecValue: controller
                                            .userProfilePaySlip.lopRecovery ??
                                            '1',
                                        lopReversalValue: controller
                                            .userProfilePaySlip.lopReversal ??
                                            '1',
                                        accountNumberSuffix: controller
                                            .userProfilePaySlip.accountNumber ??
                                            '****7890',
                                        bankName:
                                        controller.userProfilePaySlip.bankName ??
                                            'HDFC Bank',
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 2.h),
                                  // Buttons Grid
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  buildDropdownScrollYears(context, controller);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2.0),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                                    height: 4.h,
                                                    alignment: Alignment.centerLeft,
                                                    child: Obx(() => Row(
                                                      children: [
                                                        Text(
                                                          controller.selectedYear.value,
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight: FontWeight.bold,
                                                            color: appTheme.darkGrey,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        arrowIconDown(),
                                                      ],
                                                    )),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  buildDropdownScrollMonth(context, controller);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2.0),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                                    height: 4.h,
                                                    alignment: Alignment.centerLeft,
                                                    child: Obx(() => Row(
                                                      children: [
                                                        Text(
                                                          controller.selectedMonth.value,
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight: FontWeight.bold,
                                                            color: appTheme.darkGrey,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        arrowIconDown(),
                                                      ],
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: (){
                                              controller.fetchPaySlipPdf();
                                            },
                                              child: FaIcon(FontAwesomeIcons.download,size:18.sp,color: appTheme.appColor,)
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Obx(
                                    () => ExpandableListTile(
                                      title: 'GROSS EARNINGS',
                                      total:
                                          controller.totals.value.totalEarnings ??
                                              '',
                                      items: controller.earningsData.isNotEmpty
                                          ? controller.earningsData
                                          : [],
                                      index: 0,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Obx(() => ExpandableListTile(
                                        title: 'GROSS DEDUCTIONS',
                                        total: controller
                                                .totals.value.totalDeduction ??
                                            '',
                                        items: controller.deductionData.isNotEmpty
                                            ? controller.deductionData
                                            : [],
                                        index: 1,
                                      )),
                                  SizedBox(height: 1.h),
                                  Obx(() => ExpandableListTile(
                                        title: 'CUMULATIVE',
                                        total:
                                            controller.totals.value.netPay ?? '',
                                        items:
                                            controller.cumulativeData.isNotEmpty
                                                ? controller.cumulativeData
                                                : [],
                                        index: 1,
                                      )),
                                  SizedBox(height: 4.h),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   crossAxisAlignment: CrossAxisAlignment.center,
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [
                                  //     // Left Arrow Icon
                                  //     IconButton(
                                  //       icon: Icon(Icons.arrow_back_ios),
                                  //       onPressed: () {
                                  //         controller.onSwipeLeft();
                                  //       },
                                  //     ),
                                  //
                                  //     // Center Text
                                  //     Center(
                                  //         child: Obx(
                                  //               () => Text(
                                  //             '${controller.selectedMonth.value.substring(0, 3)} ${controller.selectedYear.value}',
                                  //             style: TextStyle(
                                  //               fontSize: 18, // Adjust font size
                                  //               fontWeight:
                                  //               FontWeight.bold, // Add bold text
                                  //             ),
                                  //           ),
                                  //         )),
                                  //
                                  //     // Right Arrow Icon
                                  //     IconButton(
                                  //       icon: Icon(Icons.arrow_forward_ios),
                                  //       onPressed: () {
                                  //         controller.onSwipeRight();
                                  //       },
                                  //     ),
                                  //   ],
                                  // ),
                                  SizedBox(height: 15.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Visibility(
                          visible: controller.loading.value == Loading.loading,
                          child: loadingIndicator()),
                    )
                  ],
                ),
                floatingActionButton: CustomBottomNaviBar(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.startFloat,
              );
            }
          },
        )
    );
  }
}
