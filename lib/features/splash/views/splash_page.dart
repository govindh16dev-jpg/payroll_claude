import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/splash_page_controller.dart';

class SplashPage extends GetView<SplashPageController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child:
            Image.asset(
            height: 55, width: 55, 'assets/logos/app_icon.png'),
            ));
  }
}
