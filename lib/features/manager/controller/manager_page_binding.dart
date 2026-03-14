import 'package:get/get.dart';

import 'manager_page_controller.dart';

class ManagerPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ManagerPageController());
  }
}
