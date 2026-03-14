import 'package:get/get.dart';
import 'package:payroll/features/homepage/controller/home_page_controller.dart';
import 'package:payroll/features/profile_page/views/controller/profile_page_binding.dart';
import 'package:payroll/features/profile_page/views/controller/profile_page_controller.dart';

import 'main_page_controller.dart';

class MainPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainPageController());
    Get.put(HomePageController());
    // Get.put(ExpensePageController());
    // Get.put(TimePageController());
    // Get.put(LeavePageController());
    Get.put(ProfilePageBinding());
    Get.put(ProfilePageController());

  }
}
