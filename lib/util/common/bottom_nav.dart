
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:sizer/sizer.dart';

import '../../theme/theme_controller.dart';

class CustomBottomNaviBar extends StatelessWidget {
  const CustomBottomNaviBar({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return  Container(
      margin: const EdgeInsets.all(8),
      // Padding around the nav bar
      height: 5.h,
      width: 30.w,
      // Height of the navigation bar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:appTheme.buttonGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30), // Rounded edges
      ),
      child:Center(
        child: ElevatedButton(
          onPressed: (){
            if (Get.currentRoute != AppRoutes.homePage) {
              Get.offAllNamed(AppRoutes.homePage);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            // Set to transparent for gradient
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Icon(
                Icons.dashboard,
                color: appTheme.white,
                size: 20.sp,
              ),
               Text("Home",
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                    color: appTheme.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ))

              // Spacing between icon and label
            ],
          ),
        ),
      )
    );
  }
}

