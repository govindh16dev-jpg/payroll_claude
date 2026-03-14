import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'appTheme.dart';

class ThemeController extends GetxController {
  var selectedTheme = 0.obs;
  static const storage = FlutterSecureStorage();
  static const _themeKey = 'selected_theme_index';

  final _themes = [
    AppTheme(),
    AppThemeGreen(),
    AppThemeYellow(),
    AppThemeCoralRed(),
    AppThemeBlue(),
  ];

  dynamic get currentTheme => _themes[selectedTheme.value];

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  Future<void> _loadThemeFromStorage() async {
    String? indexStr = await storage.read(key: _themeKey);
    if (indexStr != null) {
      final index = int.tryParse(indexStr);
      if (index != null && index >= 0 && index < _themes.length) {
        selectedTheme.value = index;
        Get.changeTheme(currentTheme.lightTheme);
      }
    }
  }

  void changeTheme(int index) async {
    selectedTheme.value = index;
    await storage.write(key: _themeKey, value: index.toString());
    Get.changeTheme(currentTheme.lightTheme);
  }
}
