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

    return Container(
      height: Responsive.h(48),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        textDirection: TextDirection.rtl,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
        ),
        decoration: InputDecoration(
          hintText: hint ?? AppStrings.search,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
          ),
          prefixIcon: Icon(
            IconsaxPlusLinear.search_normal_1,
            color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            size: Responsive.r(20),
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.w(16),
            vertical: Responsive.h(12),
          ),
        ),
      ),
    );
  }
}
