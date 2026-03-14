import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:payroll/features/profile_page/views/widgets/profile_carosel.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sizer/sizer.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../../login/domain/model/login_model.dart';
import 'controller/profile_page_controller.dart';

class ProfilePage extends GetView<ProfilePageController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      final isMobile =
          sizingInformation.deviceScreenType == DeviceScreenType.mobile;

      return FutureBuilder<UserData?>(
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          CustomHeader(
                            title: 'Your Profile',
                          ),
                          SizedBox(height: 5.h),
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 16.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: appTheme.buttonGradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 2.h),
                                    Text(
                                      controller.user[0].employeeName,
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold,
                                        color: appTheme.white,
                                      ),
                                    ),
                                    Text(
                                      '${controller.user[0].jobTitle} | ${controller.user[0].departmentName}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: appTheme.white,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesomeIcons.envelope,
                                            color: appTheme.white, size: 18),
                                        SizedBox(width: 1.5.w),
                                        Text(
                                          controller.user[0].email??'',
                                          style:
                                              TextStyle(color: appTheme.white),
                                        ),
                                        SizedBox(width: 1.5.w),
                                        Icon(FontAwesomeIcons.phone,
                                            color: appTheme.white, size: 18),
                                        SizedBox(width: 1.5.w),
                                        Text(
                                          controller.user[0].mobile??'',
                                          style:
                                              TextStyle(color: appTheme.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 14.h,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    GestureDetector(
                                      onTap: () => controller
                                          .showImageSourceBottomSheet(context),
                                      child: CircleAvatar(
                                        radius: 48,
                                        child: Obx(()=>ClipOval(
                                            child:
                                            controller.user[0].img != null
                                                ? Image.memory(
                                              base64Decode(controller
                                                  .user[0].img!),
                                              width: 25.w,
                                              height: 50.h,
                                              fit: BoxFit.cover,
                                            )
                                                : const SizedBox.shrink()),)
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      bottom: 4,
                                      child: GestureDetector(
                                        onTap: () => controller
                                            .showImageSourceBottomSheet(
                                                context),
                                        child: FaIcon(
                                          FontAwesomeIcons.penToSquare,
                                          size: 18.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          ProfileCarousel()
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startFloat,
            );
          }
        },
      );
    });
  }
}
