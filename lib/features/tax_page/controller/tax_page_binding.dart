import 'package:get/get.dart';

import 'tax_page_controller.dart';

class TaxPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TaxPageController());
  }
}
