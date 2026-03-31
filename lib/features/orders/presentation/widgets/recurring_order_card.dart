import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_card.dart';

class RecurringOrderCard extends StatelessWidget {
  const RecurringOrderCard({
    super.key,
    required this.data,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
  });

  final Map<String, dynamic> data;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final customerName = data['customerName'] as String? ?? '-';
    final address = data['deliveryAddress'] as String? ?? '';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final pattern = data['recurrencePattern'] as String? ?? '';
    final isPaused = data['isPaused'] as bool? ?? false;
    final nextDate = data['nextScheduledDate'] as String? ?? '';

    final patternLabel = switch (pattern) {
      'Daily' => AppStrings.recurrenceDaily,
      'Weekly' => AppStrings.recurrenceWeekly,
      'Monthly' => AppStrings.recurrenceMonthly,
      _ => pattern,
    };

    return SekkaCard(
      margin: EdgeInsets.only(bottom: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: customer + status
          Row(
            textDirection: TextDirection.rtl,
            children: [
              // Recurring icon
              Container(
                padding: EdgeInsets.all(Responsive.w(6)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusLinear.repeat,
                  size: Responsive.r(14),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  customerName,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              // Status chip
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: isPaused
                      ? AppColors.warning.withValues(alpha: 0.12)
                      : AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  isPaused ? AppStrings.pauseRecurring : AppStrings.resumeRecurring,
                  style: AppTypography.captionSmall.copyWith(
                    color: isPaused ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSizes.sm),

          // Address
          if (address.isNotEmpty)
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  IconsaxPlusLinear.location,
                  size: AppSizes.iconSm,
                  color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                ),
                SizedBox(width: AppSizes.xs),
                Expanded(
                  child: Text(
                    address,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textBodyDark : AppColors.textBody,
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          SizedBox(height: AppSizes.sm),

          // Bottom row: amount + pattern + next date + actions
          Row(
            textDirection: TextDirection.rtl,
            children: [
              // Amount
              Text(
                '${amount.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: AppSizes.sm),

              // Pattern chip
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: Responsive.h(2),
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconsaxPlusLinear.repeat,
                        size: Responsive.r(12),
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption),
                    SizedBox(width: Responsive.w(4)),
                    Text(
                      patternLabel,
                      style: AppTypography.captionSmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Pause/Resume button
              _ActionIcon(
                icon: isPaused ? IconsaxPlusLinear.play : IconsaxPlusLinear.pause,
                color: isPaused ? AppColors.success : AppColors.warning,
                onTap: isPaused ? onResume : onPause,
              ),
              SizedBox(width: AppSizes.xs),
              // Delete button
              _ActionIcon(
                icon: IconsaxPlusLinear.trash,
                color: AppColors.error,
                onTap: () => _confirmDelete(context),
              ),
            ],
          ),

          // Next date
          if (nextDate.isNotEmpty && !nextDate.startsWith('0001'))
            Padding(
              padding: EdgeInsets.only(top: AppSizes.xs),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(IconsaxPlusLinear.calendar_1,
                      size: Responsive.r(12),
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption),
                  SizedBox(width: Responsive.w(4)),
                  Text(
                    '${AppStrings.nextScheduled}: ${nextDate.length >= 10 ? nextDate.substring(0, 10) : nextDate}',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Text(AppStrings.deleteRecurring,
              style: AppTypography.titleMedium),
          content: Text(AppStrings.confirmDeleteRecurring,
              style: AppTypography.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppStrings.cancel, style: AppTypography.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              child: Text(
                AppStrings.deleteRecurring,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Responsive.w(6)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Icon(icon, size: Responsive.r(16), color: color),
      ),
    );
  }
}
