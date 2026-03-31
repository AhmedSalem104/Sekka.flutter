import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_typography.dart';

class ReferralCodeCard extends StatelessWidget {
  const ReferralCodeCard({
    super.key,
    required this.code,
  });

  final String code;

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with icon
          Row(
            children: [
              Icon(
                IconsaxPlusBold.gift,
                color: AppColors.textOnPrimary,
                size: AppSizes.iconLg,
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  AppStrings.referralCode,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),

          // Subtitle explanation
          Text(
            AppStrings.referralSubtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: AppSizes.md),

          // Code display
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.md),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: IconsaxPlusLinear.copy,
                  label: AppStrings.copyCode,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    context.showSnackBar(AppStrings.codeCopied);
                  },
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _ActionButton(
                  icon: IconsaxPlusLinear.share,
                  label: AppStrings.shareCode,
                  onTap: () {
                    final shareText = AppStrings.currentLang == 'ar'
                        ? 'سجّل في سِكّة واستخدم كود الدعوة بتاعي: $code\nhttps://sekka.app/join?ref=$code'
                        : 'Join Sekka using my invite code: $code\nhttps://sekka.app/join?ref=$code';
                    Share.share(shareText);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textOnPrimary, size: AppSizes.iconSm),
            SizedBox(width: AppSizes.xs),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
