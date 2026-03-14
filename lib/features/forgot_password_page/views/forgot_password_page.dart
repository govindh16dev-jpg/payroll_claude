import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payroll/features/forgot_password_page/views/controller/forgot_password_page_controller.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:payroll/util/custom_widgets.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sizer/sizer.dart';

import '../../../config/constants.dart';
import '../../../theme/theme_controller.dart';
import '../../../util/common/extensions.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordPageController> {
  ForgotPasswordPage({super.key});
  var appTheme = Get.find<ThemeController>().currentTheme;
  Widget _buildTextField(
      TextEditingController controllerText, String hint, bool isMobile,
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
        controller: controllerText,
        obscureText: obscureText,
        validator: controller.isEmailSent.value ? validateOTP : validateEmail,
        style: TextStyle(color: appTheme.black),
        keyboardType:
            hint == "ENTER OTP" ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          hintText: hint,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.transparent,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.transparent,
              )),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.transparent,
              )),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.transparent,
              )),
          hintStyle:
              TextStyle(fontSize: isMobile ? 14.sp : 18.sp, color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    controller.isNewPassVisible.value =
                        !controller.isNewPassVisible.value;
                  },
                  icon: Icon(
                      color: appTheme.appGradient,
                      controller.isNewPassVisible.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildResetTextField(
      TextEditingController controllerText, String hint, bool isMobile) {
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
        controller: controllerText,
        obscureText: controller.isConfirmPassVisible.value,
        validator: (value) {
          if (value!.isEmpty) {
            return 'This field is required';
          }
          if (value != controller.newPassword.text) {
            return 'Password is not matching';
          }
          return null;
        },
        style: TextStyle(color: appTheme.black),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.transparent)),
            errorBorder: InputBorder.none,
            hintStyle: TextStyle(
                fontSize: isMobile ? 14.sp : 18.sp, color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            suffixIcon: IconButton(
              onPressed: () {
                controller.isConfirmPassVisible.value =
                    !controller.isConfirmPassVisible.value;
              },
              icon: Icon(
                  color: appTheme.appGradient,
                  controller.isConfirmPassVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isMobile =
            sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;

        return Obx(() => controller.isPasswordResetDone.value
            ? Scaffold(
                body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: height / 4,
                      ),
                      Image.asset(
                          height: 10.h,
                          width: 20.w,
                          'assets/logos/app_icon.png'),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'HURRAY!! ',
                              style: TextStyle(
                                fontSize: isMobile ? 16.sp : 18.sp,
                                fontWeight: FontWeight.w900,
                                color: appTheme.appColor,
                              ),
                            ),
                            TextSpan(
                              text: 'YOUR PASSWORD HAS BEEN RESET',
                              style: TextStyle(
                                fontSize: isMobile ? 16.sp : 18.sp,
                                color: appTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'YOU CAN ',
                              style: TextStyle(
                                fontSize: isMobile ? 16.sp : 18.sp,
                                color: appTheme.black,
                              ),
                            ),
                            TextSpan(
                              text: 'SIGN IN ',
                              style: TextStyle(
                                fontSize: isMobile ? 16.sp : 18.sp,
                                fontWeight: FontWeight.w900,
                                color: appTheme.appColor,
                              ),
                            ),
                            TextSpan(
                              text: 'YOU CAN WITH YOUR CREDENTIALS',
                              style: TextStyle(
                                fontSize: isMobile ? 16.sp : 18.sp,
                                color: appTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'NOW',
                          style: TextStyle(
                            fontSize: isMobile ? 16.sp : 18.sp,
                            fontWeight: FontWeight.w900,
                            color: appTheme.appColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
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
                            Get.offAllNamed(AppRoutes.loginPage);
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
                    ],
                  ),
                ),
              ))
            : Scaffold(
                appBar: AppBar(
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Image.asset(
                            height: 5.5,
                            width: 5.5.w,
                            'assets/logos/app_icon.png'),
                      ),
                    ),
                  ],
                ),
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: height / 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        thickness: 1,
                                        color: appTheme.appColor)),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Obx(
                                      () => Text(
                                          controller.isEmailSent.value
                                              ? 'RESET PASSWORD'
                                              : 'FORGOT PASSWORD',
                                          style: TextStyle(
                                              color: appTheme.appColor,
                                              fontSize:
                                                  isMobile ? 16.sp : 18.sp,
                                              fontWeight: FontWeight.w900)),
                                    )),
                                Expanded(
                                    child: Divider(
                                        thickness: 1,
                                        color: appTheme.appColor)),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Obx(() => !controller.isEmailSent.value
                                ? Form(
                                    key: controller.forgotPassEmailFormKey,
                                    child: _buildTextField(
                                        controller.forgetEmailController,
                                        'ENTER YOUR REGISTERED EMAIL ADDRESS',
                                        isMobile),
                                  )
                                : SizedBox.shrink()),
                            SizedBox(
                              height: 2.h,
                            ),
                            Obx(() => controller.isEmailSent.value
                                ? Form(
                                    key: controller.resetPassFormKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20.0),
                                      child: Column(
                                        children: [
                                          _buildTextField(
                                              controller.newPassword,
                                              'SET PASSWORD',
                                              isMobile,
                                              isPassword: true,
                                              obscureText: controller
                                                  .isNewPassVisible.value),
                                          SizedBox(
                                            height: 2.h,
                                          ),
                                          _buildResetTextField(
                                            controller.confirmPassword,
                                            'RE-ENTER PASSWORD',
                                            isMobile,
                                          ),
                                          SizedBox(
                                            height: 2.h,
                                          ),
                                          _buildTextField(
                                              controller.verifyCodeController,
                                              'ENTER OTP',
                                              isMobile),
                                        ],
                                      ),
                                    ))
                                : SizedBox.shrink()),
                            SizedBox(height: 3.h),
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
                                    if (controller.isEmailSent.value) {
                                      controller.onSetPassword();
                                    } else {
                                      controller.onSendMail(false);
                                    }
                                  },
                                  child: Obx(
                                    () => Text(
                                      controller.isEmailSent.value
                                          ? 'RESET'
                                          : 'SEND',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w900,
                                        color: appTheme.white,
                                      ),
                                    ),
                                  )),
                            ),
                            SizedBox(height: 3.h),
                            if (controller.isEmailSent.value)
                              GestureDetector(
                                onTap: () {
                                  controller.onSendMail(true);
                                },
                                child: Text(
                                  'RESEND OTP',
                                  style: TextStyle(
                                    fontSize: isMobile ? 16.sp : 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: appTheme.appColor,
                                    decoration: TextDecoration.underline,
                                    decorationColor: appTheme.appColor,
                                    decorationThickness: 2,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            // if( controller.isEmailSent.value)    TimerPage(),
                          ],
                        ),
                      ),
                    ),
                    Obx(
                      () => Visibility(
                          visible: controller.loading.value == Loading.loading,
                          child: loadingIndicator()),
                    )
                  ],
                ),
              ));
      },
    );
  }
}
