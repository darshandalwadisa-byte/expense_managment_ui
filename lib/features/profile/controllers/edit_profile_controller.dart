import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:expense/core/services/firestore_service.dart';
import 'package:expense/core/storage/app_storage.dart';
import 'package:expense/core/utils/app_snackbars.dart';
import 'package:expense/features/auth/services/auth_service.dart';
import 'package:expense/features/profile/controllers/profile_controller.dart';
import 'package:expense/features/profile/services/image_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final ProfileController profileController = Get.find<ProfileController>();
  final AuthService _authService = AuthService();
  final ImageStorageService _imageStorageService = ImageStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(
      text: profileController.userName.value,
    );
    phoneController = TextEditingController(
      text: profileController.userPhone.value,
    );
    emailController = TextEditingController(
      text: profileController.userEmail.value,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      AppSnackbars.showError(title: "Error", message: "Failed to pick image");
    }
  }

  Future<void> saveChanges() async {
    try {
      bool imageUpdated = false;
      bool infoUpdated = false;

      // Upload image first if selected
      if (selectedImage.value != null) {
        isUploadingImage.value = true;
        final userId = _authService.currentUser?.uid;

        if (userId != null) {
          try {
            debugPrint('Starting local image save for user: $userId');
            final imagePath = await _imageStorageService.uploadProfileImage(
              selectedImage.value!,
              userId,
            );
            debugPrint('Image saved locally. Path: $imagePath');

            // Save path to AppStorage
            AppStorage.instance.userAvatarPath = imagePath;
            profileController.userAvatar.value = imagePath;
            debugPrint('Profile photo path saved to storage');
            imageUpdated = true;
          } catch (e) {
            debugPrint('Image save error: $e');
            AppSnackbars.showError(
              title: "Upload Failed",
              message: "Failed to upload profile photo",
            );
            isUploadingImage.value = false;
            return; // Stop execution if image save fails
          }
        } else {
          AppSnackbars.showError(title: "Error", message: "User not logged in");
          isUploadingImage.value = false;
          return;
        }
        isUploadingImage.value = false;
      }

      // Update display name in Firebase if changed
      if (nameController.text != profileController.userName.value) {
        await _authService.updateDisplayName(nameController.text);

        // Also update in Firestore
        await FirestoreService.userDoc().set({
          'username': nameController.text,
        }, SetOptions(merge: true));

        profileController.userName.value = nameController.text;
        AppStorage.instance.username = nameController.text;
        infoUpdated = true;
      }

      // Refresh profile to reflect changes
      profileController.refreshProfile();

      Get.back();

      if (imageUpdated || infoUpdated) {
        String message = "Profile updated successfully";
        if (imageUpdated && !infoUpdated) {
          message = "Profile photo updated successfully";
        }

        AppSnackbars.showSuccess(title: "Success", message: message);
      }
    } catch (e) {
      debugPrint('Save changes error: $e');
      AppSnackbars.showError(
        title: "Error",
        message: "Failed to update profile: $e",
      );
    }
  }
}
