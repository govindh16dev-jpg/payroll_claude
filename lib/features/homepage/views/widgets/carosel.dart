import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get/get.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/appstates.dart';
import '../../../../theme/theme_controller.dart';
import '../../controller/home_page_controller.dart';
import 'notification_carosel.dart';


class BannerCarousel extends GetView<HomePageController> {
  final RxInt _current = 0.obs;
  BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var appTheme = Get.find<ThemeController>().currentTheme;
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 20.h,
                viewportFraction:
                    0.9, // Removes the space for next/previous items
                enableInfiniteScroll:
                    true, // Optional: Set to false if you want to stop infinite scroll
                showIndicator: false,
                onPageChanged: (index, reason) {
                  _current.value = index;
                },
                slideIndicator: CircularSlideIndicator(),
              ),
              items: controller.bannerItems.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    int index = controller.bannerItems.indexOf(item);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Opacity(
                          opacity: _current.value == index ? 1 : 0.4,
                          child: GestureDetector(onTap: () {}, child: item)),
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
        );
    });
  }
}

class NetPayCard extends GetView<HomePageController> {
  final String monthYear;
  final String amount;
  final double percentageChange;
  final String bankAccountNumber;
  final String bankName;
  final String daysWorked;
  NetPayCard({
    super.key,
    required this.monthYear,
    required this.amount,
    required this.percentageChange,
    required this.bankAccountNumber,
    required this.bankName,
    required this.daysWorked,
  });
  final appStateController = Get.put(AppStates());
  @override
  Widget build(BuildContext context) {

    return Obx((){
      var appTheme = Get.find<ThemeController>().currentTheme;
    return  GestureDetector(
        onTap: (){
          List<String> parts = monthYear.split(' ');
          String month = parts[0];
          String year = parts[1];
          Get.toNamed(AppRoutes.paySlipPage,arguments: {
            "year":year,
            "month":month,
          });
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: appTheme.bannerGradient,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthYear,
                    style: TextStyle(
                      color: appTheme.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                  ),
                  Obx(
                        () => Text(
                      textAlign: TextAlign.start,
                      controller.isMasked.value ? '*****' : daysWorked,
                      style: TextStyle(
                        color: appTheme.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                        () => RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: appTheme.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                              "${appStateController.currency.value} " ?? '₹ '),
                          TextSpan(
                              text: controller.isMasked.value ? '*****' : amount),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'Days Worked',
                    style: TextStyle(
                      color: appTheme.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.8.h),
              Text(
                'Net Pay',
                style: TextStyle(
                  color: appTheme.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(), // Pushes the bank info to the right
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                            () => Text(
                          controller.isMasked.value ? '*****' : bankAccountNumber,
                          style: TextStyle(
                            color: appTheme.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        bankName,
                        style: TextStyle(
                          color: appTheme.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class PayslipBannerDivided extends GetView<HomePageController> {
  // Input parameters for the widget
  final String monthYear;
  final String netPayAmount;
  final String netPayLabel;
  final String accountNumberSuffix;
  final String bankName;
  final String workedDaysValue;
  final String workedDaysLabel;
  final String lopJanValue;
  final String lopJanLabel;
  final String plopDecValue;
  final String plopDecLabel;
  final String lopReversalValue;
  final String lopReversalLabel;

  // Define gradient colors (can also be passed as parameters if needed)

  final appStateController = Get.put(AppStates());

  // Constructor with required and optional (with default values) parameters
  PayslipBannerDivided({
    super.key,
    required this.monthYear,
    required this.netPayAmount,
    this.netPayLabel = 'Net Pay',
    required this.accountNumberSuffix,
    required this.bankName,
    required this.workedDaysValue,
    this.workedDaysLabel = 'Month days: ',
    required this.lopJanValue,
    this.lopJanLabel = 'LOP Month: ',
    required this.plopDecValue,
    this.plopDecLabel = 'PLOP: ',
    required this.lopReversalValue,
    this.lopReversalLabel = 'LOP Reversal: ',
  });

  // Helper method to build the main content of the payslip card
  Widget _buildMainCardContent(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 85.w,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: appTheme.bannerGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0.5.w, // Responsive spread
            blurRadius: 2.w, // Responsive blur
            offset: Offset(0, 0.5.h), // Responsive offset
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side content
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthYear,
                  style: TextStyle(
                    color: appTheme.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(
                          () => RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: appTheme.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: "${appStateController.currency.value} " ??
                                    '₹ '),
                            TextSpan(
                                text: controller.isMasked.value
                                    ? '*****'
                                    : netPayAmount),
                          ],
                        ),
                      ),
                    ),
                    Obx(()=> Align(
                      alignment: controller.isMasked.value
                          ?Alignment.centerLeft: Alignment.centerLeft,
                      child: Text(
                        netPayLabel,
                        style: TextStyle(
                          color: appTheme.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ))
                  ],
                ),
                SizedBox(height: 1.5.h),
                Obx(
                      () => Text(
                    controller.isMasked.value ? '*****' : accountNumberSuffix,
                    style: TextStyle(
                      color: appTheme.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  bankName,
                  maxLines: 1,
                  style: TextStyle(
                    color: appTheme.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildInfoItem(workedDaysValue, workedDaysLabel),
                _buildInfoItem(lopJanValue, lopJanLabel),
                _buildInfoItem(
                  plopDecValue,
                  plopDecLabel,
                ),
                _buildInfoItem(lopReversalValue, lopReversalLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Helper widget for individual info items on the right
  Widget _buildInfoItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Obx(
                () => Text(
              textAlign: TextAlign.start,
              controller.isMasked.value ? '*****' : value ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainCardWithContent = _buildMainCardContent(context);
    return  mainCardWithContent;
  }
}


class TaxCard extends GetView<HomePageController> {
  final String taxLiability;
  final String taxPaid;
  final String balanceTax;
  final String remainingMonths;
  final String monthlyTax;

  TaxCard(
      {super.key,
      required this.taxLiability,
      required this.taxPaid,
      required this.balanceTax,
      required this.remainingMonths,
      required this.monthlyTax});
  final appStateController = Get.put(AppStates());
  final double taxFiguresFontSize=19.sp;
  @override
  Widget build(BuildContext context) {

    return Obx((){
      var appTheme = Get.find<ThemeController>().currentTheme;
      return GestureDetector(
        onTap: (){
          Get.toNamed(AppRoutes.taxPage);
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: appTheme.bannerGradient,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [


              Obx(
                    () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: appTheme.white,
                          fontSize:taxFiguresFontSize,
                          fontWeight: FontWeight.w900,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: "${appStateController.currency.value} " ??
                                  '₹ '),
                          TextSpan(
                              text: controller.isMasked.value
                                  ? '*****'
                                  : taxLiability),
                        ],
                      ),
                    ),
                    Text(
                      'Total Tax Liability',
                      style: TextStyle(
                        color: appTheme.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 2.8.h,
                    ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: appTheme.white,
                          fontSize:taxFiguresFontSize,
                          fontWeight: FontWeight.w900,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "${appStateController.currency.value} " ?? '₹ ',
                          ),
                          TextSpan(
                            text: controller.isMasked.value ? '*****' : balanceTax,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Balance Tax',
                      style: TextStyle(
                        color: appTheme.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Obx(
                    () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: appTheme.white,
                          fontSize:taxFiguresFontSize,
                          fontWeight: FontWeight.w900,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: "${appStateController.currency.value} " ??
                                  '₹ '),
                          TextSpan(
                              text: controller.isMasked.value
                                  ? '*****'
                                  : taxPaid),
                        ],
                      ),
                    ),
                    Text(
                      'Tax Paid till now',
                      style: TextStyle(
                        color: appTheme.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 2.8.h,
                    ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: appTheme.white,
                          fontSize: taxFiguresFontSize,
                          fontWeight: FontWeight.w900,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: "${appStateController.currency.value} " ??
                                  '₹ '),
                          TextSpan(
                              text: controller.isMasked.value
                                  ? '*****'
                                  : monthlyTax),
                        ],
                      ),
                    ),
                    Text(
                      'Monthly Tax Paid',
                      style: TextStyle(
                        color: appTheme.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class LeaveCardOverAll extends GetView<HomePageController> {
  final String title;
  final String sickLeave;
  final String earnedLeave;
  final String compOff;
  final String upcomingHoliday;

  const LeaveCardOverAll({
    super.key,
    required this.title,
    required this.sickLeave,
    required this.earnedLeave,
    required this.compOff,
    required this.upcomingHoliday,
  });

  @override
  Widget build(BuildContext context) {
    return Obx((){
      var appTheme = Get.find<ThemeController>().currentTheme;
      return GestureDetector(
        onTap: (){
          Get.toNamed(AppRoutes.leavePage);
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: appTheme.bannerGradient,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp),
                ),
              ),
              SizedBox(height: 1.8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: sickLeave,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Sick Leave',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: earnedLeave,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Earned Leave',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: compOff,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Comp Off',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              RichText(
                text: TextSpan(
                  text: upcomingHoliday,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
