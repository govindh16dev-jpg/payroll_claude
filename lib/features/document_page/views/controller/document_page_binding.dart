import 'package:get/get.dart';

import 'document_page_controller.dart';

class DocumentPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DocumentPageController());
  }
}
