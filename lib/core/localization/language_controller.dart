import 'package:expense/core/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  // Supported Locales
  static const List<Map<String, dynamic>> locales = [
    {'name': 'English', 'locale': Locale('en', 'US')},
    {'name': 'हिंदी', 'locale': Locale('hi', 'IN')},
    {'name': 'ગુજરાતી', 'locale': Locale('gu', 'IN')},
  ];

  Locale get locale {
    String? langCode = AppStorage.instance.language;
    if (langCode.isNotEmpty) {
      if (langCode == 'hi_IN') return const Locale('hi', 'IN');
      if (langCode == 'gu_IN') return const Locale('gu', 'IN');
    }
    return Get.deviceLocale ?? const Locale('en', 'US');
  }

  void changeLanguage(Locale locale) {
    Get.updateLocale(locale);
    AppStorage.instance.language =
        '${locale.languageCode}_${locale.countryCode}';
    update();
  }

  String get currentLanguageName {
    Locale active = locale;
    for (var item in locales) {
      Locale l = item['locale'];
      if (l.languageCode == active.languageCode &&
          l.countryCode == active.countryCode) {
        return item['name'];
      }
    }
    return 'English';
  }
}
