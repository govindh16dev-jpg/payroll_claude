import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../controller/tax_page_controller.dart';

buildDropdownScrollTax(
    BuildContext context,
    TaxPageController  controller
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

              scrollController: FixedExtentScrollController(
                initialItem: controller.taxYears.indexOf(controller.selectedYear.value),
              ),
              onSelectedItemChanged: (int index) {
                final selected = controller.taxYears[index];
                controller.selectedYear.value = selected;
                controller.fetchTaxData();
              },
              children: controller.taxYears
                  .map((year) => Center(child: Text(year.financialLabel ?? "")))
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );
}