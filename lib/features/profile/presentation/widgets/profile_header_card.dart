import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_avatar.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    this.onEditTap,
  });

  final ProfileEntity profile;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.xl),
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
          SekkaAvatar(
            imageUrl: profile.profileImageUrl,
            size: 80,
          ),
          SizedBox(height: AppSizes.md),
          Text(
            profile.name,
            style: AppTypography.headlineMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            profile.phone,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
            textDirection: TextDirection.ltr,
          ),
          SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon: IconsaxPlusLinear.medal_star,
                label: '${AppStrings.level} ${profile.level}',
                isDark: isDark,
              ),
              SizedBox(width: AppSizes.sm),
              _InfoChip(
                icon: IconsaxPlusLinear.cup,
                label: '${profile.totalPoints} ${AppStrings.points}',
                isDark: isDark,
              ),
              SizedBox(width: AppSizes.sm),
              _InfoChip(
                icon: profile.isOnline
                    ? IconsaxPlusLinear.tick_circle
                    : IconsaxPlusLinear.close_circle,
                label:
                    profile.isOnline ? AppStrings.online : AppStrings.offline,
                color: profile.isOnline ? AppColors.success : AppColors.textCaption,
                isDark: isDark,
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEditTap,
              icon: Icon(
                IconsaxPlusLinear.edit_2,
                size: AppSizes.iconSm,
              ),
              label: const Text(AppStrings.editProfile),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
                padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Responsive.r(14),
            color: color ?? AppColors.primary,
          ),
          SizedBox(width: AppSizes.xs),
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
