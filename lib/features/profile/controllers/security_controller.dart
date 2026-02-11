import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:expense/core/services/firestore_service.dart';
import 'package:expense/core/storage/app_storage.dart';
import 'package:expense/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SecurityController extends GetxController with WidgetsBindingObserver {
  // Rx Variables
  final RxBool isAutoLockEnabled = false.obs;
  final RxInt autoLockTimeout = 120.obs; // Default 2 minutes
  final RxString pinHash = ''.obs;
  final RxBool isLocked = false.obs;

  Timer? _inactivityTimer;
  DateTime? _backgroundTime;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Check auto-lock status synchronously to lock ASAP
    if (AppStorage.instance.isAutoLockEnabled) {
      isLocked.value = true;
    }

    _loadSettings();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isAutoLockEnabled.value) return;

    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
      _inactivityTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final duration = DateTime.now().difference(_backgroundTime!);
        if (duration.inSeconds >= autoLockTimeout.value) {
          lockApp();
        }
      }
      resetInactivityTimer();
    }
  }

  void _loadSettings() async {
    // Load settings from local storage
    isAutoLockEnabled.value = AppStorage.instance.isAutoLockEnabled;
    autoLockTimeout.value = AppStorage.instance.lockTimeout;
    pinHash.value = AppStorage.instance.pinHash;

    // If enabled, lock initially on app start
    if (isAutoLockEnabled.value) {
      lockApp();
    }

    // Then sync from Firestore
    try {
      final doc = await FirestoreService.userDoc().get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        isAutoLockEnabled.value =
            data['isAppAutoLockEnabled'] ?? isAutoLockEnabled.value;
        autoLockTimeout.value = data['appLockTimeout'] ?? autoLockTimeout.value;
        pinHash.value = data['appLockPinHash'] ?? pinHash.value;

        // Update local storage
        AppStorage.instance.isAutoLockEnabled = isAutoLockEnabled.value;
        AppStorage.instance.lockTimeout = autoLockTimeout.value;
        AppStorage.instance.pinHash = pinHash.value;
      }
    } catch (e) {
      AppLogger.error('Error syncing security settings from Firestore: $e');
    }
  }

  void resetInactivityTimer() {
    if (!isAutoLockEnabled.value || isLocked.value) return;

    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: autoLockTimeout.value), () {
      lockApp();
    });
  }

  void lockApp() {
    if (!isAutoLockEnabled.value) return;
    isLocked.value = true;
    AppLogger.info('App Locked');
  }

  void unlockApp() {
    isLocked.value = false;
    resetInactivityTimer();
    AppLogger.info('App Unlocked');
  }

  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    pinHash.value = hash;
    isAutoLockEnabled.value = true;

    // Save locally
    AppStorage.instance.pinHash = hash;
    AppStorage.instance.isAutoLockEnabled = true;

    // Save to Firestore
    try {
      await FirestoreService.userDoc().update({
        'appLockPinHash': hash,
        'isAppAutoLockEnabled': true,
        'appLockTimeout': autoLockTimeout.value,
      });
    } catch (e) {
      AppLogger.error('Error saving PIN to Firestore: $e');
    }
  }

  bool verifyPin(String pin) {
    final hash = _hashPin(pin);
    if (hash == pinHash.value) {
      unlockApp();
      return true;
    }
    return false;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  void updateTimeout(int seconds) async {
    autoLockSecondsUpdate(seconds);
  }

  void autoLockSecondsUpdate(int seconds) async {
    autoLockTimeout.value = seconds;
    AppStorage.instance.lockTimeout = seconds;
    resetInactivityTimer();

    try {
      await FirestoreService.userDoc().update({'appLockTimeout': seconds});
    } catch (e) {
      AppLogger.error('Error updating timeout to Firestore: $e');
    }
  }

  void toggleAutoLock(bool value) async {
    if (value && pinHash.value.isEmpty) {
      // Need to setup PIN first - caller should handle navigation
      return;
    }

    isAutoLockEnabled.value = value;
    AppStorage.instance.isAutoLockEnabled = value;

    if (value) {
      resetInactivityTimer();
    } else {
      _inactivityTimer?.cancel();
      isLocked.value = false;
    }

    try {
      await FirestoreService.userDoc().update({'isAppAutoLockEnabled': value});
    } catch (e) {
      AppLogger.error('Error toggling auto-lock in Firestore: $e');
    }
  }
}
