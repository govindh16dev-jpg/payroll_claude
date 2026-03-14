import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payroll/features/forgot_password_page/data/repository/forgot_password_provider.dart';

import '../../../../routes/app_pages.dart';
import '../../data/forgot_password_model.dart';

class ForgotPasswordPageController extends GetxController {
  var loading = Loading.initial.obs;
  final ForgotPasswordProvider forgotPasswordProvider =
      Get.put(ForgotPasswordProvider());
  final appStateController = Get.put(AppStates());
  final forgetEmailController = TextEditingController();
  final verifyCodeController = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  final forgotPassEmailFormKey = const GlobalObjectKey<FormState>('Forgot');
  final resetPassFormKey = const GlobalObjectKey<FormState>('ForgotReset');
  RxBool isEmailSent = false.obs;
  RxBool isPasswordResetDone = false.obs;
  late SendMailResponse sendMailResponse;
  RxBool isConfirmPassVisible = true.obs;
  RxBool isNewPassVisible = true.obs;
  dynamic argumentData = Get.arguments;

  @override
  void onReady() {
    super.onReady();
    forgetEmailController.text = argumentData['email'];
  }

  onSendMail(bool isResend) async {
    bool isFieldValid=false;

    if(isResend)  {
      isFieldValid =true;
    }else{
      isFieldValid  = forgotPassEmailFormKey.currentState!.validate();
    }

    if (isFieldValid == true) {
      try {
        loading.value = Loading.loading;

        await forgotPasswordProvider
            .sendMail(forgetEmailController.text)
            .then((value) {
          loading.value = Loading.loaded;
          sendMailResponse = value;
          if (value.success) {
            isEmailSent.value = true;
            appSnackBar(data: value.message, color: AppColors.textGreenColor);
          } else {
            appSnackBar(
                data: value.data[0]['error_msg'], color: AppColors.appRedColor);
          }
        });
      } on CustomException {
        loading.value = Loading.loaded;
        appSnackBar(
            data: sendMailResponse.message, color: AppColors.appRedColor);
      } catch (error) {
        loading.value = Loading.loaded;
        // appSnackBar(data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
        appSnackBar(
            data: 'Failed: ${sendMailResponse.message}',
            color: AppColors.appRedColor);
      }
    }
  }

  onSetPassword() async {
    bool isFieldValid = resetPassFormKey.currentState!.validate();

    if (isFieldValid == true) {
      try {
        loading.value = Loading.loading;

        await forgotPasswordProvider
            .verifyMail(VerifyPasswordPostData(
                email: forgetEmailController.text,
                password: newPassword.text,
                confirmPassword: confirmPassword.text,
                otp: verifyCodeController.text))
            .then((value) {
          loading.value = Loading.loaded;
          sendMailResponse = value;
          if (value.success) {
            isPasswordResetDone.value = true;
            appSnackBar(data: value.message, color: AppColors.textGreenColor);
          } else {
            appSnackBar(
                data: value.data[0]['error_msg'], color: AppColors.appRedColor);
          }
        });
      } on CustomException catch (err) {
        loading.value = Loading.loaded;
        appSnackBar(data: err.message, color: AppColors.appRedColor);
      } catch (error) {
        loading.value = Loading.loaded;
        appSnackBar(
            data: 'Failed: ${error.toString()}', color: AppColors.appRedColor);
      }
    }
  }

  @override
  void dispose() {
    Get.delete<ForgotPasswordPageController>();
    super.dispose();
  }
}
