import 'package:get/get.dart';

import 'payslip_page_controller.dart';

class PayslipPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PayslipPageController());
  }
}
