import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/common/bottom_nav.dart';
import '../../homepage/views/home_page.dart';
import '../controller/main_page_controller.dart';

class MainPage extends GetView<MainPageController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          resizeToAvoidBottomInset: false,
          drawerEnableOpenDragGesture: false,
          floatingActionButton:CustomBottomNaviBar(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.startFloat,
          body: IndexedStack(
            index: controller.selectedIndex.value,
            children:   [
              HomePage(),


              // LeavePage(
              //   fromHome: false,
              // )
            ],
          ),
        ));
  }
}

