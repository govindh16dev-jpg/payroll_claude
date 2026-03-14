import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:payroll/features/payslip_page/data/models/payslipPopupData.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/appstates.dart';
import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';
import '../../controller/payslip_page_controller.dart';
import '../../data/models/employeeData.dart';
import '../../data/models/payslip_dropdown.dart';

class GradientSackIcon extends StatelessWidget {
  const GradientSackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 10.w,
      height: 4.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: appTheme.buttonGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.sackDollar, // Money bag icon
          color: appTheme.white,
          size: 18.sp, // Adjust icon size
        ),
      ),
    );
  }
}

class ExpandableListTile extends GetView<PayslipPageController> {
  final String title;
  final String total;
  final List<Map<String, dynamic>> items;
  final int index;
  RxBool isExpanded = false.obs;
  final appStateController = Get.put(AppStates());
  ExpandableListTile(
      {super.key,
      required this.title,
      required this.total,
      required this.items,
      required this.index});
  var appTheme = Get.find<ThemeController>().currentTheme;
  @override
  Widget build(BuildContext context) {
    appTheme = Get.find<ThemeController>().currentTheme;
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
          // Icon matches theme
          title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: appTheme.black87,
                fontSize: 16.sp),
          ),
          trailing: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appTheme.black87,
                        fontSize: 16.sp),
                    children: <TextSpan>[
                      if (!controller.isMasked.value)
                        TextSpan(
                            text: "${appStateController.currency.value} " ??
                                '₹ '),
                      TextSpan(
                          text: controller.isMasked.value ? '*****' : total),
                    ],
                  ),
                ),
                Obx(
                  () => Center(
                      child:
                          isExpanded.value ? arrowIconUp() : arrowIconDown()),
                )
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
                  padding: EdgeInsets.symmetric(vertical: 8),
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
                      ? ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: items.map((item) {
                            return ListTile(
                                minLeadingWidth: 20,
                                dense: true,
                                leading: GradientSackIcon(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10.0),
                                title: Text(
                                  item['component_name']!,
                                  style: TextStyle(
                                      color: appTheme.black87, fontSize: 14.sp),
                                ),
                                trailing: Obx(
                                  () => GestureDetector(
                                    onTap: () async {
                                      if (item['component_name'] ==
                                          'Income Tax') {
                                        await controller.fetchIncomeTaxData();
                                        showIncomeTaxDialog(
                                            controller.selectedMonth.value,
                                            controller.incomeTaxData,
                                            controller.userProfilePaySlip,
                                            context);
                                      } else {
                                        String payId = item['pay_id'];
                                        String componentId =
                                            item['component_id'];
                                        await controller.fetchFormulaData(
                                            payId, componentId);
                                        showPaySlipDialog(
                                            controller.selectedMonth.value,
                                            controller.payslipPopupData,
                                            context);
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: appTheme.black54,
                                                fontSize: 14.sp),
                                            children: <TextSpan>[
                                              if (!controller.isMasked.value)
                                                TextSpan(
                                                    text:
                                                        "${appStateController.currency.value} " ??
                                                            '₹ '),
                                              TextSpan(
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: appTheme.black54,
                                                      fontSize: 14.sp),
                                                  text: controller
                                                          .isMasked.value
                                                      ? '*****'
                                                      : item['component_values'] ??
                                                          '0'),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Center(
                                            child: Icon(
                                              Icons.info,
                                              size: 18.sp,
                                              color: appTheme.infoIconPaySlip,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ));
                          }).toList(),
                        )
                      : SizedBox.shrink()),
            )
          ]),
    );
  }
}

showPaySlipDialog(String month, PayslipPopupData popupData, context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
          backgroundColor: Colors.transparent, // Transparent background
          elevation: 0,
          insetPadding: EdgeInsets.all(0),
          child: PaySlipPopup(
              month: month,
              popupData: popupData.data,
              item: popupData.data?.componentDetails![0]));
    },
  );
}

Widget arrearsTable(PopupData popupData, String componentName, appTheme) {
  final arrearDetails = popupData.arrearDetails;

  // Calculate total
  double total = 0;
  if (arrearDetails != null) {
    for (var detail in arrearDetails) {
      total += double.tryParse(detail.arrearValue ?? '0') ?? 0;
    }
  }

  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: appTheme.popUp2Border),
      borderRadius: BorderRadius.circular(14),
    ),
    padding: EdgeInsets.all(3),
    child: Container(
      width: 95.w,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appTheme.popUpCardBG,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$componentName',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: appTheme.darkGrey,
            ),
          ),
          SizedBox(height: 1.h),
          Table(
            border: TableBorder.all(color: Colors.grey),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]),
                children: [
                  tableCell('Sino', bold: true),
                  tableCell('Month Name', bold: true),
                  tableCell('Month Value', bold: true),
                ],
              ),
              // Dynamic data rows
              if (arrearDetails != null)
                for (int i = 0; i < arrearDetails.length; i++)
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    children: [
                      tableCell('${i + 1}'),
                      tableCell(arrearDetails[i].monthName ?? ''),
                      tableCell(arrearDetails[i].arrearValue ?? '0'),
                    ],
                  ),
              // Total row
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]),
                children: [
                  tableCell(''),
                  tableCell('Total', bold: true),
                  tableCell(total.toStringAsFixed(2), bold: true),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class PaySlipPopup extends StatelessWidget {
  final String month;
  final ComponentDetail? item;
  final PopupData? popupData;

  const PaySlipPopup({
    super.key,
    required this.month,
    required this.item,
    this.popupData,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = Get.find<ThemeController>().currentTheme;
    final details = popupData?.componentDetails ?? const <ComponentDetail>[];
    final firstDetail = details.isNotEmpty ? details.first : null;

    // Component type checks
    final componentType = item?.componentType ?? '';
    final isEarnings = componentType == 'Earnings';
    final isDeductions = componentType == 'Deductions';
    final isCumulative = componentType == 'Cumulative';

    // Check for arrears status
    final arrearsStatus = firstDetail?.arrearsStatus ?? '';
    final showArrears = arrearsStatus == 'Include' &&
        popupData?.arrearDetails != null &&
        popupData!.arrearDetails!.isNotEmpty;

    // Determine modes based on top-level popupData flags - only for Earnings
    final isLop = isEarnings && (firstDetail?.lopStatus ?? '') == 'Include';
    final isLopr = isEarnings && (firstDetail?.lopReversal ?? '') == 'Include';

    // Provisional row visibility logic
    final provFormula = item?.provFormula ?? '';
    final showProvisional = () {
      if (showArrears) return false;
      if (isCumulative) return false;
      if (isDeductions) return provFormula.isNotEmpty;
      if (isEarnings) return !isLopr || isLop;
      return provFormula.isNotEmpty;
    }();

    // Middle section (LOP/LOPR) visibility
    final showLopSection = () {
      if (isEarnings) {
        final includeLop = (item?.lopStatus ?? '') == 'Include';
        final includeLopr = (item?.lopReversal ?? '') == 'Include';
        return (includeLop || includeLopr) && !isCumulative;
      }
      return false;
    }();

    // Actual section (last row) visibility
    final showActual = () {
      if (isCumulative) return true;
      if (isEarnings) return isLop && !isLopr;
      return true;
    }();

    // Configure titles and formulas based on component type
    final lopOrLoprTitle = () {
      if (isCumulative) return '${item?.componentName ?? ''} Current Month';
      if (isLop) return '${item?.componentName ?? ''} LOP (B)';
      return item?.componentName ?? '';
    }();

    final lopOrLoprFormula = () {
      if (isLop) return item?.lopFormula ?? '';
      return item?.lopreversalFormula?.toString() ?? '';
    }();

    final actualTitle = () {
      if (isCumulative) {
        return '$month Month  ${item?.componentName ?? ''}';
      }
      return '$month Month Actual ${item?.componentName ?? ''} ${item?.lopStatus != 'Include' ? '(C=A)' : '(C=A-B)'}';
    }();

    return Container(
      width: 95.w,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appTheme.popUpBG,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTheme.gradientBlue,
                ),
                child: Icon(Icons.close, color: appTheme.black),
              ),
            ),
          ),
          SizedBox(height: 1.h),

          // 1) Provisional row (A) — conditional based on component type and formula
          if (showProvisional)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: appTheme.popUp1Border),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(3),
              child: InfoCard(
                title: '$month Month Provisional ${item?.componentName ?? ''} (A)',
                formula: item?.provFormula ?? '',
                calculation: item?.provCalculation ?? '',
                result: item?.provValue ?? '',
                month: month,
                componentName: item?.componentName ?? '',
              ),
            ),

          if (showProvisional) SizedBox(height: 1.5.h),

          // 2) Arrears section - NEW
          if (showArrears)
            arrearsTable(
              popupData!,
              '$month Month ${item?.componentName ?? ''}',
              appTheme,
            ),

          if (showArrears) SizedBox(height: 1.5.h),

          // 3) Middle section (LOP/LOPR for Earnings, Current Month for Cumulative, etc.)
          if (showLopSection)
            (item?.popupVersion == 'v2')
                ? lopV2Table(
              popupData!,
              lopOrLoprFormula,
              lopOrLoprTitle,
              appTheme,
            )
                : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: appTheme.popUp2Border),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(3),
              child: LopCard(
                title: lopOrLoprTitle,
                days: item?.lopDays ?? '',
                formula: lopOrLoprFormula,
                calculation: item?.lopCalculation ?? '',
                result: isCumulative ? (item?.provValue ?? '') : (item?.lopValue ?? ''),
                month: month,
              ),
            ),

          if (showLopSection) SizedBox(height: 1.5.h),

          // 4) Actual/YTD section — conditional based on component type
          if (showActual)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: appTheme.popUp3Border),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(3),
              child: InfoCard(
                title: actualTitle,
                formula: (item?.actualFormula ?? ''),
                calculation: item?.actualCalculation ?? '',
                result: item?.actualValue ?? '',
                month: month,
                componentName: item?.componentName ?? '',
              ),
            ),
        ],
      ),
    );
  }
}

showIncomeTaxDialog(
    String month, IncomeTaxData taxData, ProfileDataPayslip profile, context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
          backgroundColor: Colors.transparent, // Transparent background
          elevation: 0,
          insetPadding: EdgeInsets.all(0),
          child: TaxPopup(
            month: month,
            item: taxData,
            profileData: profile,
          ));
    },
  );
}

class TaxPopup extends StatelessWidget {
  final String month;
  final IncomeTaxData item;
  final ProfileDataPayslip profileData;

  const TaxPopup({
    super.key,
    required this.month,
    required this.item,
    required this.profileData,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 95.w,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appTheme.popUpBG,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                  width: 30, // Adjust the size
                  height: 30, // Adjust the size
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appTheme
                        .gradientBlue, // Adjust the background color to match
                  ),
                  child: Icon(
                    Icons.close,
                    color: appTheme.black,
                  )),
            ),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              textAlign: TextAlign.center,
              '$month Month Income Tax Calculation',
              style: TextStyle(
                  color: appTheme.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: appTheme.popUp1Border),
              borderRadius: BorderRadius.circular(14), // Outer border radius
            ),
            padding: EdgeInsets.all(3),
            child: InfoCardIncomeTax(
              title: '$month Month Income Tax Calculation',
              estimatedAnnualTax:
                  profileData.estimatedAnnualTaxableIncome ?? "",
              regime: profileData.taxRegime ?? "",
            ),
          ),
          SizedBox(height: 1.5.h),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: appTheme.popUp1Border),
              borderRadius: BorderRadius.circular(14), // Outer border radius
            ),
            padding: EdgeInsets.all(3),
            child: Container(
              width: 95.w,
              height: 60.h,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appTheme.popUpCardBG,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    buildTableHeader(),
                    Divider(color: appTheme.appColor),
                    if (item.data != null)
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: item.data!.incomeSlab!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final slabItem = item.data!.incomeSlab![index];
                          return buildTableRow(
                              slabItem.slab ?? '',
                              slabItem.formulaOrPercentage ?? '',
                              slabItem.value ?? "");
                        },
                      ),
                    if (item.data != null) Divider(color: appTheme.appColor),
                    SizedBox(height: 1.h),
                    Text("Surcharge",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    if (item.data != null)
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: item.data!.surcharge!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final slabItem = item.data!.surcharge![index];
                          return buildTableRow(
                              slabItem.slab ?? '',
                              slabItem.formulaOrPercentage ?? '',
                              slabItem.value ?? "");
                        },
                      ),
                    Divider(color: appTheme.appColor),
                    SizedBox(height: 1.h),
                    if (item.data != null)
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: item.data!.taxAfterSurcharge!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final slabItem = item.data!.taxAfterSurcharge![index];
                          return buildTableRow(
                              slabItem.slab ?? '',
                              slabItem.formulaOrPercentage ?? '',
                              slabItem.value ?? "");
                        },
                      ),
                    Divider(color: appTheme.appColor),
                    SizedBox(height: 1.h),
                    // Text("Total Estimated Annual Income Tax (D)",
                    //     style: TextStyle(fontWeight: FontWeight.bold)),
                    if (item.data != null)
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: item.data!.otherTabs!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final slabItem = item.data!.otherTabs![index];
                          return buildTableRow(
                              slabItem.slab ?? '',
                              slabItem.formulaOrPercentage ?? '',
                              slabItem.value ?? "");
                        },
                      ),
                    SizedBox(height: 1.h),
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

class InfoCard extends StatelessWidget {
  final String title;
  final String formula;
  final String calculation;
  final String result;
  final String month;
  final String componentName;

  const InfoCard({
    super.key,
    required this.title,
    required this.formula,
    required this.calculation,
    required this.result,
    required this.month,
    required this.componentName
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 95.w,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appTheme.popUpCardBG,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: appTheme.darkGrey,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  'Formula',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                  maxLines: 4,
                ),
              ),
              Flexible(
                flex: 6,
                child: Text(
                  formula,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  'Calculations',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                  maxLines: 1,
                ),
              ),
              Flexible(
                flex: 6,
                child: Text(
                  calculation,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 6,
                child: Text(
                  '$month Month Provisional $componentName',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                child: Text(
                  result,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoCardIncomeTax extends StatelessWidget {
  final String title;
  final String estimatedAnnualTax;
  final String regime;

  const InfoCardIncomeTax({
    super.key,
    required this.title,
    required this.estimatedAnnualTax,
    required this.regime,
  });
  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Column(
      children: [
        Container(
          width: 95.w,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: appTheme.popUpCardBG,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      'Estimated Annual Taxable Income',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: appTheme.darkGrey,
                          fontWeight: FontWeight.bold),
                      maxLines: 4,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Text(
                      estimatedAnnualTax,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: appTheme.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      'Regime',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: appTheme.darkGrey,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Text(
                      regime,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: appTheme.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LopCard extends StatelessWidget {
  final String title;
  final String days;
  final String formula;
  final String calculation;
  final String result;
  final String month;

  const LopCard({
    super.key,
    required this.title,
    required this.formula,
    required this.calculation,
    required this.result,
    required this.days,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Container(
      width: 95.w,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appTheme.popUpCardBG,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: appTheme.darkGrey,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  'LOP Days',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
              Flexible(
                flex: 6,
                child: Text(
                  days,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  'Formula',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                  maxLines: 1,
                ),
              ),
              Flexible(
                flex: 6,
                child: Text(
                  formula,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  'Calculation',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                  maxLines: 1,
                ),
              ),
              Flexible(
                flex: 6,
                child: Text(
                  calculation,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 6,
                child: Text(
                  '$month Month Provisional Basic',//todo replace basic with actual component name
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                child: Text(
                  result,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: appTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildTableHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("Slab", style: TextStyle(fontWeight: FontWeight.bold)),
      Text("Tax(%) / Formula", style: TextStyle(fontWeight: FontWeight.bold)),
      Text("Value", style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}

Widget buildTableRow(String slab, String tax, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 30.w, child: Text(slab)),
        SizedBox(width: 16.w, child: Text(tax)),
        SizedBox(width: 16.w, child: Text(value)),
      ],
    ),
  );
}

Widget tableCell(String text, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontSize: 14.sp,
      ),
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    ),
  );
}

Widget lopV2Table(PopupData popupData,String formula,String title, appTheme,) {
  // Filter for row entries only
  final dataRows =
  popupData.componentDetails?.first.lopStatus=="Include"?popupData.payLossDataLop:popupData.payLossDataLopr;

String totalValue =popupData.componentDetails?.first.lopStatus=="Include"?popupData.totalValueLop!:popupData.totalValueLopr!;
String totalDays =popupData.componentDetails?.first.lopStatus=="Include"?popupData.lopTotalDays!:popupData.loprTotalDays!;

  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: appTheme.popUp2Border),
      borderRadius:
      BorderRadius.circular(14), // Outer border radius
    ),
    padding: EdgeInsets.all(3),
    child: Container(
      width: 95.w,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appTheme.popUpCardBG,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: appTheme.darkGrey,
            ),
          ),
          SizedBox(height: 1.h),
          Table(
            border: TableBorder.all(color: Colors.grey),
            columnWidths: {
              0: FlexColumnWidth(0.6),     // S.No - 1 part
              1: FlexColumnWidth(1.5),     // Month - 2 parts (twice as wide)
              2: FlexColumnWidth(1),     // Days - 1 part
              3: FlexColumnWidth(1),     // Basic - 2 parts
              4: FlexColumnWidth(1),     // LOP Days - 1 part
              5: FlexColumnWidth(1)
            },
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]),
                children: [
                  tableCell('Si.No.', bold: true),
                   tableCell('Month', bold: true),
                  tableCell('Days', bold: true),
                  tableCell('Basic', bold: true),
                  tableCell('Days', bold: true),
                  tableCell('LOP Value', bold: true),
                ],
              ),
              // Dynamic data rows
           if(dataRows!=null)   for (int i = 0; i < dataRows.length; i++)
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    tableCell('${i + 1}'),
                    tableCell(dataRows[i].month ?? ''),
                    tableCell(dataRows[i].monthDays ?? ''),
                    tableCell(dataRows[i].monthValue.toString() ?? ''),
                    tableCell(dataRows[i].noOfDays ?? ''),
                    tableCell(dataRows[i].componentValue.toString() ?? ''),
                  ],
                ),
              // Total row if present

                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    tableCell(''),
                    tableCell(''),
                    tableCell(''),
                    tableCell('Total', bold: true),
                    tableCell(totalDays ?? ''),
                    tableCell(totalValue?? '', bold: true),
                  ],
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    'Formula',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: appTheme.darkGrey,
                    ),
                    maxLines: 1,
                  ),
                ),
                Flexible(
                  flex: 6,
                  child: Text(
                    formula,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: appTheme.darkGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
