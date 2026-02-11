import 'package:expense/core/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static ThemeController get instance => Get.find();

  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _isDarkMode.value = AppStorage.instance.isDarkMode;
  }

  /// Get the current theme mode from storage
  ThemeMode get themeMode {
    if (isDarkMode) {
      return ThemeMode.dark;
    }
    return ThemeMode.light;
  }

  /// Switch the theme and save the preference
  void toggleTheme() {
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
      _isDarkMode.value = false;
      AppStorage.instance.isDarkMode = false;
    } else {
      Get.changeThemeMode(ThemeMode.dark);
      _isDarkMode.value = true;
      AppStorage.instance.isDarkMode = true;
    }
  }
}
