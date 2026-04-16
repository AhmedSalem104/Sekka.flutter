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
    this.enabled = true,
  });

  final List<SekkaDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T> onChanged;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final bool enabled;

  @override
  State<SekkaDropdownField<T>> createState() => _SekkaDropdownFieldState<T>();
}

class _SekkaDropdownFieldState<T> extends State<SekkaDropdownField<T>> {
  bool _isOpen = false;

  Future<void> _openMenu() async {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final target = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screen = MediaQuery.of(context).size;

    setState(() => _isOpen = true);

    final selected = await showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
        target.dx,
        target.dy + size.height + AppSizes.xs,
        screen.width - target.dx - size.width,
        screen.height - target.dy - size.height,
      ),
      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      elevation: 4,
      items: widget.items.map((item) {
        final isSelected = item.value == widget.value;
        return PopupMenuItem<T>(
          value: item.value,
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
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody),
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
            ],
          ),
        );
      }).toList(),
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

    return InkWell(
      onTap: widget.enabled ? _openMenu : null,
      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
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
