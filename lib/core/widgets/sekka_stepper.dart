import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';

class SekkaStepperItem {
  const SekkaStepperItem({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;
}

class SekkaStepper extends StatelessWidget {
  const SekkaStepper({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<SekkaStepperItem> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final dotSize = Responsive.r(28);

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppColors.success : AppColors.border,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;

        return _buildStep(
          steps[stepIndex],
          dotSize: dotSize,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
        );
      }),
    );
  }

  Widget _buildStep(
    SekkaStepperItem step, {
    required double dotSize,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final Color color;
    if (isCompleted) {
      color = AppColors.success;
    } else if (isCurrent) {
      color = AppColors.primary;
    } else {
      color = AppColors.border;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded,
                    size: AppSizes.iconSm, color: AppColors.textOnPrimary)
                : step.icon != null
                    ? Icon(step.icon, size: AppSizes.iconSm, color: color)
                    : null,
          ),
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          step.label,
          style: AppTypography.captionSmall.copyWith(
            color: isCurrent ? AppColors.primary : AppColors.textCaption,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w300,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
