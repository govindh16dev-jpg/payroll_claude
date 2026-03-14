import 'package:get/get.dart';
import 'package:payroll/features/time/controller/route_history_controller.dart';

import 'manager_time_controller.dart';
import 'time_page_controller.dart';

class TimePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TimePageController());
    Get.put(RouteHistoryController());
    Get.put(ManagerTimeController());
  }
}
