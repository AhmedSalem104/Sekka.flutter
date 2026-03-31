import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
  });

  final String title;
  final String? subtitle;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (showLogo) ...[
          SizedBox(height: AppSizes.xl),
          Image.asset(
            isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
            height: AppSizes.avatarLg * 1.5,
          ),
          SizedBox(height: AppSizes.xxl),
        ],
        Text(
          title,
          style: AppTypography.headlineLarge.copyWith(
            color: isDark
                ? AppColors.textHeadlineDark
                : AppColors.textHeadline,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppSizes.sm),
          Text(
            subtitle!,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textBodyDark
                  : AppColors.textBody,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
