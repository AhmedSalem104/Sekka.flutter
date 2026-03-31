import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../bloc/break_bloc.dart';

/// Bottom sheet for selecting energy level before/after a break.
///
/// Pass [isStart] = true when starting a break (shows location input).
/// Pass [isStart] = false when ending a break.
class BreakEnergySheet extends StatefulWidget {
  const BreakEnergySheet({super.key, required this.isStart});

  final bool isStart;

  @override
  State<BreakEnergySheet> createState() => _BreakEnergySheetState();
}

class _BreakEnergySheetState extends State<BreakEnergySheet> {
  int _selectedEnergy = 3;
  final _locationController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _onConfirm(BuildContext context) {
    if (widget.isStart &&
        _locationController.text.trim().isEmpty) {
      setState(() => _errorMessage = AppStrings.breakLocationRequired);
      return;
    }
    if (widget.isStart) {
      context.read<BreakBloc>().add(
            BreakStartRequested(
              energyBefore: _selectedEnergy,
              locationDescription: _locationController.text.trim(),
            ),
          );
    } else {
      context.read<BreakBloc>().add(
            BreakEndRequested(energyAfter: _selectedEnergy),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<BreakBloc, BreakState>(
      listener: (context, state) {
        if (state is BreakStarted || state is BreakEnded) {
          Navigator.of(context).pop();
        }
        if (state is BreakError) {
          setState(() => _errorMessage = state.message);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: AppSizes.xxxl,
                    height: AppSizes.xs,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.xl),

                // Title
                Text(
                  widget.isStart
                      ? AppStrings.breakEnergyBeforeTitle
                      : AppStrings.breakEnergyAfterTitle,
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                Text(
                  AppStrings.breakEnergySubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
                SizedBox(height: AppSizes.xxl),

                // Energy selector
                _EnergySelector(
                  selected: _selectedEnergy,
                  onSelect: (v) => setState(() => _selectedEnergy = v),
                  isDark: isDark,
                ),
                SizedBox(height: AppSizes.xxl),

                // Location input (start only)
                if (widget.isStart) ...[
                  SekkaInputField(
                    controller: _locationController,
                    label: AppStrings.breakLocation,
                    hint: AppStrings.breakLocationHint,
                    onChanged: (_) =>
                        setState(() => _errorMessage = null),
                  ),
                  SizedBox(height: AppSizes.lg),
                ],

                // Inline error
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: AppSizes.sm),
                ],

                // Confirm button
                BlocBuilder<BreakBloc, BreakState>(
                  builder: (context, state) {
                    final isLoading =
                        state is BreakStarting || state is BreakEnding;
                    return SekkaButton(
                      label: widget.isStart
                          ? AppStrings.breakStart
                          : AppStrings.breakEnd,
                      onPressed: isLoading ? null : () => _onConfirm(context),
                      isLoading: isLoading,
                    );
                  },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Row of 5 energy level buttons (1 = very tired → 5 = full energy).
class _EnergySelector extends StatelessWidget {
  const _EnergySelector({
    required this.selected,
    required this.onSelect,
    required this.isDark,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final bool isDark;

  static const _levels = [
    (1, '😴', AppStrings.energyLevel1),
    (2, '😔', AppStrings.energyLevel2),
    (3, '😐', AppStrings.energyLevel3),
    (4, '😊', AppStrings.energyLevel4),
    (5, '🤩', AppStrings.energyLevel5),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _levels.map((level) {
        final (value, emoji, label) = level;
        final isSelected = selected == value;
        return GestureDetector(
          onTap: () => onSelect(value),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.backgroundDark
                          : AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.borderDark
                            : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

void showBreakEnergySheet(
  BuildContext context, {
  required bool isStart,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<BreakBloc>(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BreakEnergySheet(isStart: isStart),
      ),
    ),
  );
}
