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

    return Row(
      children: [
        for (var index = 0; index < tabs.length; index++) ...[
          if (index > 0) SizedBox(width: AppSizes.sm),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                decoration: BoxDecoration(
                  color: index == selectedIndex
                      ? AppColors.primary
                      : (isDark ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(AppSizes.chipRadius),
                  border: Border.all(
                    color: index == selectedIndex
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                    width: 0.5,
                  ),
                  boxShadow: index == selectedIndex
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
                  tabs[index],
                  style: AppTypography.titleMedium.copyWith(
                    color: index == selectedIndex
                        ? AppColors.textOnPrimary
                        : (isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody),
                    fontWeight: index == selectedIndex
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
