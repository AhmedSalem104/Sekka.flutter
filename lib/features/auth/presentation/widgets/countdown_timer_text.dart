import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_typography.dart';

class CountdownTimerText extends StatelessWidget {
  const CountdownTimerText({
    super.key,
    required this.secondsRemaining,
    required this.canResend,
    required this.onResend,
  });

  final int secondsRemaining;
  final bool canResend;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (canResend) {
      return GestureDetector(
        onTap: onResend,
        child: Text(
          AppStrings.resendOtp,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Text.rich(
      TextSpan(
        text: '${AppStrings.resendIn} ',
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textBodyDark : AppColors.textBody,
        ),
        children: [
          TextSpan(
            text: secondsRemaining.toString().toArabicNumbers,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          TextSpan(
            text: ' ${AppStrings.seconds}',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
