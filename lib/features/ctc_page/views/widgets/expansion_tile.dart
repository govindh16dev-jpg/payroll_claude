import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/appstates.dart';
import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';
import '../../controller/ctc_page_controller.dart';

class CTCExpandableListTile extends GetView<CTCPageController> {
  final String title;
  final String yearlyTotal;
  final String monthlyTotal;
  final List<Map<String, dynamic>> items;
  final int index;
  final CTCTileType tileType;
  RxBool isExpanded = false.obs;
  final appStateController = Get.put(AppStates());

  CTCExpandableListTile({
    super.key,
    required this.title,
    required this.yearlyTotal,
    required this.monthlyTotal,
    required this.items,
    required this.index,
    this.tileType = CTCTileType.earnings,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Theme(
      data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: controller.isExpanded[index],
        iconColor: appTheme.darkGrey,
        collapsedTextColor: appTheme.darkGrey,
        onExpansionChanged: (expanded) {
          controller.toggleExpanded(index);
          isExpanded.value = expanded;
        },
        tilePadding: EdgeInsets.symmetric(horizontal: 8.0),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16.sp,
          ),
        ),
        trailing: Obx(
              () => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Yearly Amount
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Yearly',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appTheme.black87,
                        fontSize: 14.sp,
                      ),
                      children: <TextSpan>[
                        if (!controller.isMasked.value)
                          TextSpan(text: "${appStateController.currency.value ?? '₹'} "),
                        TextSpan(
                          text: controller.isMasked.value ? '*****' : yearlyTotal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              // Monthly Amount
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Monthly',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appTheme.black87,
                        fontSize: 14.sp,
                      ),
                      children: <TextSpan>[
                        if (!controller.isMasked.value)
                          TextSpan(text: "${appStateController.currency.value ?? '₹'} "),
                        TextSpan(
                          text: controller.isMasked.value ? '*****' : monthlyTotal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              Obx(
                    () => Center(
                  child: isExpanded.value ? arrowIconUp() : arrowIconDown(),
                ),
              ),
            ],
          ),
        ),
        children: [
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: appTheme.payslipExpandable,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: appTheme.white,
                gradient: LinearGradient(
                  colors: appTheme.paySlipDetailsBG,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: items.isNotEmpty
                  ? Column(
                children: [
                  // Header Row
                  _buildTableHeader(appTheme),
                  // Divider(thickness: 1, color: Colors.grey[300]),
                  // Data Rows
                  ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: items.map((item) => _buildCTCRow(item, appTheme)).toList(),
                  ),
                ],
              )
                  : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(var appTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Components",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Yearly CTC",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: appTheme.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Monthly CTC",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: appTheme.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTCRow(Map<String, dynamic> item, var appTheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          // bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Component Name
          Expanded(
            flex: 3,
            child: Text(
              item['component_name'] ?? item['compensation'] ?? '',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13.sp,
              ),
            ),
          ),
          // Yearly Amount
          Expanded(
            flex: 2,
            child: Obx(
                  () => RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: appTheme.black54,
                    fontSize: 13.sp,
                  ),
                  children: <TextSpan>[
                    if (!controller.isMasked.value)
                      TextSpan(text: "${appStateController.currency.value ?? '₹'} "),
                    TextSpan(
                      text: controller.isMasked.value
                          ? '*****'
                          : (item['amount'] ?? item['yearly_amount'] ?? '0'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Monthly Amount
          Expanded(
            flex: 2,
            child: Obx(
                  () => RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: appTheme.black54,
                    fontSize: 14.sp,
                  ),
                  children: <TextSpan>[
                    if (!controller.isMasked.value)
                      TextSpan(text: "${appStateController.currency.value ?? '₹'} "),
                    TextSpan(
                      text: controller.isMasked.value
                          ? '*****'
                          : (item['monthly_amount'] ?? '0'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enum to define different types of CTC tiles
enum CTCTileType {
  earnings,
  employerContribution,
  ctcBreakdown,
}

// Helper widget for CTC summary cards (if needed)
Widget buildCTCSummaryCard({
  required String title,
  required String amount,
  required Color startColor,
  required Color endColor,
  required bool isMasked,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [startColor, endColor],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          isMasked ? '*****' : amount,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class CTCBreakdownCards extends GetView<CTCPageController> {
  final appStateController = Get.put(AppStates());

  CTCBreakdownCards({super.key});

  Widget _buildCTCCard({
    required String title,
    required String amount,
    required List<Color> gradientColors,
    required var appTheme,
  }) {
    return Container(
      width: double.infinity,
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: appTheme.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          Obx(() => RichText(
            text: TextSpan(
              style: TextStyle(
                color: appTheme.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
              ),
              children: <TextSpan>[
                if (!controller.isMasked.value)
                  TextSpan(text: "${appStateController.currency.value ?? '₹'} "),
                TextSpan(text: controller.getMaskedAmount(amount)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;

    return Obx(() => Column(
      children: [
        // CTC Yearly Card
        _buildCTCCard(
          title: 'CTC Yearly',
          amount: controller.ctcTotals['ctc_yearly'] ?? '0',
          gradientColors: appTheme.buttonGradient,
          appTheme: appTheme,
        ),

        SizedBox(height: 12),

        // CTC Monthly Card
        _buildCTCCard(
          title: 'CTC Monthly',
          amount: controller.ctcTotals['ctc_monthly'] ?? '0',
          gradientColors: appTheme.buttonGradient,
          appTheme: appTheme,
        ),
      ],
    ));
  }
}
