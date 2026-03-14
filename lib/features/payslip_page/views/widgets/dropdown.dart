import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../controller/payslip_page_controller.dart';


buildDropdownScrollYears(
    BuildContext context,
    PayslipPageController  controller
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
              child:  Text('Done', style: TextStyle(fontSize: 18.sp )),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 40,
              scrollController: FixedExtentScrollController(initialItem: controller.payslipYears.indexOf(controller.selectedYear.value),),
              onSelectedItemChanged: (int index) {
                var selectedItem= controller.payslipYears[index];
                controller.selectedYear.value =
                    selectedItem ?? '';
                controller.selectedMonth.value =
                controller
                    .payslipYearMonthMap[
                controller
                    .selectedYear
                    .value]
                    ?.isNotEmpty ??
                    false
                    ? controller
                    .payslipYearMonthMap[
                controller
                    .selectedYear
                    .value]!
                    .first
                    : '';
                controller.fetchPaySlipData(
                    true);
              },
              children: controller.payslipYears.map((String year) {
                return Text(year);
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}

buildDropdownScrollMonth(
    BuildContext context,
    PayslipPageController controller,
    ) {
  final appTheme = Get.find<ThemeController>().currentTheme;

  // Extract the month list for the selected year
  final monthList = controller.payslipYearMonthMap[controller.selectedYear.value] ?? [];

  // Safely find the initial index for the selected month
  final initialIndex = monthList.indexOf(controller.selectedMonth.value);
  final scrollController = FixedExtentScrollController(
    initialItem: initialIndex >= 0 ? initialIndex : 0,
  );

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
              child: Text(
                'Done',
                style: TextStyle(fontSize: 18.sp),
              ),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              backgroundColor: Colors.white,
              itemExtent: 40,
              scrollController: scrollController,
              onSelectedItemChanged: (int index) {
                final selectedItem = monthList[index];
                controller.selectedMonth.value = selectedItem;
                controller.fetchPaySlipData(true);
              },
              children: monthList
                  .map((month) => Center(child: Text(month)))
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
