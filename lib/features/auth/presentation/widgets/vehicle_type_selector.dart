import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/vehicle_type_entity.dart';

extension _VehicleTypeExt on VehicleTypeEntity {
  String get arabicName =>
      AppStrings.vehicleTypesArabic[name] ?? name;

  String get iconPath =>
      'assets/images/vehicles/${name.toLowerCase()}.png';
}

class VehicleTypeSelector extends StatelessWidget {
  const VehicleTypeSelector({
    super.key,
    required this.vehicleTypes,
    required this.selectedId,
    required this.onChanged,
    this.errorText,
  });

  final List<VehicleTypeEntity> vehicleTypes;
  final int? selectedId;
  final ValueChanged<int?> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: AppSizes.avatarLg * 1.6,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vehicleTypes.length,
            separatorBuilder: (_, __) => SizedBox(width: AppSizes.md),
            itemBuilder: (context, index) {
              final type = vehicleTypes[index];
              final isSelected = type.id == selectedId;

              return GestureDetector(
                onTap: () => onChanged(type.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: AppSizes.avatarLg * 1.6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : bgColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : borderColor,
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        type.iconPath,
                        width: AppSizes.iconXl * 1.5,
                        height: AppSizes.iconXl * 1.5,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: AppSizes.xs),
                      Text(
                        type.arabicName,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.textBodyDark
                                  : AppColors.textBody,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: AppSizes.sm),
          Text(
            errorText!,
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
