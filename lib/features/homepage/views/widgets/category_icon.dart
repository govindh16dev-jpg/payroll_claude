import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/constants.dart';
import '../../../../theme/theme.dart';
import '../../../../theme/theme_controller.dart';
import '../../../login/domain/model/login_model.dart';
import '../../controller/home_page_controller.dart';

getNavigation(label) {
  final homeController = Get.find<HomePageController>();
  final bool isManager = homeController.isManager();

  switch (label) {
    case 'payslip':
      Get.toNamed(AppRoutes.paySlipPage);
      break;
    case 'Settings':
      Get.to(() => SettingsPage());
      break;
    case 'tax_computation':
      Get.toNamed(AppRoutes.taxPage);
      break;
    case 'my_ctc':
      Get.toNamed(AppRoutes.ctcPage);
      break;
    case 'absence_employee':
    case 'absence_manager':
      if (isManager) {
        Get.toNamed(AppRoutes.managerPage);
      } else {
        Get.toNamed(AppRoutes.leavePage);
      }
      break;
    case 'Employee Time':
      break;
    case 'profile':
      Get.toNamed(AppRoutes.profilePage);
      break;
    case 'time':
      if (isManager) {
        Get.toNamed(AppRoutes.managerTimePage);
      } else {
        Get.toNamed(AppRoutes.timePage);
      }
      break;
    case 'Logout':
      signOutSmart();
      break;
  }
}
Future<void> signOutSmart() async {
  const storage = FlutterSecureStorage();

  // Check if rememberMe is true
  final rememberMe = await storage.read(key: PrefStrings.rememberMe) == 'true';

  String? userCredData = await storage.read(key: PrefStrings.userCredentialsData);
  LoginCredentials? userData;
  if (userCredData != null) {
    userData = loginCredentialsFromJson(userCredData);
  }

  await storage.deleteAll();

  if (rememberMe && userData != null) {
    await storage.write(
      key: PrefStrings.userCredentialsData,
      value: loginCredentialsToJson(userData),
    );
    await storage.write(key: PrefStrings.rememberMe, value: 'true');
  }
  if (userData != null) {
    await storage.write(
      key: PrefStrings.userCredentialsData,
      value: loginCredentialsToJson(userData),
    );
  }
  Get.offAllNamed(AppRoutes.loginPage);
}

class CustomIconButton extends StatelessWidget {
  final double size;
  final String icon;
  final  String label;
  final String menuKey;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.size,
    required this.menuKey,
  });

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme; // Access currentTheme in build
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        InkWell(
            onTap: () {
              getNavigation(menuKey);
            },
            borderRadius: BorderRadius.circular(size ),
            child:
            Container(
              width: 7.w,
              height: 7.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: appTheme.buttonGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35), // Clip the image into a circle
                  child: CachedNetworkImage(
                    imageUrl: icon,
                    width: 10.w,
                    height: 5.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(), // Loading indicator
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
            )
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 14.sp ,
            color: appTheme.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class PulsingInfinityIcon extends StatefulWidget {
  const PulsingInfinityIcon({super.key});

  @override
  State<PulsingInfinityIcon> createState() => _PulsingInfinityIconState();
}

class _PulsingInfinityIconState extends State<PulsingInfinityIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // pulse back and forth

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return ScaleTransition(
      scale: _animation,
      child:   FaIcon(
        FontAwesomeIcons.infinity,
        size: 24.sp,
        color: appTheme.orangeGradient,
      ),
    );
  }
}