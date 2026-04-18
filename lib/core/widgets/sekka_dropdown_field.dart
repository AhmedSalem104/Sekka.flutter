import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';

class SekkaDropdownItem<T> {
  const SekkaDropdownItem({
    required this.value,
    required this.label,
    this.leading,
  });

  final T value;
  final String label;
  final Widget? leading;
}

class SekkaDropdownField<T> extends StatefulWidget {
  const SekkaDropdownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.prefixIcon,
    this.sheetTitle,
    this.enabled = true,
  });

  final List<SekkaDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final String? sheetTitle;
  final bool enabled;

  @override
  State<SekkaDropdownField<T>> createState() => _SekkaDropdownFieldState<T>();
}

class _SekkaDropdownFieldState<T> extends State<SekkaDropdownField<T>> {
  bool _isOpen = false;

  Future<void> _openSheet() async {
    setState(() => _isOpen = true);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selected = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sheetDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.lg,
              AppSizes.pagePadding,
              AppSizes.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sheetDark
                          ? AppColors.borderDark
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusPill,
                      ),
                    ),
                  ),
                ),
                if (widget.sheetTitle != null) ...[
                  SizedBox(height: AppSizes.lg),
                  Text(
                    widget.sheetTitle!,
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSmall.copyWith(
                      color: sheetDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                  ),
                ],
                SizedBox(height: AppSizes.lg),
                ...widget.items.map((item) {
                  final isSelected = item.value == widget.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSizes.sm),
                    child: _DropdownOptionTile(
                      item: item,
                      isSelected: isSelected,
                      isDark: sheetDark,
                      onTap: () => Navigator.pop(ctx, item.value),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) setState(() => _isOpen = false);
    if (selected != null) widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final iconColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;
    final textColor = isDark ? AppColors.textBodyDark : AppColors.textBody;

    SekkaDropdownItem<T>? selected;
    for (final item in widget.items) {
      if (item.value == widget.value) {
        selected = item;
        break;
      }
    }

    final hasValue = selected != null;
    final displayText =
        selected?.label ?? widget.hint ?? widget.label ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? _openSheet : null,
      child: Container(
        height: AppSizes.inputHeight,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          border: Border.all(
            color: _isOpen ? AppColors.primary : borderColor,
            width: _isOpen ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Icon(
                widget.prefixIcon,
                size: AppSizes.iconLg,
                color: iconColor,
              ),
              SizedBox(width: AppSizes.sm),
            ],
            if (hasValue && selected.leading != null) ...[
              selected.leading!,
              SizedBox(width: AppSizes.sm),
            ],
            Expanded(
              child: Text(
                displayText,
                style: AppTypography.bodyLarge.copyWith(
                  color: hasValue ? textColor : iconColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                IconsaxPlusLinear.arrow_down_1,
                size: AppSizes.iconMd,
                color: _isOpen ? AppColors.primary : iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownOptionTile<T> extends StatelessWidget {
  const _DropdownOptionTile({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final SekkaDropdownItem<T> item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.08)
        : (isDark ? AppColors.backgroundDark : AppColors.background);
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.border);
    final textColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.textBodyDark : AppColors.textBody);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: AppSizes.inputHeight,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            if (item.leading != null) ...[
              item.leading!,
              SizedBox(width: AppSizes.sm),
            ],
            Expanded(
              child: Text(
                item.label,
                style: AppTypography.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                IconsaxPlusLinear.tick_circle,
                size: AppSizes.iconMd,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
