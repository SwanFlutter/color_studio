import 'package:flutter/material.dart';
import 'package:get_x_master/get_x_master.dart';
import 'package:get_x_storage/get_x_storage.dart';

enum AvailableTheme { light, dark, system }

class ThemeController extends GetXController {
  var appThemeMode = AvailableTheme.system.obs;
  final _storage = GetXStorage();

  @override
  void onInit() {
    super.onInit();
    // خواندن مقدار ذخیره شده (درصورت وجود)
    String? savedTheme = _storage.read(key: 'theme');
    if (savedTheme != null) {
      // فقط مقدار داخلی را ست کن؛ تم اولیه در main تنظیم شده
      switch (savedTheme) {
        case 'light':
          appThemeMode.value = AvailableTheme.light;
          break;
        case 'dark':
          appThemeMode.value = AvailableTheme.dark;
          break;
        default:
          appThemeMode.value = AvailableTheme.system;
      }
    }
  }

  void setLight() {
    appThemeMode.value = AvailableTheme.light;
    Get.changeThemeMode(ThemeMode.light);
    _storage.write(key: 'theme', value: 'light'); // ذخیره در حافظه
  }

  void setDark() {
    appThemeMode.value = AvailableTheme.dark;
    Get.changeThemeMode(ThemeMode.dark);
    _storage.write(key: 'theme', value: 'dark');
  }

  void setSystem() {
    appThemeMode.value = AvailableTheme.system;
    Get.changeThemeMode(ThemeMode.system);
    _storage.write(key: 'theme', value: 'system');
  }

  void toggleTheme() {
    if (appThemeMode.value == AvailableTheme.light) {
      setDark();
    } else {
      setLight();
    }
  }
}
