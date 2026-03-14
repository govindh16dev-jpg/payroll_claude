import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/theme_controller.dart';
import '../../../../util/custom_widgets.dart';
import '../../controller/home_page_controller.dart';


class NotificationFilterDropdown extends GetView<HomePageController>{


  const NotificationFilterDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var appTheme = Get.find<ThemeController>().currentTheme;
      return DropdownButton<String>(
      value: controller.selectedNotificationFilter.value,
      style: GoogleFonts.poppins(
        fontSize: 16.sp ,
        color: appTheme.appColor,
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.updateNotificationFilter(newValue);
        }
      },
      items: controller.notificationFilterOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                color: appTheme.appColor,
              )
          ),
        );
      }).toList(),
      dropdownColor: appTheme.white,
      icon:   arrowIconDown(),
      underline: Divider(
        thickness: 0.1,
        height: 1,
        color: appTheme.appColor,
      ),
    );
    });
  }
}


