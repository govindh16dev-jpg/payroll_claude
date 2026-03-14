import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get/get.dart';
import 'package:payroll/features/profile_page/views/controller/profile_page_controller.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../../homepage/views/widgets/notification_carosel.dart';

class ProfileCarousel extends GetView<ProfilePageController> {
  final RxInt _current = 0.obs;

    ProfileCarousel({super.key});

  @override
  Widget build(BuildContext context) {

    return  Obx(() {
      var appTheme = Get.find<ThemeController>().currentTheme;
      return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlutterCarousel(
          options: FlutterCarouselOptions(
            height: 40.h,
            viewportFraction: 0.9,
            enableInfiniteScroll: true,
            showIndicator: false,
            onPageChanged: (index, reason) {
              _current.value = index;
            },
            slideIndicator: CircularSlideIndicator(),
          ),
          items: controller.bannerData.keys.map((tabName) {
            List<Map<String, dynamic>> sectionList = controller.bannerData[tabName]!; // Get items

                return Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        height: 4.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: appTheme.buttonGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            // Add functionality if needed
                          },
                          child: Text(
                            tabName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: appTheme.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // List of Items
                      SizedBox(
                        height: 40.h,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: sectionList.length,
                          itemBuilder: (context, subIndex) {
                            var item = sectionList[subIndex]; // Convert to Map
                            return profileCarouselItem(item); // Custom widget
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomCarouselIndicator(
                itemCount: controller.bannerData.keys.length,
                currentIndex: _current.value, activeColor: appTheme.appColor, inactiveColor: appTheme.appColor,
              ),
            ),
          ],
        );
    });
  }

  Widget profileCarouselItem(item) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: appTheme.popUp1Border,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(8),
        children: item.entries
            .where((e) => e.key != 'tab_name' || e.key != "img")
            .map<Widget>((entry) => buildInfoRow(
          entry.key.replaceAll('_', ' ').toUpperCase(),
          entry.value?.toString() ?? 'N/A',
        ))
            .toList(), // Ensure it's List<Widget>
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: appTheme.black54,
              ),
              overflow: TextOverflow.ellipsis, // Prevents overflow issues
            ),
          ),
          Expanded(
            flex: 2, // Gives more space to value
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: appTheme.black87,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis, // Prevents overflow issues
            ),
          ),
        ],
      ),
    );
  }
}


