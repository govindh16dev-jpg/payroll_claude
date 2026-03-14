import 'package:get/get.dart';

import 'forgot_password_page_controller.dart';

class ForgotPasswordPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ForgotPasswordPageController());
  }
}
