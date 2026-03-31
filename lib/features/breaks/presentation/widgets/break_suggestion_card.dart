import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/break_suggestion_entity.dart';
import 'break_energy_sheet.dart';

/// Card shown on home screen when the API suggests the driver should rest.
class BreakSuggestionCard extends StatelessWidget {
  const BreakSuggestionCard({
    super.key,
    required this.suggestion,
    required this.isDark,
  });

  final BreakSuggestionEntity suggestion;
  final bool isDark;

  Color _urgencyColor(int urgency) => switch (urgency) {
        3 => AppColors.error,
        2 => AppColors.warning,
        1 => AppColors.success,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _urgencyColor(suggestion.urgency);

    return Container(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  IconsaxPlusBold.coffee,
                  color: color,
                  size: AppSizes.iconMd,
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.breakSuggestionTitle,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${suggestion.suggestedDurationMinutes} ${AppStrings.breakMinutes}',
                      style: AppTypography.bodySmall.copyWith(color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (suggestion.reason.isNotEmpty) ...[
            SizedBox(height: AppSizes.md),
            Text(
              suggestion.reason,
              style: AppTypography.bodyMedium.copyWith(
                color:
                    isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
            ),
          ],

          if (suggestion.nearbySpots.isNotEmpty) ...[
            SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.xs,
              children: suggestion.nearbySpots.take(3).map((spot) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    spot,
                    style: AppTypography.captionSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          SizedBox(height: AppSizes.lg),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => showBreakEnergySheet(context, isStart: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              ),
              child: Text(
                AppStrings.breakTakeBreak,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
