import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:payroll/features/mainpage/controller/main_page_controller.dart';
import 'package:payroll/routes/app_route.dart';
import 'package:payroll/theme/theme_controller.dart';
import 'package:sizer/sizer.dart';

import 'features/login/controller/login_page_controller.dart';
import 'routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = false;
    Get.put(NetworkService());
    Get.put(ProgressService());
    Get.put(LoginPageController());
    Get.put(MainPageController());
    const storage = FlutterSecureStorage();
    isLoggedIn = await storage.read(key: PrefStrings.accessToken) != null;
    return isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    var appTheme = Get.find<ThemeController>().currentTheme;
    return Sizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute:   AppRoutes.splashPage,
          getPages: AppPages.pages,
          theme: appTheme.lightTheme,
        );
      },
    );
  }
}

