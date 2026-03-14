import 'package:flutter/cupertino.dart';

import '../../../../routes/app_pages.dart';
import '../forgot_password_model.dart';

class ForgotPasswordProvider extends ApiProvider {
  Future<SendMailResponse> sendMail(String email) async {
    try {
      final response = await post(
        ApiConstants.forgotPassword,
        headers: getJsonHeader(),
        body: {
          'email': email
        },
      );
      final sendMailResponse = sendMailResponseFromJson(response.body);
        if (sendMailResponse.success) {
          return sendMailResponse;
        }
        return sendMailResponse;
    } catch (e, s) {
      debugPrint("we got  $e $s");
      throw CustomException('Error Occurred');

    }
  }
  Future<SendMailResponse> verifyMail(VerifyPasswordPostData verifyPasswordData) async {
    try {
      final response = await post(
        ApiConstants.verifyPassword,
        headers: getJsonHeader(),
        body: verifyPasswordData.toJson()
      );
      final sendMailResponse = sendMailResponseFromJson(response.body);
        if (sendMailResponse.success) {
          return sendMailResponse;
        }
        return sendMailResponse;
    } catch (e, s) {
      debugPrint("we got  $e $s");
      throw CustomException('Error Occurred');

    }
  }
}
