import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../theme/app_typography.dart';
import 'sekka_button.dart';

enum SekkaMessageType { error, success, info }

class SekkaMessageDialog extends StatelessWidget {
  const SekkaMessageDialog({
    super.key,
    required this.message,
    this.title,
    this.type = SekkaMessageType.error,
    this.buttonText,
  });

  final String message;
  final String? title;
  final SekkaMessageType type;
  final String? buttonText;

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    SekkaMessageType type = SekkaMessageType.error,
    String? buttonText,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => SekkaMessageDialog(
        message: message,
        title: title,
        type: type,
        buttonText: buttonText,
      ),
    );
  }

  (IconData, Color) get _iconAndColor => switch (type) {
        SekkaMessageType.error => (Icons.error_rounded, AppColors.error),
        SekkaMessageType.success => (
            Icons.check_circle_rounded,
            AppColors.success
          ),
        SekkaMessageType.info => (Icons.info_rounded, AppColors.info),
      };

  String get _defaultTitle => switch (type) {
        SekkaMessageType.error => AppStrings.errorTitle,
        SekkaMessageType.success => AppStrings.successTitle,
        SekkaMessageType.info => AppStrings.infoTitle,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (icon, color) = _iconAndColor;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding * 2,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: AppSizes.avatarLg,
              height: AppSizes.avatarLg,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(icon, color: color, size: AppSizes.iconXl),
            ),
            SizedBox(height: AppSizes.lg),

            // Title
            Text(
              title ?? _defaultTitle,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.sm),

            // Message
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.xxl),

            // Button
            SekkaButton(
              label: buttonText ?? AppStrings.ok,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
