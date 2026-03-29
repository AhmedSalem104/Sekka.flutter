import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/enums/sos_enums.dart';

class SosStatusBadge extends StatelessWidget {
  const SosStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final SosStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _statusInfo;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSizes.sm : AppSizes.md,
        vertical: compact ? AppSizes.xs : AppSizes.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: (compact ? AppTypography.captionSmall : AppTypography.bodySmall)
            .copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  (Color, String) get _statusInfo => switch (status) {
        SosStatus.active => (AppColors.sosActive, AppStrings.sosStatusActive),
        SosStatus.resolved =>
          (AppColors.sosResolved, AppStrings.sosStatusResolved),
        SosStatus.dismissed =>
          (AppColors.sosDismissed, AppStrings.sosStatusDismissed),
        SosStatus.expired =>
          (AppColors.sosExpired, AppStrings.sosStatusExpired),
      };
}
