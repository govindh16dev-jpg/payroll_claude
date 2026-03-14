import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get/get.dart';
import 'package:payroll/features/leave_page/views/widgets/popup.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../../../util/common/status_legends.dart';
import '../../../homepage/views/widgets/notification_carosel.dart';
import '../../controller/leave_page_controller.dart';

class LeaveCard extends GetView<LeavePageController> {
  final String title;
  final String eligible;
  final String applied;
  final String balance;
  final String upcomingHoliday;


  const LeaveCard({
    super.key,
    required this.title,
    required this.eligible,
    required this.applied,
    required this.balance,
    required this.upcomingHoliday,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient:   LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: appTheme.bannerGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:   TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16.sp),
          ),
           SizedBox(height: 1.8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    eligible,
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Eligible',
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                   applied,
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Applied',
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                   balance,
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
            SizedBox(height: 2.h),
          Text(
            upcomingHoliday,
            style:  TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16.sp,),
          ),
        ],
      ),
    );
  }
}

class BannerCarousel extends GetView<LeavePageController> {
  final RxInt _current = 0.obs;

    BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return  Obx(()=>Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlutterCarousel(
          options: FlutterCarouselOptions(
            height: 20.h,
            viewportFraction: 0.9, // Removes the space for next/previous items
            enableInfiniteScroll: true, // Optional: Set to false if you want to stop infinite scroll
            showIndicator: false,
            onPageChanged: (index, reason) {
              _current.value = index;
            },
            slideIndicator: CircularSlideIndicator(),
          ),
          items: controller.bannerItems.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(onTap: () {}, child: item),
                );
              },
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CustomCarouselIndicator(
            itemCount: controller.bannerItems.length,
            currentIndex: _current.value,
            activeColor: appTheme.appColor,
            inactiveColor: appTheme.appColor,
          ),
        ),
      ],
    ));
  }
}

Widget buildStatusCircle(String count, String label,BuildContext context,final List<Map<String, String?>>?  leaveHistory ) {
  var appTheme = Get.find<ThemeController>().currentTheme;
  return GestureDetector(
    onTap: (){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              // Transparent background
              elevation: 0,
              insetPadding: EdgeInsets.all(0),
              child: LeaveHistoryPopup(
                label: label,
                  leaveHistory:
                   leaveHistory!));
        },
      );
    },
    child: Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: appTheme.buttonGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              count,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(label),
      ],
    ),
  );
}


