import 'package:get/get.dart';

import 'leave_page_controller.dart';

class LeavePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LeavePageController());
  }
}
