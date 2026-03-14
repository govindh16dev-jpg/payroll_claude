import 'package:get/get.dart';

import 'ctc_page_controller.dart';

class CTCPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CTCPageController());
  }
}
