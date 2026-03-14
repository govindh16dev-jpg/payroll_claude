import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:payroll/features/login/domain/model/login_model.dart';

import '../../../routes/app_pages.dart';

class MainPageController extends GetxController {
  var loading = Loading.initial.obs;

  final appStateController = Get.put(AppStates());
  UserData userData = UserData();
  RxInt selectedIndex = 0.obs;
  
  Future<UserData>? getUserData() async {
    const storage = FlutterSecureStorage();
    final String? userDataLocal = await storage.read(key: PrefStrings.userData);
    if (userDataLocal != null) {
      userData = userDataFromJson(userDataLocal);
      appStateController.userData.value=userData;
    }

    return userData;
  }

  @override
  void onReady() {
    getUserData()?.then((v) {
      // fetchProfileData();
    });

    super.onReady();
  }
  @override
  void dispose() {
    Get.delete<MainPageController>();
    super.dispose();
  }
}
