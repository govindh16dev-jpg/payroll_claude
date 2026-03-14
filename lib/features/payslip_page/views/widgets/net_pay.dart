import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payroll/features/payslip_page/controller/payslip_page_controller.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/appstates.dart';
import '../../../../theme/theme_controller.dart';

class NetPayCard extends GetView<PayslipPageController> {
  final String monthYear;
  final String amount;
  final double percentageChange;
  final String bankAccountNumber;
  final String bankName;
  final String daysWorked;
  final appStateController = Get.put(AppStates());

  NetPayCard(
      {super.key,
      required this.monthYear,
      required this.amount,
      required this.daysWorked,
      required this.percentageChange,
      required this.bankAccountNumber,
      required this.bankName});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: appTheme.bannerGradient, // Gradient colors
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
                  controller.isMasked.value ? '*****' : daysWorked ?? '',
                  style: TextStyle(
                    color: appTheme.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.7.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: appTheme.white,
                      fontSize: 22.sp,
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
          SizedBox(height: 0.7.h),
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
    );
  }
}

// class PayslipBanner extends GetView<PayslipPageController> {
//   // Input parameters for the widget
//   final String monthYear;
//   final String netPayAmount;
//   final String netPayLabel;
//   final String accountNumberSuffix;
//   final String bankName;
//   final String workedDaysValue;
//   final String workedDaysLabel;
//   final String lopJanValue;
//   final String lopJanLabel;
//   final String plopDecValue;
//   final String plopDecLabel;
//   final String lopReversalValue;
//   final String lopReversalLabel;
//
//   // Define gradient colors (can also be passed as parameters if needed)
//
//   final appStateController = Get.put(AppStates());
//
//   // Constructor with required and optional (with default values) parameters
//   PayslipBanner({
//     super.key,
//     required this.monthYear,
//     required this.netPayAmount,
//     this.netPayLabel = 'Net Pay',
//     required this.accountNumberSuffix,
//     required this.bankName,
//     required this.workedDaysValue,
//     this.workedDaysLabel = 'Worked days :',
//     required this.lopJanValue,
//     this.lopJanLabel = 'LOP :',
//     required this.plopDecValue,
//     this.plopDecLabel = 'PLOP :',
//     required this.lopReversalValue,
//     this.lopReversalLabel = 'LOP Reversal :',
//   });
//
//   // Helper method to build the main content of the payslip card
//   Widget _buildMainCardContent(BuildContext context) {
//     // Using sizer for responsive dimensions
//     final double cardBorderRadius = 6.w; // e.g., 6% of screen width
//     final double cardPadding = 5.w; // e.g., 5% of screen width
//     var appTheme = Get.find<ThemeController>().currentTheme;
//     return Container(
//       width: 85.w, // 85% of screen width
//       padding: EdgeInsets.all(cardPadding),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: appTheme.bannerGradient,
//         ),
//         borderRadius: BorderRadius.circular(cardBorderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             spreadRadius: 0.5.w, // Responsive spread
//             blurRadius: 2.w, // Responsive blur
//             offset: Offset(0, 0.5.h), // Responsive offset
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left side content
//           Expanded(
//             flex: 2,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   monthYear,
//                   style: TextStyle(
//                     color: appTheme.white,
//                     fontWeight: FontWeight.w900,
//                     fontSize: 16.sp,
//                   ),
//                 ),
//                 SizedBox(height: 1.h), // Responsive spacing
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Obx(
//                       () => RichText(
//                         text: TextSpan(
//                           style: TextStyle(
//                             color: appTheme.white,
//                             fontSize: 22.sp,
//                             fontWeight: FontWeight.w900,
//                           ),
//                           children: <TextSpan>[
//                             TextSpan(
//                                 text: "${appStateController.currency.value} " ??
//                                     '₹ '),
//                             TextSpan(
//                                 text: controller.isMasked.value
//                                     ? '*****'
//                                     : netPayAmount),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         netPayLabel,
//                         style: TextStyle(
//                           color: appTheme.white,
//                           fontSize: 13.sp,
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 1.5.h),
//                 Obx(
//                   () => Text(
//                     controller.isMasked.value ? '*****' : accountNumberSuffix,
//                     style: TextStyle(
//                       color: appTheme.white,
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   bankName,
//                   style: TextStyle(
//                     color: appTheme.white,
//                     fontSize: 11.sp,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Right side content
//           Expanded(
//             flex: 1,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 _buildRightSideInfoRow(
//                     workedDaysValue, workedDaysLabel, lopJanValue, lopJanLabel),
//                 _buildRightSideInfoRow(plopDecValue, plopDecLabel,
//                     lopReversalValue, lopReversalLabel),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper widget to build the info rows on the right side
//   Widget _buildRightSideInfoRow(
//       String value1, String label1, String value2, String label2) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         _buildInfoItem(value1, label1),
//         SizedBox(width: 3.w), // Responsive spacing
//         _buildInfoItem(value2, label2),
//       ],
//     );
//   }
//
//   // Helper widget for individual info items on the right
//   Widget _buildInfoItem(String value, String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Obx(
//           () => Text(
//             textAlign: TextAlign.start,
//             controller.isMasked.value ? '*****' : value ?? '',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 10.sp,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Helper method to build the side indicators
//   Widget _buildSideIndicator({
//     required bool isLeft,
//     required Color color,
//     required double indicatorWidth,
//   }) {
//     const Radius cornerRadius = Radius.circular(16); // More curvature
//
//     return Container(
//       width: indicatorWidth,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.4),
//         borderRadius: BorderRadius.horizontal(
//           left: isLeft ? cornerRadius : Radius.zero,
//           right: isLeft ? Radius.zero : cornerRadius,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Widget mainCardWithContent = _buildMainCardContent(context);
//     var appTheme = Get.find<ThemeController>().currentTheme;
//     // Responsive indicator dimensions
//     final double indicatorWidth = 3.w; // e.g., 3% of screen width
//     final double indicatorSpacing = 2.w; // e.g., 0.5% of screen width
//
//     return Padding(
//       padding:
//           EdgeInsets.symmetric(horizontal: indicatorWidth + indicatorSpacing),
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.center,
//         children: <Widget>[
//           mainCardWithContent,
//           Positioned(
//             left: -(indicatorWidth + indicatorSpacing),
//             top: 0,
//             bottom: 0,
//             child: _buildSideIndicator(
//               isLeft: false,
//               color: appTheme.appColor,
//               indicatorWidth: indicatorWidth,
//             ),
//           ),
//           Positioned(
//             right: -(indicatorWidth + indicatorSpacing),
//             top: 0,
//             bottom: 0,
//             child: _buildSideIndicator(
//               isLeft: true,
//               color: appTheme.appColor,
//               indicatorWidth: indicatorWidth,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class PayslipBannerDivided extends GetView<PayslipPageController> {
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
    // Using sizer for responsive dimensions
    final double cardBorderRadius = 6.w; // e.g., 6% of screen width
    final double cardPadding = 5.w; // e.g., 5% of screen width
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
                SizedBox(height: 0.5.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
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
                SizedBox(height: 1.h),
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
}
