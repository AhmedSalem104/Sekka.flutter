import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_progress_bar.dart';
import '../../domain/entities/profile_completion_entity.dart';

class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({
    super.key,
    required this.completion,
    this.onStepTap,
  });

  final ProfileCompletionEntity completion;
  final ValueChanged<String>? onStepTap;

  @override
  Widget build(BuildContext context) {
    if (completion.isProfileComplete) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconsaxPlusLinear.info_circle,
                size: AppSizes.iconMd,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.sm),
              Text(
                AppStrings.profileIncomplete,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          SekkaProgressBar(percentage: completion.completionPercentage),
          SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: completion.pendingSteps.map((step) {
              return GestureDetector(
                onTap: () => onStepTap?.call(step.stepKey),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.background,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                    border: Border.all(
                      color: step.isRequired
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconsaxPlusLinear.add_circle,
                        size: AppSizes.iconSm,
                        color: step.isRequired
                            ? AppColors.primary
                            : isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption,
                      ),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        step.stepName,
                        style: AppTypography.captionSmall.copyWith(
                          color: step.isRequired
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.textBodyDark
                                  : AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
