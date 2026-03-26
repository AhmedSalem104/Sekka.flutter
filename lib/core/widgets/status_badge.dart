import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../theme/app_typography.dart';

enum OrderStatus {
  newOrder,
  onTheWay,
  arrived,
  delivered,
  failed,
  cancelled,
  returned,
  postponed,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final OrderStatus status;
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
        OrderStatus.newOrder => (AppColors.statusNew, AppStrings.statusNew),
        OrderStatus.onTheWay =>
          (AppColors.statusOnTheWay, AppStrings.statusOnTheWay),
        OrderStatus.arrived =>
          (AppColors.statusArrived, AppStrings.statusArrived),
        OrderStatus.delivered =>
          (AppColors.statusDelivered, AppStrings.statusDelivered),
        OrderStatus.failed => (AppColors.statusFailed, AppStrings.statusFailed),
        OrderStatus.cancelled =>
          (AppColors.statusCancelled, AppStrings.statusCancelled),
        OrderStatus.returned =>
          (AppColors.statusReturned, AppStrings.statusReturned),
        OrderStatus.postponed =>
          (AppColors.statusPostponed, AppStrings.statusPostponed),
      };
}
