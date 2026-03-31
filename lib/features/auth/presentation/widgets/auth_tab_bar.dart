import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

class AuthTabBar extends StatelessWidget {
  const AuthTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.border.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.chipRadius),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.chipRadius),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: AppTypography.titleMedium.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
