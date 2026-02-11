import 'package:expense/core/theme/app_text_styles.dart';
import 'package:expense/features/wallet/controllers/wallet_controller.dart';
import 'package:expense/features/wallet/models/card_model.dart';
import 'package:expense/features/shared/pages/transaction_success_page.dart';
import 'package:expense/routes/app_named.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopUpController extends GetxController {
  // Dependency on WalletController to get saved cards
  // We can find it because it should be alive in the app, or we can fetch it.
  // Ideally, WalletController handles card data. TopUpController handles TopUp logic.
  WalletController get walletController => _walletController;
  final WalletController _walletController = Get.find<WalletController>();

  List<CardModel> get savedCards => walletController.savedCards;

  // Top-up related state
  final RxInt selectedDenomination = 50.obs;
  final TextEditingController customAmountController = TextEditingController();
  final RxInt selectedCardIndex = 0.obs;

  // Selected Bank Balance
  double get selectedBankBalance {
    if (walletController.savedCards.isEmpty) return 0.0;
    if (selectedCardIndex.value >= walletController.savedCards.length) {
      return 0.0;
    }

    final card = walletController.savedCards[selectedCardIndex.value];
    final bankAccount = walletController.getBankAccountForCard(card.cardId);

    if (bankAccount == null) return 0.0;
    final balance = bankAccount['balance'];
    if (balance is int) return balance.toDouble();
    if (balance is double) return balance;
    return 0.0;
  }

  void selectDenomination(int amount) {
    selectedDenomination.value = amount;
    // For visual consistency/editing, we can show int string
    customAmountController.text = amount.toString();
  }

  Future<void> performTopUp() async {
    // Parse input as double first to allow flexibility, then cast to int for now
    // since topUp signature requires int. Or we'll fix WalletController later.
    // For now, let's assume we want integer top-ups from preset denominations.

    // Actually, user might type 50.50.
    // Let's parse as double.
    final doubleAmount = customAmountController.text.isNotEmpty
        ? double.tryParse(customAmountController.text.replaceAll(',', '')) ??
              selectedDenomination.value.toDouble()
        : selectedDenomination.value.toDouble();

    final int amount = doubleAmount.toInt(); // Truncate for now as per API

    if (savedCards.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add a card first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Verify balance
    if (selectedBankBalance < amount) {
      Get.snackbar(
        'Error',
        'Insufficient bank balance',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final card = savedCards[selectedCardIndex.value];
    final bankAccount = walletController.getBankAccountForCard(card.cardId);

    if (bankAccount == null) {
      Get.snackbar(
        'Error',
        'Bank account not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await walletController.topUp(bankId: bankAccount['id'], amount: amount);

      // Navigate to Success Page
      Get.toNamed(
        AppNamed.transactionSuccess,
        arguments: TransactionSuccessArgs(
          type: TransactionType.topUp,
          amount: amount.toString(),
          recipientName: card.bankName,
          recipientInfo: "**** **** **** ${card.last4 ?? ''}",
        ),
      );

      // Reset the custom amount
      customAmountController.clear();
      selectedDenomination.value = 50;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void changeBank() {
    if (savedCards.isEmpty) return;

    Get.bottomSheet(
      Container(
        color: Theme.of(Get.context!).cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Select Bank'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: savedCards.length,
                itemBuilder: (context, index) {
                  final card = savedCards[index];
                  return ListTile(
                    leading: const Icon(Icons.credit_card),
                    title: Text(
                      card.bankName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      '**** **** ****  ${card.last4}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    onTap: () {
                      selectedCardIndex.value = index;
                      Get.back();
                    },
                    selected: index == selectedCardIndex.value,
                    trailing: index == selectedCardIndex.value
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  void onClose() {
    customAmountController.dispose();
    super.onClose();
  }
}
