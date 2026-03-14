

import 'package:get/get.dart';
import 'package:payroll/features/splash/controller/splash_page_controller.dart';

import '../../../service/api_service.dart';
import '../../../service/network_service.dart';

class SplashPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkService(), permanent: true);
    Get.put(ProgressService());
    Get.put(SplashPageController());

  }
}
