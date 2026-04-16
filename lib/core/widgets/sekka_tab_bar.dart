import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';

/// Segmented tab bar where each tab is a standalone pill/button.
/// Tabs are visually separated (not joined in a single container).
class SekkaTabBar extends StatelessWidget {
  const SekkaTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onChanged,
    this.isDark = false,
    this.expand = true,
    this.gap,
  });

  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final bool isDark;
  final bool expand;
  final double? gap;

  @override
  Widget build(BuildContext context) {
    final spacing = gap ?? AppSizes.sm;
    final children = <Widget>[];
    for (var i = 0; i < tabs.length; i++) {
      final tab = _SekkaTabItem(
        label: tabs[i],
        isSelected: i == currentIndex,
        isDark: isDark,
        onTap: () => onChanged(i),
      );
      children.add(expand ? Expanded(child: tab) : tab);
      if (i != tabs.length - 1) {
        children.add(SizedBox(width: spacing));
      }
    }

    return Row(children: children);
  }
}

class _SekkaTabItem extends StatelessWidget {
  const _SekkaTabItem({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDark : AppColors.surface);
    final fg = isSelected
        ? AppColors.textOnPrimary
        : (isDark ? AppColors.textHeadlineDark : AppColors.textHeadline);
    final border = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.border);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        child: Container(
          height: AppSizes.buttonHeight,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
            border: Border.all(color: border, width: 1),
          ),
          child: Text(
            label,
            style: AppTypography.button.copyWith(
              color: fg,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
