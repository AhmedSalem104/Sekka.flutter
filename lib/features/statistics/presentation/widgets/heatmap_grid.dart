import 'package:flutter/material.dart';
import 'package:sekka/core/core.dart';

import '../../domain/entities/heatmap_stats_entity.dart';

class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({required this.cells, super.key});

  final List<HeatmapCellEntity> cells;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.currentLang == 'ar';

    const dayLabelsAr = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
    const dayLabelsEn = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final dayLabels = isAr ? dayLabelsAr : dayLabelsEn;

    // Grid: 7 days × 24 hours
    final grid = List<List<HeatmapCellEntity?>>.generate(
      7,
      (_) => List<HeatmapCellEntity?>.filled(24, null),
    );
    var maxOrders = 0;
    for (final c in cells) {
      final dow = ((c.dayOfWeek - 6) % 7 + 7) % 7; // map so 6=Sat→0
      if (dow >= 0 && dow < 7 && c.hour >= 0 && c.hour < 24) {
        grid[dow][c.hour] = c;
        if (c.orders > maxOrders) maxOrders = c.orders;
      }
    }

    final cellSize = Responsive.r(16);
    final gap = Responsive.r(2);

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.peakHoursHint,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textCaptionDark
                  : AppColors.textCaption,
            ),
          ),
          SizedBox(height: Responsive.h(12)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hour labels (every 3 hours)
                Padding(
                  padding: EdgeInsets.only(right: Responsive.w(28)),
                  child: Row(
                    children: List.generate(24, (h) {
                      final show = h % 3 == 0;
                      return SizedBox(
                        width: cellSize + gap,
                        child: show
                            ? Text(
                                '$h',
                                style: AppTypography.captionSmall.copyWith(
                                  color: isDark
                                      ? AppColors.textCaptionDark
                                      : AppColors.textCaption,
                                  fontSize: 9,
                                ),
                                textAlign: TextAlign.center,
                              )
                            : const SizedBox.shrink(),
                      );
                    }),
                  ),
                ),
                SizedBox(height: Responsive.h(4)),
                // Rows per day
                for (var d = 0; d < 7; d++)
                  Padding(
                    padding: EdgeInsets.only(bottom: gap),
                    child: Row(
                      children: [
                        for (var h = 0; h < 24; h++)
                          Container(
                            margin: EdgeInsets.only(right: gap),
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: _colorFor(
                                grid[d][h]?.orders ?? 0,
                                maxOrders,
                                isDark,
                              ),
                              borderRadius:
                                  BorderRadius.circular(Responsive.r(3)),
                            ),
                          ),
                        SizedBox(width: Responsive.w(6)),
                        SizedBox(
                          width: Responsive.w(22),
                          child: Text(
                            dayLabels[d],
                            style: AppTypography.captionSmall.copyWith(
                              color: isDark
                                  ? AppColors.textBodyDark
                                  : AppColors.textBody,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: Responsive.h(12)),
          _Legend(isDark: isDark),
        ],
      ),
    );
  }

  Color _colorFor(int orders, int max, bool isDark) {
    if (max == 0 || orders == 0) {
      return isDark
          ? AppColors.borderDark.withValues(alpha: 0.35)
          : AppColors.border.withValues(alpha: 0.5);
    }
    final t = (orders / max).clamp(0.15, 1.0);
    return AppColors.primary.withValues(alpha: t);
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const baseColor = AppColors.primary;
    return Row(
      children: [
        Text(
          '0',
          style: AppTypography.captionSmall.copyWith(
            color: isDark
                ? AppColors.textCaptionDark
                : AppColors.textCaption,
          ),
        ),
        SizedBox(width: Responsive.w(6)),
        for (final a in const [0.15, 0.35, 0.6, 0.85, 1.0])
          Container(
            width: Responsive.r(14),
            height: Responsive.r(14),
            margin: EdgeInsets.only(right: Responsive.w(2)),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: a),
              borderRadius: BorderRadius.circular(Responsive.r(3)),
            ),
          ),
        SizedBox(width: Responsive.w(6)),
        Text(
          AppStrings.peakHoursTitle,
          style: AppTypography.captionSmall.copyWith(
            color: isDark
                ? AppColors.textCaptionDark
                : AppColors.textCaption,
          ),
        ),
      ],
    );
  }
}
