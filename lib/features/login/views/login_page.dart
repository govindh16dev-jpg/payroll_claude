import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';

import '../../../config/constants.dart';
import '../../../routes/app_route.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/extensions.dart';
import '../controller/login_page_controller.dart';
import 'biometricAuth.dart';

class LoginPage extends GetView<LoginPageController> {
  LoginPage({super.key});
  var appTheme = Get.find<ThemeController>().currentTheme;
  Widget _buildTextField(
      TextEditingController controllerText, String hint, bool isMobile,ValueKey key,
      {bool isPassword = false, bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.transparent, // Required for BoxDecoration border
        ),
        gradient: LinearGradient(
          colors: appTheme.textFieldBorderGradient,
        ),
      ),
      child: TextFormField(
        key: key,
        validator: isPassword ? validatePassword : validateEmail,
        keyboardType:
            isPassword ? TextInputType.text : TextInputType.emailAddress,
        obscureText: obscureText,
        controller: controllerText,
        style: TextStyle(color: appTheme.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          hintText: hint,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.transparent,
              )),
          hintStyle: TextStyle(
            fontSize: isMobile ? 14.sp : 18.sp,
            color: appTheme.textFieldLabel,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    controller.isVisible.value = !controller.isVisible.value;
                  },
                  icon: Icon(
                      color: appTheme.appGradient,
                      controller.isVisible.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    appTheme = Get.find<ThemeController>().currentTheme;
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isMobile =
            sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

        return UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.cupertino,
          // upgrader: Upgrader(debugDisplayAlways: true),
          child: Scaffold(
            key: const ValueKey('login_page_scaffold'), // Add unique key
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                        height: 5.5.h, width: 5.5.h, 'assets/logos/app_icon.png'),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: CustomPaint(
                //     size: Size(40.w, 15.h),
                //     painter: WavePainter(),
                //   ),
                // ),
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: GradientBlobScreen(),
                // ),
          
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome to ',
                                  style: TextStyle(
                                    fontSize: isMobile ? 20.sp : 36.sp,
                                    fontWeight: FontWeight.bold,
                                    color: appTheme.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Azatecon',
                                  style: TextStyle(
                                    fontSize: isMobile ? 20.sp : 36.sp,
                                    fontWeight: FontWeight.bold,
                                    color: appTheme.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 1.h),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'A',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14.sp : 18.sp,
                                    color: appTheme.welcomeText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'N ',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14.sp : 18.sp,
                                    color: appTheme.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'I',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14.sp : 18.sp,
                                    color: appTheme.welcomeText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'NTELLIGENT PAYROLL COMPANY',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14.sp : 18.sp,
                                    color: appTheme.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Form(
                            key: controller.loginFormKey,
                            child: Column(
                              children: [
                                _buildTextField(controller.usernameController,
                                    'E-MAIL / PHONE', isMobile,const ValueKey('username_field'),),
                                SizedBox(height: 3.h),
                                Obx(
                                  () => _buildTextField(
                                      controller.passwordController,
                                      'PASSWORD',
                                      isMobile,const ValueKey('password_field'),
                                      isPassword: true,
                                      obscureText: controller.isVisible.value),
                                ),
                                SizedBox(height: 1.h),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Obx(
                                    () => Checkbox(
                                        value: controller.isRememberMe.value,
                                        onChanged: (value) {
                                          controller.isRememberMe.value =
                                              !controller.isRememberMe.value;
                                        }),
                                  ),
                                  Text(
                                    'REMEMBER ME',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14.sp : 16.sp,
                                      color: appTheme.black,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(arguments: {
                                    'email': controller.usernameController.text
                                  }, AppRoutes.forgotPasswordPage);
                                },
                                child: Text(
                                  'FORGOT PASSWORD?',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14.sp : 16.sp,
                                    color: appTheme.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: appTheme.buttonGradient,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                controller.onLoginTap();
                              },
                              child: Text(
                                'SIGN IN',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                  color: appTheme.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Obx(() => controller.isLoggedIn.value && controller.appStateController.isBioMetricsSupported.value
                              ? Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                            thickness: 1,
                                            color: appTheme.appColor)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text('OR SIGN IN WITH',
                                          style: TextStyle(
                                            color: appTheme.appColor,
                                            fontSize: isMobile ? 14 : 16,
                                            fontWeight: FontWeight.w900,
                                          )),
                                    ),
                                    Expanded(
                                        child: Divider(
                                            thickness: 1,
                                            color: appTheme.appColor)),
                                  ],
                                )
                              : SizedBox.shrink()),
                          SizedBox(height: 2.h),
                          Obx(() => controller.isLoggedIn.value
                              ? BiometricAuth(rememberMe: controller.isRememberMe.value,)
                              : SizedBox.shrink()),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Visibility(
                    visible: controller.loading.value == Loading.loading,
                    child: Center(
                      child: SpinKitWave(
                        color: appTheme.appColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
