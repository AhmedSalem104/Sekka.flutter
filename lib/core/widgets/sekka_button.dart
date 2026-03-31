import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';

enum SekkaButtonType { primary, secondary, text }

class SekkaButton extends StatelessWidget {
  const SekkaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = SekkaButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final SekkaButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  /// Override for primary button background (e.g. AppColors.error for danger).
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: AppSizes.buttonHeight,
      child: switch (type) {
        SekkaButtonType.primary => _buildPrimary(),
        SekkaButtonType.secondary => _buildSecondary(),
        SekkaButtonType.text => _buildText(),
      },
    );
  }

  Widget _buildPrimary() {
    final bg = backgroundColor ?? AppColors.primary;
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: bg.withValues(alpha: 0.5),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
      ),
      child: _buildContent(AppColors.textOnPrimary),
    );
  }

  Widget _buildSecondary() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
      ),
      child: _buildContent(AppColors.primary),
    );
  }

  Widget _buildText() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildContent(AppColors.primary),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: AppSizes.iconLg,
        height: AppSizes.iconLg,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconMd),
          SizedBox(width: AppSizes.sm),
          Flexible(
            child: Text(
              label,
              style: AppTypography.button.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: AppTypography.button.copyWith(color: color),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
