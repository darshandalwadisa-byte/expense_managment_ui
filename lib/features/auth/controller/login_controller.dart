import 'package:expense/core/storage/app_storage.dart';
import 'package:expense/core/utils/app_snackbars.dart';
import 'package:expense/features/auth/services/auth_service.dart';
import 'package:expense/routes/app_named.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  // Email field
  final emailController = ''.obs;
  final isEmailValid = false.obs;
  final emailErrorText = ''.obs;

  // Password field
  final passwordController = ''.obs;
  final passwordErrorText = ''.obs;

  // Save password checkbox
  final savePassword = false.obs;

  // Loading state
  final isLoading = false.obs;

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

  /// Validates password
  void validatePassword(String value) {
    passwordController.value = value;
    if (value.isEmpty) {
      passwordErrorText.value = 'Password is required';
    } else if (value.length < 8) {
      passwordErrorText.value = 'Password must be at least 8 characters';
    } else {
      passwordErrorText.value = '';
    }
  }

  /// Validates password (minimum 6 characters for Firebase)
  bool get isPasswordValid => passwordController.value.length >= 6;

  /// Toggle save password checkbox
  void toggleSavePassword() {
    savePassword.value = !savePassword.value;
  }

  /// Check if form is valid
  bool get isFormValid => isEmailValid.value && isPasswordValid;

  /// Validates all fields - call this on button tap
  void validateAllFields() {
    validateEmail(emailController.value);
    validatePassword(passwordController.value);
  }

  /// Handle login
  Future<void> login() async {
    // Validate all fields first to show all errors
    validateAllFields();

    if (!isFormValid) return;

    isLoading.value = true;

    try {
      FocusManager.instance.primaryFocus?.unfocus();

      await _authService.signInWithEmail(
        email: emailController.value.trim(),
        password: passwordController.value,
      );

      // Save login state using AppStorage
      AppStorage.instance.isLoggedIn = true;
      AppStorage.instance.userEmail = emailController.value.trim();
      AppSnackbars.showSuccess(
        title: 'Success',
        message: 'Logged in successfully',
      );
      Get.offAllNamed(AppNamed.menuPage);
    } catch (e) {
      AppSnackbars.showError(
        title: 'Error',
        message: 'Please enter valid email and password',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to forgot password
  void goToForgotPassword() {
    Get.toNamed(AppNamed.forgotPassword);
  }

  /// Navigate to sign up
  void goToSignUp() {
    Get.toNamed(AppNamed.register);
  }
}
