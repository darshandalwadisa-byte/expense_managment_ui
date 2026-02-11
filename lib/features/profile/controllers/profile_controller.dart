import 'package:expense/core/services/firestore_service.dart';
import 'package:expense/core/storage/app_storage.dart';
import 'package:expense/core/utils/app_logger.dart';
import 'package:expense/features/auth/services/auth_service.dart';
import 'package:get/get.dart';

// Helper extension for string if needed, or just handle inline
extension StringExtension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();

  final RxString userName = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userAvatar = ''.obs;
  final RxInt points = 4000.obs;
  final RxDouble walletBalance = 0.0.obs;
  final RxDouble transactionLimit = 200.0.obs;
  final RxBool isTransactionLimitEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    fetchWalletBalance();
  }

  void _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      // Load data from Firebase Auth
      userName.value = user.displayName ?? 'No Name';
      userEmail.value = user.email ?? 'No Email';

      try {
        // Fetch from Firestore
        final doc = await FirestoreService.userDoc().get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          userPhone.value = data['phone'] ?? '';
          userName.value = data['username'] ?? userName.value;
          // Note: We prioritize Firestore name if available, else Auth name
        } else {
          // Fallback to local storage or auth if no firestore doc
          userPhone.value =
              user.phoneNumber ??
              AppStorage.instance.userPhone.ifEmpty('No Phone');
        }
      } catch (e) {
        AppLogger.error('Error fetching user profile from Firestore: $e');
        // Fallback on error
        userPhone.value =
            user.phoneNumber ??
            AppStorage.instance.userPhone.ifEmpty('No Phone');
      }

      userAvatar.value = AppStorage.instance.userAvatarPath;

      // Load additional data from storage if available
      points.value = AppStorage.instance.userPoints;
      transactionLimit.value = AppStorage.instance.transactionLimit;
      isTransactionLimitEnabled.value =
          AppStorage.instance.isTransactionLimitEnabled;
    } else {
      AppLogger.warning('No user logged in');
    }
  }

  /// FETCH WALLET BALANCE (REAL-TIME)
  void fetchWalletBalance() {
    try {
      final uid = FirestoreService.uid;
      final path = 'users/$uid/wallet/main';
      AppLogger.info("Listening to wallet balance at: $path");

      FirestoreService.userDoc()
          .collection('wallet')
          .doc('main')
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists) {
              final data = snapshot.data();
              AppLogger.info("Snapshot found! Data: $data");
              walletBalance.value =
                  (data?['balance'] as num?)?.toDouble() ?? 0.0;
              AppLogger.info("Wallet balance updated: ${walletBalance.value}");
            } else {
              AppLogger.warning("Snapshot DOES NOT exist at: $path");
              // Temporary Debug Snackbar
              // Get.snackbar(
              //   "Debug: No Wallet Found",
              //   "Please Top Up to create wallet.\nPath: $path",
              //   snackPosition: SnackPosition.TOP,
              //   duration: const Duration(seconds: 10),
              //   backgroundColor: Colors.red,
              //   colorText: Colors.white,
              // );
            }
          }, onError: (e) {});
    } catch (e, s) {
      AppLogger.error("Error setting up wallet balance fetch", e, s);
    }
  }

  void refreshProfile() {
    _loadUserProfile();
  }

  void updateTransactionLimit(double limit) {
    transactionLimit.value = limit;
    AppStorage.instance.transactionLimit = limit;
    AppLogger.info("Transaction limit updated to: $limit");
  }

  void toggleTransactionLimit(bool isEnabled) {
    isTransactionLimitEnabled.value = isEnabled;
    AppStorage.instance.isTransactionLimitEnabled = isEnabled;
    AppLogger.info("Transaction limit enabled: $isEnabled");
  }

  void logout() async {
    try {
      await _authService.signOut();
      // Clear storage
      await AppStorage.instance.clearAll();

      Get.offAllNamed('/login');
    } catch (e) {
      AppLogger.error('Logout error: $e');
      Get.snackbar('Error', 'Failed to logout');
    }
  }
}
