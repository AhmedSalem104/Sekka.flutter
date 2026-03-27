import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/cash_status_entity.dart';

class CashStatusBar extends StatelessWidget {
  const CashStatusBar({
    super.key,
    required this.status,
    this.onSettleTap,
  });

  final CashStatusEntity status;
  final VoidCallback? onSettleTap;

  Color get _progressColor {
    if (status.isSafe) return AppColors.success;
    if (status.isWarning) return AppColors.warning;
    if (status.isDanger) return AppColors.error;
    return AppColors.error;
  }

  String get _statusText {
    if (status.isSafe) return AppStrings.cashStatusSafe;
    if (status.isWarning) return AppStrings.cashStatusWarning;
    if (status.isDanger) return AppStrings.cashStatusDanger;
    return AppStrings.cashStatusCritical;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    final progress = (status.percentage / 100).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                IconsaxPlusLinear.wallet_2,
                size: AppSizes.iconMd,
                color: _progressColor,
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  _statusText,
                  style: AppTypography.bodySmall.copyWith(
                    color: _progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onSettleTap != null)
                GestureDetector(
                  onTap: onSettleTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Text(
                      AppStrings.newSettlement,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  isDark ? AppColors.borderDark : AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
