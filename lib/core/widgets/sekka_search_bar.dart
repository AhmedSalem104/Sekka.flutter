import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../theme/app_typography.dart';

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
    return Container(
      height: AppSizes.inputHeight * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        textDirection: TextDirection.rtl,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: hint ?? AppStrings.search,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textCaption,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textCaption,
            size: AppSizes.iconLg,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
        ),
      ),
    );
  }
}
