import 'dart:io';
import 'package:expense/core/constants/app_strings.dart';
import 'package:expense/core/theme/app_colors.dart';
import 'package:expense/core/theme/app_text_styles.dart';
import 'package:expense/features/profile/controllers/edit_profile_controller.dart';
import 'package:expense/widgets/app_button.dart';
import 'package:expense/widgets/labeled_input_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).iconTheme.color,
            size: 20.r,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          AppStrings.editProfileTitle,
          style: AppTextStyles.titleLarge.copyWith(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar
            Container(
              color: Theme.of(context).cardColor,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Obx(
                    () => GestureDetector(
                      onTap: controller.pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                              image: _getAvatarImage(),
                            ),
                            child: _getAvatarImage() == null
                                ? Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 50.r,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : null,
                          ),
                          // Camera icon overlay
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).cardColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 16.r,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          // Upload loading indicator
                          if (controller.isUploadingImage.value)
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Form Fields
            LabeledInputTile(
              title: AppStrings.usernameLabel,
              controller: controller.nameController,
            ),
            SizedBox(height: 8.h),
            LabeledInputTile(
              title: AppStrings.phoneNumberLabel,
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              readOnly: true,
            ),
            SizedBox(height: 8.h),
            LabeledInputTile(
              title: AppStrings.emailLabel,
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ),
            SizedBox(height: 40.h),

            // Save Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SizedBox(
                width: double.infinity,
                child: Obx(
                  () => AppButton(
                    text: AppStrings.saveChangeBtn,
                    onPressed: controller.saveChanges,
                    isLoading: controller.isUploadingImage.value,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// Get avatar image decoration
  DecorationImage? _getAvatarImage() {
    // Show selected image first
    if (controller.selectedImage.value != null) {
      return DecorationImage(
        image: FileImage(controller.selectedImage.value!),
        fit: BoxFit.cover,
      );
    }

    // Show existing avatar from profile
    final avatarPath = controller.profileController.userAvatar.value;
    if (avatarPath.isNotEmpty) {
      ImageProvider? imageProvider;

      if (avatarPath.startsWith('http')) {
        imageProvider = NetworkImage(avatarPath);
      } else {
        final file = File(avatarPath);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
        }
      }

      if (imageProvider != null) {
        return DecorationImage(image: imageProvider, fit: BoxFit.cover);
      }
    }

    return null;
  }
}
