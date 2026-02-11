import 'package:expense/core/constants/app_strings.dart';
import 'package:expense/core/constants/app_images.dart';

import 'package:expense/core/theme/app_colors.dart';
import 'package:expense/core/theme/app_text_styles.dart';
import 'package:expense/routes/app_named.dart';
import 'package:expense/widgets/app_button.dart';
import 'package:expense/widgets/app_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                // Top spacing
                40.verticalSpace,
                Center(
                  child: AppImageViewer(
                    imagePath: AppImages.onboardingImage1,
                    height: 350.h,
                    fit: BoxFit.contain,
                  ),
                ),

                40.verticalSpace,

                // Content section
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppImageViewer(
                      imagePath: AppImages.appLogo,
                      height: 90.h,
                      width: 90.w,
                    ),

                    20.verticalSpace,

                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: context.theme.textTheme.headlineSmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    12.verticalSpace,

                    Text(
                      AppStrings.onboardingMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),

                48.verticalSpace,

                // Bottom button
                AppButton(
                  text: AppStrings.getStartedBtn,
                  onPressed: () => Get.toNamed(AppNamed.login),
                ),

                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
