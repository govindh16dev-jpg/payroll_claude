import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:payroll/features/homepage/data/model/notification.dart';
import 'package:sizer/sizer.dart';

import '../../../config/constants.dart';
import '../../../../theme/theme_controller.dart';
import '../../../util/common/bottom_nav.dart';
import '../../../util/common/drawer.dart';
import '../../../util/custom_widgets.dart';
import '../../login/domain/model/login_model.dart';
import '../controller/home_page_controller.dart';
import 'widgets/carosel.dart';
import 'widgets/category_icon.dart';
import 'widgets/notification_carosel.dart';

class HomePage extends GetView<HomePageController>  with WidgetsBindingObserver {
    const HomePage({super.key});

    // @override
    // void didChangeAppLifecycleState(AppLifecycleState state) {
    //   if (state == AppLifecycleState.resumed) {
    //     // User came back to the app
    //     controller.fetchNotificationData();
    //   }
    // }
  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return FutureBuilder<UserData>(
      future: controller.getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final userData = snapshot.data;
        final name = userData?.user?.name ?? 'Guest';

        return Obx(()=>RefreshIndicator(
          onRefresh: ()async {
            await controller.getUserData();
          },
          child: Scaffold(
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
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      CustomHeader(
                        title: '',
                      ),
                      SizedBox(
                        height: 3.h,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () async {
                              controller.isMasked.value =
                              !controller.isMasked.value;
                            },
                            icon:   Icon(
                                color: appTheme.appGradient,
                                controller.isMasked.value
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                          ),
                        ),
                      ),
                      BannerCarousel(),
                      SizedBox(height: 1.h),
                      _buildMenuGrid(),
                      SizedBox(height: 1.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height:3.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:appTheme.buttonGradient,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),

                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Center(
                                  child: Text(
                                    'Notifications',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: appTheme.white,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Nos ',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: appTheme.appColor,
                                      fontWeight: FontWeight.w900),
                                ),
                                Container(
                                  height:3.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors:appTheme.buttonGradient,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Center(
                                        child:Obx(()=> Text(
                                          controller.notificationCount.value,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: appTheme.white,
                                              fontWeight: FontWeight.w900),
                                        ),)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                     Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0),
                              child: _buildDropdownSection(context),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0),
                              child: _buildDropdownRole(context),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      NotificationCarousel(),
                      SizedBox(height: 15.h),
                    ],
                  ),
                ),
                Obx(() => Visibility(
                  visible: controller.loading.value == Loading.loading,
                  child: loadingIndicator(),
                )),
              ],
            ),
            floatingActionButton: CustomBottomNaviBar(),
            floatingActionButtonLocation:
            FloatingActionButtonLocation.startFloat,
          ),
        ));
      },
    );
  }

  Widget _buildMenuGrid() {
    return Obx(() => Container(
      constraints: BoxConstraints(maxHeight: 20.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: controller.menuItems.length,
        itemBuilder: (context, index) {
          final item = controller.menuItems[index];
          return
            item["menu_name"]=="Logout"?null:CustomIconButton(
            icon: item["menu_image_link"],
            label: item["menu_name"],
            menuKey:item["menu_key"],
            size: 6.h,
          );
        },
      ),
    ));
  }

 Future buildDropdownScroll(
      BuildContext context,
      ) {
   var appTheme = Get.find<ThemeController>().currentTheme;
    return showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 30.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appTheme.darkGrey,
        ),
        child: Column(
          children: [
            // Done Button
            Container(
              height: 5.h,
              color: Colors.white,
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 40,
                scrollController: FixedExtentScrollController(       initialItem: controller.sectionItems.indexOf(controller.selectedSection.value),),
                onSelectedItemChanged: (int index) {
                  var selectedSection = controller.sectionItems[index];
                  controller.selectedSection.value = selectedSection.section!;
                  controller.fetchNotificationData();
                },
                children:
                controller.sectionItems.map((Section section) {
                  return Text(section.section ?? '');
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future buildDropdownScrollRole(
      BuildContext context,
      ) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 30.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appTheme.darkGrey,
        ),
        child: Column(
          children: [
            // Done Button
            Container(
              height: 5.h,
              color: Colors.white,
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 40,
                scrollController: FixedExtentScrollController(       initialItem: controller.roleItems.indexOf(controller.selectedRole.value),),
                onSelectedItemChanged: (int index) {
                  var selectedRole = controller.roleItems[index];
                  controller.selectedRoleID.value = selectedRole.roleId!;
                  controller.selectedRole.value = selectedRole;
                  controller.fetchNotificationData();
                },
                children:
                controller.roleItems.map((Role section) {
                  return Text(section.roleName ?? '');
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection(context) {
    return GestureDetector(
      onTap: () {
        buildDropdownScroll(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 25.w,
            child: CustomPaint(
              painter: DottedBorderPainter(),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 3.h,
                  alignment: Alignment.centerLeft,
                  child: Obx(
                        () => Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      controller.selectedSection.value ??
                          'Select Section',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  )),
            ),
          ),
          arrowIconDown()
        ],
      ),
    );
  }

  Widget _buildDropdownRole(context) {
    return GestureDetector(
      onTap: () {
        buildDropdownScrollRole(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 25.w,
            child: CustomPaint(
              painter: DottedBorderPainter(),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 3.h,
                  alignment: Alignment.centerLeft,
                  child: Obx(
                        () => Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      controller.selectedRole.value.roleName ??
                          'Select Role',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  )),
            ),
          ),
          arrowIconDown()
        ],
      ),
    );
  }
}
