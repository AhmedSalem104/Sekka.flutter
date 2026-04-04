import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/cancellation_report_entity.dart';
import '../../domain/entities/customer_profitability_entity.dart';
import '../../domain/entities/profitability_trends_entity.dart';
import '../../domain/entities/region_analysis_entity.dart';
import '../../domain/entities/source_breakdown_entity.dart';
import '../../domain/entities/time_analysis_entity.dart';

// ─── Section Header ───────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Container(
            width: Responsive.r(32),
            height: Responsive.r(32),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Responsive.r(8)),
            ),
            child: Icon(icon, size: Responsive.r(16), color: color),
          ),
          SizedBox(width: AppSizes.sm),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Card Container ────────────────────────────────

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─── Empty Section ────────────────────────────────────────

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Center(
        child: Text(
          message,
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
          ),
        ),
      ),
    );
  }
}

// ─── 1. Profitability Trends Card ─────────────────────────

class ProfitabilityTrendsCard extends StatelessWidget {
  const ProfitabilityTrendsCard({super.key, required this.data});

  final List<ProfitabilityTrendsEntity> data;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      children: [
        _SectionHeader(
          title: AppStrings.analyticsProfitabilityTrends,
          icon: IconsaxPlusLinear.trend_up,
          color: AppColors.success,
        ),
        SizedBox(height: AppSizes.lg),
        if (data.isEmpty)
          _EmptySection(message: AppStrings.analyticsNoData)
        else
          ...data.map((item) => _ProfitabilityRow(item: item)),
      ],
    );
  }
}

class _ProfitabilityRow extends StatelessWidget {
  const _ProfitabilityRow({required this.item});

  final ProfitabilityTrendsEntity item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.period,
              style: AppTypography.captionSmall.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: AppStrings.analyticsRevenue,
                    value: '${item.revenue.toStringAsFixed(0)} ${AppStrings.currency}',
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _MiniStat(
                    label: AppStrings.analyticsExpenses,
                    value: '${item.expenses.toStringAsFixed(0)} ${AppStrings.currency}',
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _MiniStat(
                    label: AppStrings.analyticsNetProfit,
                    value: '${item.netProfit.toStringAsFixed(0)} ${AppStrings.currency}',
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.sm),
            // Profit margin bar
            _PercentBar(
              value: item.profitMargin / 100,
              color: AppColors.success,
              label: '${AppStrings.analyticsProfitMargin}: ${item.profitMargin.toStringAsFixed(0)}%',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.sm,
        horizontal: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              fontSize: Responsive.sp(10),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: Responsive.sp(12),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── 2. Time Analysis Card ────────────────────────────────

class TimeAnalysisCard extends StatelessWidget {
  const TimeAnalysisCard({super.key, required this.data});

  final List<TimeAnalysisEntity> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _AnalyticsCard(
      children: [
        _SectionHeader(
          title: AppStrings.analyticsTimeAnalysis,
          icon: IconsaxPlusLinear.clock,
          color: AppColors.info,
        ),
        SizedBox(height: AppSizes.lg),
        if (data.isEmpty)
          _EmptySection(message: AppStrings.analyticsNoData)
        else
          ...data.take(8).map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.sm),
                  child: _PercentBar(
                    value: data.isEmpty
                        ? 0
                        : item.totalOrders /
                            data
                                .map((e) => e.totalOrders)
                                .reduce((a, b) => a > b ? a : b),
                    color: AppColors.info,
                    label:
                        '${_formatHour(item.hour)} — ${item.totalOrders} ${AppStrings.analyticsOrders}',
                    isDark: isDark,
                  ),
                ),
              ),
      ],
    );
  }

  static String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}

// ─── 3. Region Analysis Card ──────────────────────────────

class RegionAnalysisCard extends StatelessWidget {
  const RegionAnalysisCard({super.key, required this.data});

  final List<RegionAnalysisEntity> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _AnalyticsCard(
      children: [
        _SectionHeader(
          title: AppStrings.analyticsRegionAnalysis,
          icon: IconsaxPlusLinear.location,
          color: AppColors.warning,
        ),
        SizedBox(height: AppSizes.lg),
        if (data.isEmpty)
          _EmptySection(message: AppStrings.analyticsNoData)
        else
          ...data.map(
            (item) => Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.md),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.region,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textBodyDark
                              : AppColors.textBody,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _PercentBar(
                        value: data.isEmpty
                            ? 0
                            : item.totalOrders /
                                data
                                    .map((e) => e.totalOrders)
                                    .reduce((a, b) => a > b ? a : b),
                        color: AppColors.warning,
                        label:
                            '${item.totalOrders} ${AppStrings.analyticsOrders} — ${item.totalRevenue.toStringAsFixed(0)} ${AppStrings.currency}',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── 4. Source Breakdown Card ─────────────────────────────

class SourceBreakdownCard extends StatelessWidget {
  const SourceBreakdownCard({super.key, required this.data});

  final List<SourceBreakdownEntity> data;

  static const _sourceColors = [
    AppColors.primary,
    AppColors.info,
    AppColors.success,
    AppColors.warning,
    AppColors.statusReturned,
    AppColors.statusOnTheWay,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _AnalyticsCard(
      children: [
        _SectionHeader(
          title: AppStrings.analyticsSourceBreakdown,
          icon: IconsaxPlusLinear.chart_1,
          color: AppColors.primary,
        ),
        SizedBox(height: AppSizes.lg),
        if (data.isEmpty)
          _EmptySection(message: AppStrings.analyticsNoData)
        else ...[
          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: SizedBox(
              height: Responsive.h(12),
              child: Row(
                children: data.asMap().entries.map((entry) {
                  final color =
                      _sourceColors[entry.key % _sourceColors.length];
                  return Expanded(
                    flex: (entry.value.percentage * 10).toInt().clamp(1, 100),
                    child: Container(color: color),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: AppSizes.md),
          // Legend
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              spacing: AppSizes.lg,
              runSpacing: AppSizes.sm,
              children: data.asMap().entries.map((entry) {
                final color =
                    _sourceColors[entry.key % _sourceColors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: Responsive.r(10),
                      height: Responsive.r(10),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      '${entry.value.source} (${entry.value.percentage.toStringAsFixed(0)}%)',
                      style: AppTypography.captionSmall.copyWith(
                        color: isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── 5. Customer Profitability Card ───────────────────────

class CustomerProfitabilityCard extends StatelessWidget {
  const CustomerProfitabilityCard({super.key, required this.data});

  final List<CustomerProfitabilityEntity> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _AnalyticsCard(
      children: [
        _SectionHeader(
          title: AppStrings.analyticsCustomerProfitability,
          icon: IconsaxPlusLinear.people,
          color: AppColors.statusOnTheWay,
        ),
        SizedBox(height: AppSizes.lg),
        if (data.isEmpty)
          _EmptySection(message: AppStrings.analyticsNoData)
        else
          ...data.take(5).toList().asMap().entries.map((entry) {
            final item = entry.value;
            final rank = entry.key + 1;
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.md),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: Responsive.r(28),
                      height: Responsive.r(28),
                      decoration: BoxDecoration(
                        color: rank <= 3
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.border)
                                .withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$rank',
                        style: AppTypography.captionSmall.copyWith(
                          color: rank <= 3
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textCaptionDark
                                  : AppColors.textCaption),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.customerName,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textBodyDark
                                  : AppColors.textBody,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item.totalOrders} ${AppStrings.analyticsOrders}',
                            style: AppTypography.captionSmall.copyWith(
                              color: isDark
                                  ? AppColors.textCaptionDark
                                  : AppColors.textCaption,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.totalProfit.toStringAsFixed(0)} ${AppStrings.currency}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ─── 6. Cancellation Report Card ──────────────────────────

class CancellationReportCard extends StatelessWidget {
  const CancellationReportCard({super.key, required this.data});

  final List<CancellationReportEntity> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _AnalyticsCard(
      children: [
        _SectionHeader(
          title: AppStrings.analyticsCancellationReport,
          icon: IconsaxPlusLinear.close_circle,
          color: AppColors.error,
        ),
        SizedBox(height: AppSizes.lg),
        if (data.isEmpty)
          _EmptySection(message: AppStrings.analyticsNoData)
        else
          ...data.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.sm),
              child: _PercentBar(
                value: item.percentage / 100,
                color: AppColors.error,
                label:
                    '${item.reason} — ${item.count} (${item.percentage.toStringAsFixed(0)}%)',
                isDark: isDark,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Shared: Percent Bar ──────────────────────────────────

class _PercentBar extends StatelessWidget {
  const _PercentBar({
    required this.value,
    required this.color,
    required this.label,
    required this.isDark,
  });

  final double value;
  final Color color;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSizes.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: Responsive.h(6),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
