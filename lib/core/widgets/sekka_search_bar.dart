import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';

class SekkaSearchBar extends StatelessWidget {
  const SekkaSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hint,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;
    final labelText = hint ?? AppStrings.search;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textDirection: TextDirection.rtl,
      style: AppTypography.bodyMedium.copyWith(
        color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTypography.bodyMedium.copyWith(color: captionColor),
        floatingLabelStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: Icon(
          IconsaxPlusLinear.search_normal_1,
          color: captionColor,
          size: Responsive.r(20),
        ),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.w(16),
          vertical: Responsive.h(14),
        ),
      ),
    );
  }
}
