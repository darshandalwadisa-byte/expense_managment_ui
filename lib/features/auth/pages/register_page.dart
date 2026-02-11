import 'package:expense/core/constants/app_strings.dart';
import 'package:expense/core/constants/app_images.dart';
import 'package:expense/core/theme/app_colors.dart';
import 'package:expense/core/theme/app_text_styles.dart';
import 'package:expense/features/auth/controller/register_controller.dart';
import 'package:expense/widgets/app_button.dart';
import 'package:expense/widgets/app_image_viewer.dart';
import 'package:expense/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();

    return Scaffold(
      backgroundColor: context.isDarkMode ? AppColors.black : AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and Title
                16.verticalSpace,
                _buildHeader(context),

                32.verticalSpace,

                // Username field
                _buildUsernameField(controller),

                20.verticalSpace,

                // Email field
                _buildEmailField(controller),

                20.verticalSpace,

                // Phone field
                _buildPhoneField(controller),

                20.verticalSpace,

                // Password field
                _buildPasswordField(controller),

                20.verticalSpace,

                // Confirm Password field
                _buildConfirmPasswordField(controller),

                16.verticalSpace,

                // Terms and conditions checkbox
                _buildTermsCheckbox(controller, context),

                32.verticalSpace,

                // Register button
                _buildRegisterButton(controller),

                20.verticalSpace,

                // Login link
                _buildLoginLink(controller, context),

                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header with back button and title
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20.sp,
              color: context.theme.iconTheme.color,
            ),
          ),
        ),

        // Title centered
        Expanded(
          child: Center(
            child: Text(
              AppStrings.registerTitle,
              style: AppTextStyles.titleLarge.copyWith(
                color: context.theme.textTheme.titleLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Spacer for symmetry
        SizedBox(width: 36.w),
      ],
    );
  }

  /// Build username input field
  Widget _buildUsernameField(RegisterController controller) {
    return Obx(
      () => AppTextField(
        label: AppStrings.usernameLabel,
        hint: AppStrings.usernameHint,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        showValidationIcon: true,
        isValid: controller.isUsernameValid.value,
        onChanged: controller.validateUsername,
        errorText: controller.usernameErrorText.value.isNotEmpty
            ? controller.usernameErrorText.value
            : null,
        suffixIcon: controller.isUsernameValid.value
            ? AppImageViewer(
                imagePath: AppImages.greentick,
                height: 22.sp,
                width: 22.sp,
              )
            : null,
      ),
    );
  }

  /// Build email input field
  Widget _buildEmailField(RegisterController controller) {
    return Obx(
      () => AppTextField(
        label: AppStrings.emailLabel,
        hint: AppStrings.emailHint,
        keyboardType: TextInputType.emailAddress,
        showValidationIcon: true,
        isValid: controller.isEmailValid.value,
        onChanged: controller.validateEmail,
        errorText: controller.emailErrorText.value.isNotEmpty
            ? controller.emailErrorText.value
            : null,
        suffixIcon: controller.isEmailValid.value
            ? AppImageViewer(
                imagePath: AppImages.greentick,
                height: 22.sp,
                width: 22.sp,
              )
            : null,
      ),
    );
  }

  /// Build phone input field
  Widget _buildPhoneField(RegisterController controller) {
    return Obx(
      () => AppTextField(
        label: AppStrings.phoneNumberLabel,
        hint: AppStrings.enterPhoneNumberHint,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        isPassword: false,
        prefixIcon: Container(
          width: 50.w,
          alignment: Alignment.center,
          child: Text(
            "+91",
            style: AppTextStyles.bodyLarge.copyWith(
              color: Get.theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        isValid: controller.isPhoneValid.value,
        onChanged: controller.validatePhone,
        errorText: controller.phoneErrorText.value.isNotEmpty
            ? controller.phoneErrorText.value
            : null,
        suffixIcon: controller.isPhoneValid.value
            ? AppImageViewer(
                imagePath: AppImages.greentick,
                height: 22.sp,
                width: 22.sp,
              )
            : null,
      ),
    );
  }

  /// Build password input field
  Widget _buildPasswordField(RegisterController controller) {
    return Obx(
      () => AppTextField(
        label: AppStrings.passwordLabel,
        hint: AppStrings.passwordHintShort,
        isPassword: true,
        maxLength: 8,
        onChanged: controller.validatePassword,
        errorText: controller.passwordErrorText.value.isNotEmpty
            ? controller.passwordErrorText.value
            : null,
      ),
    );
  }

  /// Build confirm password input field
  Widget _buildConfirmPasswordField(RegisterController controller) {
    return Obx(
      () => AppTextField(
        label: AppStrings.confirmPasswordLabel,
        hint: AppStrings.passwordHintShort,
        isPassword: true,
        maxLength: 8,
        onChanged: controller.validateConfirmPassword,
        errorText: controller.confirmPasswordErrorText.value.isNotEmpty
            ? controller.confirmPasswordErrorText.value
            : null,
      ),
    );
  }

  /// Build terms and conditions checkbox
  Widget _buildTermsCheckbox(
    RegisterController controller,
    BuildContext context,
  ) {
    return Obx(
      () => GestureDetector(
        onTap: controller.toggleAgreeToTerms,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: controller.agreeToTerms.value
                      ? AppColors.primary
                      : AppColors.borderNor,
                  width: 1.5.w,
                ),
                color: controller.agreeToTerms.value
                    ? AppColors.primary
                    : AppColors.transparent,
              ),
              child: controller.agreeToTerms.value
                  ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
                  : null,
            ),
            12.horizontalSpace,
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.theme.textTheme.bodySmall?.color,
                  ),
                  children: [
                    TextSpan(text: AppStrings.termsPart1),
                    TextSpan(
                      text: AppStrings.termsPart2,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.interactive,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build register button
  Widget _buildRegisterButton(RegisterController controller) {
    return Obx(
      () => AppButton(
        text: AppStrings.registerTitle,
        isLoading: controller.isLoading.value,
        onPressed: controller.register,
      ),
    );
  }

  /// Build login link
  Widget _buildLoginLink(RegisterController controller, BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.alreadyHaveAccount,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.theme.textTheme.bodyMedium?.color,
            ),
          ),
          GestureDetector(
            onTap: controller.goToLogin,
            child: Text(
              AppStrings.login,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.interactive,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
