import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';

class SekkaExpandableSection extends StatefulWidget {
  const SekkaExpandableSection({
    super.key,
    required this.title,
    required this.children,
    this.leadingIcon,
    this.initiallyExpanded = false,
    this.controller,
    this.onExpansionChanged,
  });

  final String title;
  final List<Widget> children;
  final IconData? leadingIcon;
  final bool initiallyExpanded;
  final ExpansionTileController? controller;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<SekkaExpandableSection> createState() =>
      _SekkaExpandableSectionState();
}

class _SekkaExpandableSectionState extends State<SekkaExpandableSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ExpansionTile(
            controller: widget.controller,
            onExpansionChanged: (val) {
              setState(() => _isExpanded = val);
              widget.onExpansionChanged?.call(val);
            },
            initiallyExpanded: widget.initiallyExpanded,
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
            leading: widget.leadingIcon != null
                ? Container(
                    width: Responsive.r(36),
                    height: Responsive.r(36),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(
                      widget.leadingIcon,
                      size: AppSizes.iconMd,
                      color: AppColors.primary,
                    ),
                  )
                : null,
            trailing: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                IconsaxPlusLinear.arrow_down_1,
                size: AppSizes.iconMd,
                color: _isExpanded
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption),
              ),
            ),
            title: Text(
              widget.title,
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            children: widget.children,
          ),
        ),
      ),
    );
  }
}
