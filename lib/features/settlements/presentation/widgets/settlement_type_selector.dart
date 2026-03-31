import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../utils/settlement_helpers.dart';

class SettlementTypeSelector extends StatelessWidget {
  const SettlementTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final int selectedType;
  final ValueChanged<int> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: AppSizes.buttonHeight * 0.75,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final isSelected = selectedType == index;
          final typeColor = settlementTypeColor(index);

          return GestureDetector(
            onTap: () => onTypeSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? typeColor
                    : isDark
                        ? AppColors.surfaceDark
                        : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.chipRadius),
                border: Border.all(
                  color: isSelected
                      ? typeColor
                      : isDark
                          ? AppColors.borderDark
                          : AppColors.border,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    settlementTypeIcon(index),
                    size: AppSizes.iconSm,
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : typeColor,
                  ),
                  SizedBox(width: AppSizes.xs),
                  Text(
                    settlementTypeLabel(index),
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : isDark
                              ? AppColors.textBodyDark
                              : AppColors.textBody,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
