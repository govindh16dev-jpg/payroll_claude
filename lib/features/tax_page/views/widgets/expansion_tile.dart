import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/appstates.dart';
import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';
import '../../controller/tax_page_controller.dart';

class ExpandableListTile extends GetView<TaxPageController> {
  final String title;
  final String total;
  final List<Map<String, dynamic>> items;
  final int index;
  final bool isGrossSalary;
  RxBool isExpanded = false.obs;
  final appStateController = Get.put(AppStates());
  ExpandableListTile(
      {super.key,
      required this.title,
      required this.isGrossSalary,
      required this.total,
      required this.items,
      required this.index});


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
          // Icon matches theme
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,fontSize: 16.sp
            ),
          ),
          trailing: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style:  TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appTheme.black87,
                        fontSize: 16.sp
                    ),
                    children: <TextSpan>[
                      if(!controller.isMasked.value)TextSpan(text: "${appStateController.currency.value} "??'₹ '),
                      TextSpan(text: controller.isMasked.value ? '*****' : total),
                    ],
                  ),
                ),

                Obx(
                  () => Center(
                    child: isExpanded.value
                        ?  arrowIconUp():  arrowIconDown()
                  ),
                )
              ],
            ),
          ),
          children: [
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient:
                LinearGradient(colors: appTheme.payslipExpandable,
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
                      ? ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: items.map((item) {
                            return ListTile(
                                minLeadingWidth: 20,
                                dense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 25.0),
                                title: Text(
                                  isGrossSalary
                                      ? item['property_key']
                                      : item['component_name']!,
                                  style: TextStyle(color: Colors.black87 ,fontSize: 14.sp),
                                ),
                                trailing: Obx(
                                  () => RichText(
                                    text: TextSpan(
                                      style:  TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: appTheme.black54,
                                          fontSize: 14.sp
                                      ),
                                      children: <TextSpan>[
                                        if(!controller.isMasked.value)TextSpan(text: "${appStateController.currency.value} "??'₹ '),
                                        TextSpan(
                                            style:  TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: appTheme.black54,
                                                fontSize: 14.sp
                                            ),
                                            text: controller.isMasked.value ? '*****' : item['total']??'0'),
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
        SizedBox(width: 20.w, child: Text(tax)),
        SizedBox(width: 12.w, child: Text(value)),
      ],
    ),
  );
}
