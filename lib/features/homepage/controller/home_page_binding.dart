import 'package:get/get.dart';

import '../../profile_page/views/controller/profile_page_binding.dart';
import '../../profile_page/views/controller/profile_page_controller.dart';
import 'home_page_controller.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomePageController());
    Get.put(ProfilePageBinding());
    Get.put(ProfilePageController());
  }
}
