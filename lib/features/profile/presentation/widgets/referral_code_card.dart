import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.referralCode,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: AppSizes.xs),
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
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              context.showSnackBar(AppStrings.codeCopied);
            },
            icon: const Icon(
              IconsaxPlusLinear.copy,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
