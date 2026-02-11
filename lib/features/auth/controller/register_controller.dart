import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense/core/storage/app_storage.dart';
import 'package:expense/core/utils/app_snackbars.dart';
import 'package:expense/features/auth/services/auth_service.dart';
import 'package:expense/routes/app_named.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final AuthService _authService = AuthService();

  // Username field
  final usernameController = ''.obs;
  final isUsernameValid = false.obs;
  final usernameErrorText = ''.obs;

  // Email field
  final emailController = ''.obs;
  final isEmailValid = false.obs;
  final emailErrorText = ''.obs;

  // Phone field
  final phoneController = ''.obs;
  final isPhoneValid = false.obs;
  final phoneErrorText = ''.obs;

  // Password field
  final passwordController = ''.obs;
  final isPasswordVisible = false.obs;
  final passwordErrorText = ''.obs;

  // Confirm password field
  final confirmPasswordController = ''.obs;
  final isConfirmPasswordVisible = false.obs;
  final confirmPasswordErrorText = ''.obs;

  // Terms and conditions checkbox
  final agreeToTerms = false.obs;

  // Loading state
  final isLoading = false.obs;

  /// Validates username (minimum 3 characters)
  void validateUsername(String value) {
    usernameController.value = value;
    if (value.isEmpty) {
      isUsernameValid.value = false;
      usernameErrorText.value = 'Username is required';
    } else {
      isUsernameValid.value = true;
      usernameErrorText.value = '';
    }
  }

  /// Validates email
  void validateEmail(String value) {
    emailController.value = value;
    if (value.isEmpty) {
      isEmailValid.value = false;
      emailErrorText.value = 'Email is required';
    } else if (!GetUtils.isEmail(value)) {
      isEmailValid.value = false;
      emailErrorText.value = 'Please enter a valid email';
    } else {
      isEmailValid.value = true;
      emailErrorText.value = '';
    }
  }

  /// Validates phone number
  void validatePhone(String value) {
    phoneController.value = value;
    if (value.isEmpty) {
      isPhoneValid.value = false;
      phoneErrorText.value = 'Phone number is required';
    } else if (value.length < 10) {
      isPhoneValid.value = false;
      phoneErrorText.value = 'Please enter a valid phone number';
    } else {
      isPhoneValid.value = true;
      phoneErrorText.value = '';
    }
  }

  /// Validates password
  void validatePassword(String value) {
    passwordController.value = value;
    if (value.isEmpty) {
      passwordErrorText.value = 'Password is required';
    } else if (value.length < 6) {
      passwordErrorText.value = 'Password must be 8 characters';
    } else {
      passwordErrorText.value = '';
    }
    // Re-validate confirm password when password changes
    if (confirmPasswordController.value.isNotEmpty) {
      validateConfirmPassword(confirmPasswordController.value);
    }
  }

  /// Validates confirm password
  void validateConfirmPassword(String value) {
    confirmPasswordController.value = value;
    if (value.isEmpty) {
      confirmPasswordErrorText.value = 'Confirm password is required';
    } else if (value != passwordController.value) {
      confirmPasswordErrorText.value = 'Passwords do not match';
    } else {
      confirmPasswordErrorText.value = '';
    }
  }

  void validateAgreeToTerms() {
    agreeToTerms.value
        ? null
        : AppSnackbars.showError(
            title: 'Error',
            message: 'Please accept the Terms & Conditions to continue.',
          );
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Toggle terms and conditions checkbox
  void toggleAgreeToTerms() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  /// Check if password is valid
  bool get isPasswordValid => passwordController.value.length >= 6;

  /// Check if passwords match
  bool get doPasswordsMatch =>
      passwordController.value == confirmPasswordController.value &&
      confirmPasswordController.value.isNotEmpty;

  /// Check if form is valid
  bool get isFormValid =>
      isUsernameValid.value &&
      isEmailValid.value &&
      isPhoneValid.value &&
      isPasswordValid &&
      doPasswordsMatch &&
      agreeToTerms.value;

  /// Validates all fields - call this on button tap
  void validateAllFields() {
    validateUsername(usernameController.value);
    validateEmail(emailController.value);
    validatePhone(phoneController.value);
    validatePassword(passwordController.value);
    validateConfirmPassword(confirmPasswordController.value);
    validateAgreeToTerms();
  }

  /// Handle register
  Future<void> register() async {
    // Validate all fields first to show all errors
    validateAllFields();

    if (!isFormValid) return;

    isLoading.value = true;

    try {
      FocusManager.instance.primaryFocus?.unfocus();
      final credential = await _authService.signUpWithEmail(
        email: emailController.value.trim(),
        password: passwordController.value,
      );

      // Update display name
      await credential.user?.updateDisplayName(usernameController.value);

      // Store phone number in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user?.uid)
          .set({
            'phone': "+91 ${phoneController.value.trim()}",
            'username': usernameController.value.trim(),
            'email': emailController.value.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Save login state
      AppStorage.instance.isLoggedIn = true;
      AppStorage.instance.userEmail = emailController.value.trim();
      AppStorage.instance.username = usernameController.value.trim();
      AppSnackbars.showSuccess(
        title: 'Success',
        message: 'Registration Completed successful',
      );
      Get.offAllNamed(AppNamed.signupSuccess);
    } catch (e) {
      AppSnackbars.showError(title: 'Error', message: 'Registration failed');
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.back();
  }
}
