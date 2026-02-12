import 'package:expense/core/theme/app_colors.dart';
import 'package:expense/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummaryCardWidget extends StatelessWidget {
  final String label;
  final String amount;
  final bool isIncome;

  const SummaryCardWidget({
    super.key,
    required this.label,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isIncome ? AppColors.success : AppColors.critical;

    return FittedBox(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(12.r),
              ),

              child: Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: iconColor,
                size: 20.r,
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                FittedBox(
                  child: Text(
                    amount,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: iconColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
