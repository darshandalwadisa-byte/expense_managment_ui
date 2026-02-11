import 'package:expense/core/localization/language_controller.dart';
import 'package:expense/core/localization/translations.dart';
import 'package:expense/core/theme/app_theme.dart';
import 'package:expense/core/theme/theme_controller.dart';
import 'package:expense/core/services/app_initializer.dart';
import 'package:expense/core/storage/app_storage.dart';
import 'package:expense/core/widgets/app_lock_wrapper.dart';
import 'package:expense/routes/app_named.dart';
import 'package:expense/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void main() async {
  await AppInitializer.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AppStorage.instance.isLoggedIn;
    final languageController = Get.find<LanguageController>();
    final themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Expense App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            translations: AppTranslations(),
            locale: languageController.locale,
            fallbackLocale: const Locale('en', 'US'),
            initialRoute: isLoggedIn ? AppNamed.menuPage : AppNamed.onboarding,
            getPages: AppRoutes.routes,
            builder: (context, child) => AppLockWrapper(child: child!),
          ),
        );
      },
    );
  }
}
