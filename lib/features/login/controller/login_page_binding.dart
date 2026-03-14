import 'package:get/get.dart';
import '../../../config/appstates.dart';
import 'login_page_controller.dart';

class LoginPageBinding extends Bindings {
  @override
  void dependencies() {
    // Delete old controller if exists


    // Create new controller
    Get.put<LoginPageController>(LoginPageController());
  }
}
