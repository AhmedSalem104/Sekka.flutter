import 'package:flutter/material.dart';
import 'package:sekka/core/core.dart';

class StatsBarChart extends StatelessWidget {
  const StatsBarChart({
    super.key,
    required this.labels,
    required this.values,
    this.barColor,
  });

  final List<String> labels;
  final List<double> values;
  final Color? barColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxValue = values.fold<double>(0, (a, b) => a > b ? a : b);
    final color = barColor ?? AppColors.primary;

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: SizedBox(
        height: Responsive.h(160),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(labels.length, (i) {
            final ratio = maxValue > 0 ? values[i] / maxValue : 0.0;
            final isHighest = values[i] == maxValue && maxValue > 0;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(4)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (values[i] > 0)
                      Text(
                        values[i].toInt().toString(),
                        style: AppTypography.captionSmall.copyWith(
                          color: isHighest
                              ? color
                              : (isDark
                                  ? AppColors.textCaptionDark
                                  : AppColors.textCaption),
                          fontWeight:
                              isHighest ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    SizedBox(height: Responsive.h(4)),
                    Flexible(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        width: Responsive.w(28),
                        height: ratio * Responsive.h(110) +
                            (maxValue > 0 ? Responsive.h(4) : 0),
                        decoration: BoxDecoration(
                          color: isHighest
                              ? color
                              : color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            Responsive.r(6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(8)),
                    Text(
                      labels[i],
                      style: AppTypography.captionSmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
