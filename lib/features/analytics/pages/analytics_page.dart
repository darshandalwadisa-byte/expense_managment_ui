import 'package:expense/core/constants/app_images.dart';
import 'package:expense/core/constants/app_strings.dart';

import 'package:expense/core/theme/app_text_styles.dart';
import 'package:expense/core/widgets/empty_state_widget.dart';
import 'package:expense/features/analytics/controller/analytics_controller.dart';
import 'package:expense/features/analytics/widgets/analytics_bar_chart_widget.dart';
import 'package:expense/features/analytics/widgets/summary_card_widget.dart';
import 'package:expense/features/analytics/widgets/time_filter_tabs_widget.dart';
import 'package:expense/features/analytics/widgets/trading_history_item_widget.dart';
import 'package:expense/routes/app_named.dart';
import 'package:expense/widgets/app_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AnalyticsPage extends GetView<AnalyticsController> {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.theme.iconTheme.color,
            size: 20.r,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.analyticsTitle,
          style: AppTextStyles.titleLarge.copyWith(
            color: context.theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Get.toNamed(AppNamed.shareAnalysis);
            },
            child: AppImageViewer(imagePath: AppImages.shareIcon),
          ),
          SizedBox(width: 20.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income & Outcome Summary Cards
            Container(
              decoration: BoxDecoration(color: context.theme.cardColor),
              child: _buildSummaryCardsSection(),
            ),
            SizedBox(height: 8.h),
            // Time Filter Tabs
            Obx(() {
              // Show loading state if data is loading
              if (controller.isLoading.value) {
                return SizedBox(
                  height: 300.h,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              // Show empty state if no transactions
              if (controller.transactions.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  color: context.theme.cardColor,
                  child: const EmptyStateWidget(
                    imagePath: AppImages.onboardingImage1,
                    message: "No transactions found",
                    subMessage: "Your transaction history will appear here.",
                  ),
                );
              }

              // Show filter and chart if data exists
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(color: context.theme.cardColor),
                    child: const TimeFilterTabsWidget(),
                  ),
                  Container(
                    decoration: BoxDecoration(color: context.theme.cardColor),
                    child: const AnalyticsBarChartWidget(),
                  ),
                ],
              );
            }),
            SizedBox(height: 8.h),
            // Trading History Section
            Container(
              decoration: BoxDecoration(color: context.theme.cardColor),
              child: _buildTradingHistorySection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardsSection() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Expanded(
              child: SummaryCardWidget(
                label: AppStrings.incomeLabel,
                amount: '\$${controller.totalIncome.value.toStringAsFixed(2)}',
                isIncome: true,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: SummaryCardWidget(
                label: AppStrings.outcomeLabel,
                amount: '\$${controller.totalOutcome.value.toStringAsFixed(2)}',
                isIncome: false,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTradingHistorySection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.tradingHistory,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.sp,
                  color: context.theme.textTheme.bodyLarge?.color,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(AppNamed.allTransactions);
                },
                child: Text(
                  AppStrings.viewAll,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final transactions = controller.transactions;
            if (transactions.isEmpty) {
              return const EmptyStateWidget(
                imagePath: AppImages
                    .onboardingImage1, // Using a placeholder for now, ideally specific empty state image
                message: "No transactions found",
                subMessage: "Your transaction history will appear here.",
              );
            }

            // Show top 5
            final top5 = transactions.take(5).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: top5.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final transaction = top5[index];
                return TradingHistoryItemWidget(
                  icon: transaction.icon,
                  title: transaction.title,
                  status: transaction.status,
                  amount: transaction.amount,
                  date: transaction.date,
                  isExpense: transaction.isExpense,
                  onTap: () {
                    Get.toNamed(AppNamed.shareBill);
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
