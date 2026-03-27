import 'package:flutter/material.dart';

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
    return Column(
      children: [
        if (showLogo) ...[
          SizedBox(height: AppSizes.xl),
          Image.asset(
            'assets/images/logo.png',
            height: AppSizes.avatarLg * 1.5,
          ),
          SizedBox(height: AppSizes.xxl),
        ],
        Text(
          title,
          style: AppTypography.headlineLarge,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppSizes.sm),
          Text(
            subtitle!,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
