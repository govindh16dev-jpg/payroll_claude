import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:payroll/features/profile_page/data/model/profile_model.dart';

import '../features/login/domain/model/login_model.dart';

class AppStates extends GetxController {
  RxString messageCount = '0'.obs;
  RxString currentRouteKm = '0'.obs;
  RxBool isOngoingRide = false.obs;
  RxBool isTestUser = false.obs;
  RxBool isBioMetricsSupported = false.obs;
  RxString currency = ''.obs;
  RxString upcomingHoliday = ''.obs;
  RxString taxRegime = ''.obs;
  RxList menuItems = [ ].obs;

  var userData = UserData().obs;
  var userProfileData = UserProfile().obs;
  var userProfileInfo = UserProfile().obs;
  Position? currentLocation;
  StreamController<String> messageCountStreamController =
      StreamController.broadcast();

  updateCurrentLocation(Position value) => currentLocation = value;
  updateHoliday(String value) => upcomingHoliday.value = value;

  changeMessageCount(String value) {
    messageCountStreamController.add(value);
  }
}
