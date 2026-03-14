import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../config/appstates.dart';
import '../../features/homepage/views/widgets/category_icon.dart';
import '../../features/support/freshdesk_ticketing.dart';
import '../../routes/app_route.dart';
import '../../theme/theme_controller.dart';
import 'getGreeting.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  final appStateController = Get.put(AppStates());

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Column(
      key: key,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            child: Container(
              width: 70.w,
              height: 65.h,
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient:   LinearGradient(
                  colors: appTheme.bannerGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Drawer(
                backgroundColor: Colors.transparent,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                          radius: 25,
                          child: Obx(
                            () => ClipOval(
                                child: appStateController
                                            .userProfileData.value.img !=
                                        null
                                    ? Image.memory(
                                        base64Decode(appStateController
                                            .userProfileData.value.img!),
                                        width: 25.w,
                                        height: 30.h,
                                        fit: BoxFit.cover,
                                      )
                                    : FaIcon(FontAwesomeIcons.user)),
                          )),
                      title: Text(
                        appStateController.userData.value.user?.name ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        '${appStateController.userProfileData.value.jobTitle ?? ''} |  ${appStateController.userProfileData.value.departmentName ?? ''}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: Colors.white),
                      ),
                    ),
                    Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: appStateController.menuItems.length,
                      itemBuilder: (context, index) {
                        final menuItem = appStateController.menuItems[index];
                        print('meuITem $menuItem');
                        String url = menuItem["menu_image_link"];
                        String title = menuItem["menu_name"];
                        String key = menuItem["menu_key"];
                        return ListTile(
                          leading: SizedBox(
                            height: 3.5.h,
                            width: 8.w,
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.fill,
                            ),
                          ),
                          title: Text(
                            title,
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.white),
                          ),
                          onTap: () {
                            getNavigation(key);
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: SizedBox(
                          height: 3.5.h,
                          width: 8.w,
                          child: Icon(Icons.settings,size: 20.sp,)
                      ),
                      title: Text(
                        "Settings",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                      onTap: () {
                        Get.put(ThemeController());
                        getNavigation("Settings");
                      },
                    ),
                    ListTile(
                      leading: SizedBox(
                          height: 3.5.h,
                          width: 8.w,
                          child:Icon(Icons.logout,size: 20.sp,)
                      ),
                      title: Text(
                        "Logout",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                      onTap: () {
                        Get.put(ThemeController());
                        getNavigation("Logout");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

bool isSubPage(
  String action,
) {
  return action == "Apply Leave" || action == "Add Document"|| action =="Regularize"|| action =="Apply Overtime"|| action =="Delegate"|| action =="Teams Leave History";
}

class CustomHeader extends StatefulWidget {
  final String title;

  const CustomHeader({required this.title, super.key});

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  final appStateController = Get.put(AppStates());
  final Rxn<Uint8List> userImageBytes = Rxn<Uint8List>();

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return  Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSubPage(widget.title))
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.arrow_back_ios),
                  ),
                ),
              if (widget.title != "Your Profile")
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.profilePage);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Obx(() {
                      final imgStr =
                          appStateController.userProfileData.value.img;

                      if (imgStr != null && imgStr.isNotEmpty) {
                        try {
                          userImageBytes.value = base64Decode(imgStr);

                        } catch (_) {
                          // Handle invalid base64
                          return CircleAvatar(
                            radius: 30,
                            child: FaIcon(FontAwesomeIcons.user),
                          );
                        }
                      }

                      return CircleAvatar(
                        radius: 30,
                        child: ClipOval(
                          child: userImageBytes.value != null
                              ? Image.memory(
                                  userImageBytes.value!,
                                  width: 25.w,
                                  height: 30.h,
                                  fit: BoxFit.cover,
                                )
                              : FaIcon(FontAwesomeIcons.user),
                        ),
                      );
                    }),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.title.isEmpty
                      ? getGreeting()
                      : Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: appTheme.darkGrey),
                        ),
                  Text(
                    (appStateController.userData.value.user?.name ?? ''),
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: appTheme.darkGrey),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        FontAwesomeIcons.crown,
                        color: appTheme.green,
                        size: 14.sp,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
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
                          builder: (context) =>  FreshdeskSupportScreen(token:appStateController.userData.value.accessToken??"")),
                    );
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: appTheme.appColor, width: 2),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.headset,
                          color: appTheme.appColor,
                          size: 18.sp,
                        ),
                      )),
                ),
              ),
            ],
          )
        ],
      );
  }
}
