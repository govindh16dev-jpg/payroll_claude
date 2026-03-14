import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:payroll/features/ctc_page/views/widgets/dropdown.dart';
import 'package:payroll/features/ctc_page/views/widgets/expansion_tile.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:payroll/util/common/drawer.dart';
import 'package:payroll/util/common/zoom_wrapper.dart';
import 'package:sizer/sizer.dart';
import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/custom_widgets.dart';
import '../../login/domain/model/login_model.dart';
import '../../support/freshdesk_ticketing.dart';
import '../controller/ctc_page_controller.dart';
import 'widgets/ctc_card.dart';

class CTCPage extends GetView<CTCPageController> {
  const CTCPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
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
                            }
                          },
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              padding:
                                              const EdgeInsets.only(right: 8.0),
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
                                                            : FaIcon(FontAwesomeIcons
                                                            .user)),
                                                  )),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Your CTC',
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
                                                    padding: const EdgeInsets.only(
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Visibility(
                                            visible:false,
                                            maintainSize: true,
                                            maintainAnimation: true,
                                            maintainState: true,
                                            child: GestureDetector(
                                              onTap: () {
                                                // Get.toNamed(AppRoutes.profilePage);
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
                                          Padding(
                                            padding: EdgeInsets.all(10),
                                            child: SizedBox.shrink(),
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
                                  // Replace your current CTC card section with:
                                SizedBox(
                                    height: 16.5.h, // Adjusted height for the banner profile
                                    child: CTCBannerProfile(),
                                  ),

                                  SizedBox(height: 2.h),
                                  // Buttons Grid
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          buildDropdownScrollTax(context, controller);
                                        },
                                        child: Container(
                                            padding:
                                            EdgeInsets.symmetric(horizontal: 10),
                                            height: 4.h,
                                            alignment: Alignment.centerLeft,
                                            child: Obx(
                                                  () => Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    controller.selectedYear.value
                                                        .financialLabel
                                                        ?.substring(2) ??
                                                        'Select Financial',
                                                    style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: appTheme.darkGrey),
                                                  ),
                                                  arrowIconDown()
                                                ],
                                              ),
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                            onTap: (){
                                              controller.fetchCTCPdf();
                                            },
                                            child: FaIcon(FontAwesomeIcons.download,size:18.sp,color: appTheme.appColor,)
                                        ),
                                      )
                                    ],
                                  ),
                                  Obx(() => CTCExpandableListTile(
                                    title: 'GROSS SALARY',
                                    yearlyTotal: controller.ctcTotals['gross_yearly'] ?? '0',
                                    monthlyTotal: controller.ctcTotals['gross_monthly'] ?? '0',
                                    items: controller.earningsComponents.map((component) => {
                                      'component_name': component['compensation'],
                                      'amount': component['amount'],
                                      'monthly_amount': component['monthly_amount'],
                                    }).toList(),
                                    index: 0,
                                    tileType: CTCTileType.earnings,
                                  )),
                                  SizedBox(height: 1.h),

                                  Obx(() => CTCExpandableListTile(
                                    title: 'EMPLOYER CONTRIBUTIONS',
                                    yearlyTotal: controller.ctcTotals['employer_yearly'] ?? '0',
                                    monthlyTotal: controller.ctcTotals['employer_monthly'] ?? '0',
                                    items: controller.employerContributions.map((component) => {
                                      'component_name': component['compensation'],
                                      'amount': component['amount'],
                                      'monthly_amount': component['monthly_amount'],
                                    }).toList(),
                                    index: 1,
                                    tileType: CTCTileType.employerContribution,
                                  )),
                                  SizedBox(height: 1.h),

                                  CTCBreakdownCards(),
                                  SizedBox(height: 7.h),

                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   crossAxisAlignment: CrossAxisAlignment.center,
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [
                                  //     // Left Arrow Icon
                                  //     IconButton(
                                  //       icon: Icon(Icons.arrow_back_ios),
                                  //       onPressed: (){
                                  //         controller.onSwipeLeft();
                                  //       },
                                  //     ),
                                  //
                                  //     // Center Text
                                  //     Center(
                                  //         child: Obx(()=>Text(
                                  //           '${controller.selectedYear.value.financialLabel}',
                                  //           style: TextStyle(
                                  //             fontSize: 18, // Adjust font size
                                  //             fontWeight: FontWeight.bold, // Add bold text
                                  //           ),
                                  //         ),)
                                  //     ),
                                  //
                                  //     // Right Arrow Icon
                                  //     IconButton(
                                  //       icon: Icon(Icons.arrow_forward_ios),
                                  //       onPressed: (){
                                  //         controller.onSwipeRight();
                                  //       },
                                  //     ),
                                  //   ],
                                  // ),
                                  SizedBox(height: 4.h),
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
      }),
    );
  }
}
