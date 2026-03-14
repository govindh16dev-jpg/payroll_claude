import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/constants.dart';
import '../../../../routes/app_route.dart';
import '../../../../service/app_expection.dart';
import '../../../../theme/theme_controller.dart';
import '../../../../service/api_service.dart';
import '../../controller/home_page_controller.dart';
import 'package:http/http.dart' as http;


getNavigation(label, date) {
  List<String> parts = date.split(" ");
  String month = parts[1];
  String year = parts[2];
  switch (label) {
    case 'payslip':
      Get.toNamed(AppRoutes.paySlipPage, arguments: {
        "year": year,
        "month": month,
      });
      break;
    case 'tax_computation':
      Get.toNamed(AppRoutes.taxPage);
      break;
    case 'Absence Employee':
      Get.toNamed(AppRoutes.leavePage);
      break;
    case 'Employee Time':
      break;
  }
}
Future<http.Response> _updateFCMTokenAPI(String clientId,String notificationID) async {
  http.Response response;
  try {
    response = await ApiProvider().updateNotificationStatus(
        ApiConstants.notifyStatus,
        headers: null,
        body: {
          "msg_status":"read",
          "notification_id":notificationID,
          "client_id":3
        }
    );

    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 401) {
      throw CustomException('Session Expired Login/Authenticate Again!');
    } else {
      final responseData = jsonDecode(response.body);
      String cleanedError = responseData['data'][0]['error_msg'].split("]").last.trim();
      throw CustomException(cleanedError);
    }
  } catch (e, s) {
    debugPrint("FCM Token update error: $e $s");
    rethrow;
  }
}
class NotificationCarousel extends GetView<HomePageController> {
  final RxInt _current = 0.obs;


  NotificationCarousel({super.key});
  @override
  Widget build(BuildContext context) {
     return Obx(() {
      var appTheme = Get.find<ThemeController>().currentTheme;
      return Column(
          children: [
            FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 20.h,
                viewportFraction: 0.9,
                showIndicator: false,
                onPageChanged: (index, reason) {
                  _current.value = index;
                },
                slideIndicator: CircularSlideIndicator(),
              ),
              items: controller.notificationItems.isEmpty
                  ? [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No notifications found',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ]
                  : controller.notificationItems.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    int index = controller.notificationItems.indexOf(item);
                    return GestureDetector(
                      onTap: () {
                        getNavigation(item.menuKey, item.date);
                      if(item.menuKey!=null){
                        _updateFCMTokenAPI(controller.userData.user!.clientId!,item.notificationId!);
                      }
                      },
                      child: Opacity(
                        opacity: _current.value == index ? 1 : 0.4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: appTheme.buttonGradient),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: appTheme.leaveDetailsBG,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20.0),
                                      child: Center(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: 40.w,
                                          height: 4.h,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: appTheme.buttonGradient,
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                            ),
                                            onPressed: () {
                                              // Add functionality if needed
                                            },
                                            child: Text(
                                              item.menuName ?? '',
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
                                      ),
                                    ),
                                    buildInfoRow(
                                      "Activity",
                                      item.msgStatus ?? '',
                                    ),
                                    buildInfoRow(
                                      "Date",
                                      item.date ?? '',
                                    ),
                                    buildInfoRow(
                                      "Remarks",
                                      item.notificationContent ?? '',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15),
              child: CustomCarouselIndicator(
                itemCount: controller.notificationItems.length,
                currentIndex: _current.value,
                activeColor: appTheme.appColor, inactiveColor: appTheme.appColor,
              ),
            ),
          ],
        );
    });
  }
}

class CustomCarouselIndicator extends StatefulWidget {
  final int itemCount;
  final int currentIndex;
  final double size;
  final double borderWidth;
  final Color activeColor;
  final Color inactiveColor;
  var appTheme = Get.find<ThemeController>().currentTheme;
  CustomCarouselIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.size = 14.0,
    this.borderWidth = 2.0,
    required this.activeColor,
    required this.inactiveColor,
    // this.activeColor = appTheme.appColor,
    // this.inactiveColor = appTheme.appColor,
  });

  @override
  State<CustomCarouselIndicator> createState() =>
      _CustomCarouselIndicatorState();
}

class _CustomCarouselIndicatorState extends State<CustomCarouselIndicator> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant CustomCarouselIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll when the active index moves
    _scrollToActiveIndex();
  }

  void _scrollToActiveIndex() {
    double itemWidth =
        widget.size + widget.borderWidth * 2 + 8; // Indicator width + margin
    double scrollPosition = widget.currentIndex * itemWidth -
        (itemWidth * 2); // Offset for centering

    if (scrollPosition < 0) scrollPosition = 0; // Prevent negative scroll

    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          widget.size + widget.borderWidth * 4, // Ensure space for indicators
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.itemCount, (index) {
            return Container(
              width: widget.size + widget.borderWidth * 2,
              height: widget.size + widget.borderWidth * 2,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ring (Border)
                  Container(
                    width: widget.size + widget.borderWidth,
                    height: widget.size + widget.borderWidth,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: index == widget.currentIndex
                            ? widget.activeColor
                            : widget.inactiveColor
                                .withAlpha((255 * 0.5).round()),
                        width: widget.borderWidth,
                      ),
                    ),
                  ),
                  // Inner Circle (Fill)
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Container(
                      width: widget.size - 6,
                      height: widget.size - 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == widget.currentIndex
                            ? widget.activeColor
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
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
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: appTheme.appColor,
            ),
            overflow: TextOverflow.ellipsis, // Prevents overflow issues
          ),
        ),
        Expanded(
          flex: 2, // Gives more space to value
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: appTheme.darkGrey,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Prevents overflow issues
          ),
        ),
      ],
    ),
  );
}
