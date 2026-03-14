import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:payroll/features/manager/controller/manager_page_controller.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:payroll/theme/theme_controller.dart';
import 'package:sizer/sizer.dart';

import '../config/appstates.dart';
import '../config/constants.dart';
import '../features/login/controller/login_page_controller.dart';
import '../features/login/domain/model/login_model.dart';
import '../features/manager/views/apply_delegate_page.dart';
import '../service/app_expection.dart';
import '../util/common/bottom_nav.dart';
import '../util/common/drawer.dart';
import '../util/custom_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LoginPageController loginController = Get.put(LoginPageController());
  final appStateController = Get.put(AppStates());
  String? expandedTile;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> themeColors = [
      const [Color(0xFF5170ff), Color(0xFFff66c4)],
      const [Color(0xFF0097b2), Color(0xFF7ed957)],
      const [Color(0xFFffde59), Color(0xFFff914d)],
      const [
        Color(0xFFff4858),
        Color(0xFFff4858),
      ],
      const [Color(0xFF5ce1e6), Color(0x805ce1e6)],
      // const [  Color(0xFFFF9A6B), Color(0xFFFF9A6B),],
    ];
    RxInt selectedColor = themeController.selectedTheme.value.obs;
    return Obx(() {
      return Scaffold(
        key: _scaffoldKey,
        drawer: CustomDrawer(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(5.h),
          child: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: FaIcon(
                  FontAwesomeIcons.ellipsis,
                  size: 22.sp,
                  color: themeController.currentTheme.appThemeLight,
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
        body: Padding(
          padding: EdgeInsets.all(4.w),
          child: ListView(
            children: [
              CustomHeader(title: 'Settings'),
              SizedBox(height: 6.h),
              _buildExpandableTile(
                id: '1',
                title: 'APP THEME',
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8, left: 4, right: 4),
                    child: Center(
                      child: Wrap(
                        spacing: 4.w,
                        runSpacing: 2.h,
                        children: List.generate(themeColors.length, (index) {
                          final isSelected = selectedColor.value == index;
                          List<Color> color = themeColors[index];
                          return GestureDetector(
                            onTap: () => selectedColor.value = index,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isSelected ? 16.w : 12.w,
                              height: isSelected ? 16.w : 12.w,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: color,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.first.withOpacity(0.5),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : [],
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.white, width: 1.w)
                                    : null,
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 6.w,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 22.w, // smaller width
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: themeController.currentTheme.buttonGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            themeController.changeTheme(selectedColor.value);
                            Get.offAllNamed(AppRoutes.homePage);
                          },
                          child: Text(
                            'SAVE',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: themeController.currentTheme.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _buildExpandableTile(
                id: '2',
                title: 'ACCOUNT SETTINGS',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          showDeleteConfirmationDialog();
                        },
                        child: Text(
                          "DELETE MY ACCOUNT",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: themeController.currentTheme.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              //todo handle to show to only when manager is enabled
              if (appStateController.isTestUser.value)
                _buildExpandableTile(
                  id: '3',
                  title: 'ACCESS SETTINGS',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () async {
                            final controller = Get.put(ManagerPageController());
                            await controller.waitUntilReady();
                            controller.getCurrentDelegateData();
                            Get.to(() => ApplyDelegatePage());
                          },
                          child: Text(
                            "DELEGATE MY ACCESS",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: themeController.currentTheme.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (appStateController.isTestUser.value) SizedBox(height: 2.h),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text(
                        "Loading version...",
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    );
                  }
                  final info = snapshot.data!;
                  return Center(
                    child: Text(
                      "v${info.version} (${info.buildNumber})",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: CustomBottomNaviBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      );
    });
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        var appTheme = Get.find<ThemeController>().currentTheme;
        return AlertDialog(
          title: Text(
            "Confirm Deletion",
            style: TextStyle(
                fontSize: 16.sp,
                color: appTheme.black87,
                fontWeight: FontWeight.bold),
          ),
          content: Text("Are you sure you want to delete your account?"),
          actions: [
            TextButton(
              child: Text("No",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.black87,
                  )),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.black87,
                  )),
              onPressed: () async {
                final res =
                    await loginController.loginProvider.deActivateUser();
                final loginResponse = deleteUserResFromJson(res.body);
                if (loginResponse.success) {
                  appSnackBar(
                      data: loginResponse.message,
                      color: AppColors.textGreenColor);
                  Get.offAllNamed(AppRoutes.loginPage);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandableTile(
      {required String id,
      required String title,
      required List<Widget> children}) {
    final bool isExpanded = expandedTile == id;
    return Card(
      //    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      color: Colors.white,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expandedTile = isExpanded ? null : id;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeController.currentTheme.bannerGradient,
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: themeController.currentTheme.black,
                    ),
                  ),
                  isExpanded ? arrowIconUp() : arrowIconDown(),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }
}
