import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/profile_stats_entity.dart';

class ProfileStatsSummary extends StatelessWidget {
  const ProfileStatsSummary({
    super.key,
    required this.stats,
  });

  final ProfileStatsEntity stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _StatMiniCard(
          icon: IconsaxPlusLinear.box_1,
          value: '${stats.totalOrders}',
          label: AppStrings.totalOrders,
          isDark: isDark,
        ),
        SizedBox(width: AppSizes.sm),
        _StatMiniCard(
          icon: IconsaxPlusLinear.tick_circle,
          value: '${stats.totalDelivered}',
          label: AppStrings.delivered,
          isDark: isDark,
        ),
        SizedBox(width: AppSizes.sm),
        _StatMiniCard(
          icon: IconsaxPlusLinear.star_1,
          value: stats.averageRating.toStringAsFixed(1),
          label: AppStrings.successRate,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.md,
          horizontal: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: Responsive.r(32),
              height: Responsive.r(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Responsive.r(16),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
