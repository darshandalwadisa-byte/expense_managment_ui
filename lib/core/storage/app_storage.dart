import 'package:get_storage/get_storage.dart';

class AppStorage {
  AppStorage._();
  static final AppStorage instance = AppStorage._();

  final GetStorage _box = GetStorage();

  // =====================
  // AUTH
  // =====================

  static const _isLoggedIn = 'isLoggedIn';
  static const _userEmail = 'userEmail';
  static const _username = 'username';
  static const _userPhone = 'userPhone';

  bool get isLoggedIn => _box.read(_isLoggedIn) ?? false;
  set isLoggedIn(bool value) => _box.write(_isLoggedIn, value);

  String get userEmail => _box.read(_userEmail) ?? '';
  set userEmail(String value) => _box.write(_userEmail, value);

  String get username => _box.read(_username) ?? '';
  set username(String value) => _box.write(_username, value);

  String get userPhone => _box.read(_userPhone) ?? '';
  set userPhone(String value) => _box.write(_userPhone, value);

  // =====================
  // THEME
  // =====================

  static const _isDarkMode =
      'isDarkMode'; // Matches private key in ThemeController

  bool get isDarkMode => _box.read(_isDarkMode) ?? false;
  set isDarkMode(bool value) => _box.write(_isDarkMode, value);

  // =====================
  // LANGUAGE
  // =====================

  static const _language = 'language';

  String get language => _box.read(_language) ?? 'en_US';
  set language(String value) => _box.write(_language, value);

  // =====================
  // SECURITY
  // =====================

  static const _pinHash = 'appLockPinHash';
  static const _isAutoLockEnabled = 'isAppAutoLockEnabled';
  static const _timeout = 'appLockTimeout';

  String get pinHash => _box.read(_pinHash) ?? '';
  set pinHash(String value) => _box.write(_pinHash, value);

  bool get isAutoLockEnabled => _box.read(_isAutoLockEnabled) ?? false;
  set isAutoLockEnabled(bool value) => _box.write(_isAutoLockEnabled, value);

  int get lockTimeout =>
      _box.read(_timeout) ?? 120; // Default matched SecurityController
  set lockTimeout(int value) => _box.write(_timeout, value);

  // =====================
  // PROFILE & SETTINGS
  // =====================
  static const _userAvatarPath = 'userAvatarPath';
  static const _transactionLimit = 'transactionLimit';
  static const _isTransactionLimitEnabled = 'isTransactionLimitEnabled';
  static const _userPoints = 'userPoints';

  String get userAvatarPath => _box.read(_userAvatarPath) ?? '';
  set userAvatarPath(String value) => _box.write(_userAvatarPath, value);

  double get transactionLimit => _box.read(_transactionLimit) ?? 200.0;
  set transactionLimit(double value) => _box.write(_transactionLimit, value);

  bool get isTransactionLimitEnabled =>
      _box.read(_isTransactionLimitEnabled) ?? true;
  set isTransactionLimitEnabled(bool value) =>
      _box.write(_isTransactionLimitEnabled, value);

  int get userPoints => _box.read(_userPoints) ?? 4000;
  set userPoints(int value) => _box.write(_userPoints, value);

  // =====================
  // CLEAR
  // =====================

  Future<void> clearAll() async {
    await _box.erase();
    // Re-initialize defaults if necessary, or let them be handled by getters
  }
}
