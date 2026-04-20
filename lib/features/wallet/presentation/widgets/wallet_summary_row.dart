import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/wallet_summary_entity.dart';

class WalletSummaryRow extends StatelessWidget {
  const WalletSummaryRow({super.key, required this.summary});

  final WalletSummaryEntity summary;

  String _format(double v) => NumberFormat('#,##0', AppStrings.currentLang == 'ar' ? 'ar_EG' : 'en_US').format(v);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryTile(
          icon: IconsaxPlusLinear.money_recive,
          label: AppStrings.incomeFilter,
          value: _format(summary.totalIncome),
          color: AppColors.success,
        ),
        SizedBox(width: AppSizes.sm),
        _SummaryTile(
          icon: IconsaxPlusLinear.money_send,
          label: AppStrings.expenseFilter,
          value: _format(summary.totalExpenses),
          color: AppColors.error,
        ),
        SizedBox(width: AppSizes.sm),
        _SummaryTile(
          icon: IconsaxPlusLinear.arrange_circle_2,
          label: AppStrings.settlementsFilter,
          value: _format(summary.totalSettlements),
          color: AppColors.info,
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSizes.iconMd),
            SizedBox(height: AppSizes.xs),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
