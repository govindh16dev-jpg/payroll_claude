import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payroll/features/tax_page/controller/tax_page_controller.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/appstates.dart';
import '../../../../theme/theme_controller.dart';

class TaxCard extends GetView<TaxPageController> {
  final String taxLiability;
  final String taxPaid;
  final String balanceTax;
  final String remainingMonths;
  final String monthlyTax;
  final appStateController = Get.put(AppStates());

    TaxCard({
    super.key,
    required this.taxLiability,
    required this.taxPaid,
    required this.balanceTax,
    required this.remainingMonths,
    required this.monthlyTax
  });
  Widget _buildMainCardContent(BuildContext context) {

    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors:appTheme.bannerGradient, // Gradient colors
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(()=> Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style:  TextStyle(
                    color: appTheme.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                  children: <TextSpan>[
                    TextSpan(text:  "${appStateController.currency.value} "??'₹ '),
                    TextSpan(text: controller.isMasked.value ? '*****' : taxLiability),
                  ],
                ),
              ),
              Text(
                'Total Tax Liability',
                style:  TextStyle(
                  color: appTheme.white,
                  fontSize: 14.sp ,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 2.8.h,
              ),
              RichText(
                text: TextSpan(
                  style:  TextStyle(
                    color: appTheme.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: "${appStateController.currency.value} "??'₹ '),
                    TextSpan(text: controller.isMasked.value ? '*****' : balanceTax),
                  ],
                ),
              ),
              Text(
                'Balance Tax',
                style:  TextStyle(
                  color: appTheme.white,
                  fontSize: 14.sp ,
                  fontWeight: FontWeight.w500,
                ),
              ),

            ],
          ),),
          SizedBox(height: 2.8.h,),
          Obx(()=> Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style:  TextStyle(
                    color: appTheme.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: "${appStateController.currency.value} "??'₹ '),
                    TextSpan(text: controller.isMasked.value ? '*****' : taxPaid),
                  ],
                ),
              ),
              Text(
                'Tax Paid till now',
                style:   TextStyle(
                  color: appTheme.white,
                  fontSize: 14.sp ,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 2.8.h,
              ),
              // Column(
              //   children: [
              //     Text(
              //       controller.isMasked.value?'*****':  remainingMonths,
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 20,
              //         fontWeight: FontWeight.w900,
              //       ),
              //     ),
              //     Text(
              //       'Remaining Months',
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 12,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ],
              // ),
              RichText(
                text: TextSpan(
                  style:  TextStyle(
                    color: appTheme.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: "${appStateController.currency.value} "??'₹ '),
                    TextSpan(text: controller.isMasked.value ? '*****' : monthlyTax),
                  ],
                ),
              ),
              Text(
                'Monthly Tax Paid',
                style:  TextStyle(
                  color: appTheme.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainCardWithContent = _buildMainCardContent(context);
    var appTheme = Get.find<ThemeController>().currentTheme;
    // Responsive indicator dimensions
    final double indicatorWidth = 3.w; // e.g., 3% of screen width
    final double indicatorSpacing = 2.w; // e.g., 0.5% of screen width

    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: indicatorWidth + indicatorSpacing),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          mainCardWithContent,
          Positioned(
            left: -(indicatorWidth + indicatorSpacing),
            top: 0,
            bottom: 0,
            child: _buildSideIndicator(
              isLeft: false,
              color: appTheme.appColor,
              indicatorWidth: indicatorWidth,
            ),
          ),
          Positioned(
            right: -(indicatorWidth + indicatorSpacing),
            top: 0,
            bottom: 0,
            child: _buildSideIndicator(
              isLeft: true,
              color: appTheme.appColor,
              indicatorWidth: indicatorWidth,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the side indicators
  Widget _buildSideIndicator({
    required bool isLeft,
    required Color color,
    required double indicatorWidth,
  }) {
    const Radius cornerRadius = Radius.circular(16); // More curvature

    return Container(
      width: indicatorWidth,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? cornerRadius : Radius.zero,
          right: isLeft ? Radius.zero : cornerRadius,
        ),
      ),
    );
  }

}