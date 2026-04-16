import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';

class SekkaSegmentedTabs extends StatelessWidget {
  const SekkaSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.controller,
    this.padding,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final TabController? controller;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) SizedBox(width: AppSizes.sm),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  controller?.animateTo(i);
                  onChanged(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? AppColors.primary
                        : (isDark ? AppColors.surfaceDark : AppColors.surface),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: i == selectedIndex
                          ? AppColors.primary
                          : (isDark ? AppColors.borderDark : AppColors.border),
                      width: 0.5,
                    ),
                    boxShadow: i == selectedIndex
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: AppTypography.titleMedium.copyWith(
                      color: i == selectedIndex
                          ? AppColors.textOnPrimary
                          : (isDark
                              ? AppColors.textCaptionDark
                              : AppColors.textCaption),
                      fontWeight:
                          i == selectedIndex ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
