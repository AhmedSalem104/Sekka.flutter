import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';

class SekkaExpandableSection extends StatelessWidget {
  const SekkaExpandableSection({
    super.key,
    required this.title,
    required this.children,
    this.leadingIcon,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<Widget> children;
  final IconData? leadingIcon;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.xs,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            AppSizes.lg,
            0,
            AppSizes.lg,
            AppSizes.lg,
          ),
          leading: leadingIcon != null
              ? Container(
                  width: Responsive.r(36),
                  height: Responsive.r(36),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    leadingIcon,
                    size: AppSizes.iconMd,
                    color: AppColors.primary,
                  ),
                )
              : null,
          trailing: Icon(
            IconsaxPlusLinear.arrow_down_1,
            size: AppSizes.iconMd,
            color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
          ),
          title: Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}
