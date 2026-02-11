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

class SignupSuccessfulPage extends StatelessWidget {
  const SignupSuccessfulPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              // Back button
              16.verticalSpace,
              const Spacer(flex: 2),

              // Illustration
              Center(
                child: AppImageViewer(
                  imagePath: AppImages.signUpSucessfullImage,
                  height: 250.h,
                  fit: BoxFit.contain,
                ),
              ),

              40.verticalSpace,

              // Success title
              Text(
                AppStrings.signupSuccessfulTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: context.theme.textTheme.headlineSmall?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),

              12.verticalSpace,

              // Success subtitle
              Text(
                AppStrings.signupSuccessfulMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.theme.textTheme.bodyMedium?.color,
                ),
              ),

              const Spacer(flex: 3),

              // Done button
              AppButton(
                text: AppStrings.doneBtn,
                onPressed: () {
                  // Navigate to login or home
                  Get.offAllNamed(AppNamed.menuPage);
                },
              ),

              40.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  /// Build back button
}
