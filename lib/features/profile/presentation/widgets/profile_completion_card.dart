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

  IconData _stepIcon(String stepKey) => switch (stepKey) {
        'vehicle_type' => IconsaxPlusLinear.car,
        'license_image' => IconsaxPlusLinear.card,
        'profile_photo' => IconsaxPlusLinear.camera,
        'email' => IconsaxPlusLinear.sms,
        'region' => IconsaxPlusLinear.location,
        _ => IconsaxPlusLinear.add_circle,
      };

  @override
  Widget build(BuildContext context) {
    if (completion.isProfileComplete) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = completion.completionPercentage;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: GestureDetector(
        onTap: () => onStepTap?.call(''),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with percentage + arrow
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.profileIncomplete,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    '$percentage%',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.md),

            // Progress bar
            SekkaProgressBar(percentage: percentage),
          ],
        ),
      ),
    );
  }
}
