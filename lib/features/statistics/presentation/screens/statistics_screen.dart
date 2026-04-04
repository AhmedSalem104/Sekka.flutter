import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sekka/core/core.dart';

import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_event.dart';
import '../../../analytics/presentation/bloc/analytics_state.dart';
import '../../../analytics/presentation/widgets/analytics_section.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/presentation/widgets/health_score_card.dart';
import '../../../shifts/domain/entities/shift_summary_entity.dart';
import '../../../shifts/presentation/bloc/shift_bloc.dart';
import '../../../shifts/presentation/bloc/shift_state.dart';
import '../../domain/entities/daily_stats_entity.dart';
import '../../domain/entities/monthly_stats_entity.dart';
import '../../domain/entities/weekly_stats_entity.dart';
import '../bloc/statistics_bloc.dart';
import '../widgets/stat_detail_row.dart';
import '../widgets/stat_summary_card.dart';
import '../widgets/stats_bar_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(const AnalyticsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.myStats,
          style: AppTypography.headlineSmall.copyWith(
            color:
                isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        leading: const SekkaBackButton(),
      ),
      body: Column(
        children: [
          _TabBar(isDark: isDark),
          Expanded(
            child: BlocBuilder<StatisticsBloc, StatisticsState>(
              builder: (context, state) => switch (state) {
                StatisticsLoading() => const SekkaLoading(),
                StatisticsEmpty() => SekkaEmptyState(
                    icon: IconsaxPlusLinear.chart_2,
                    title: AppStrings.noStatsYet,
                    description: AppStrings.noStatsHint,
                  ),
                StatisticsError(:final message) => SekkaEmptyState(
                    icon: IconsaxPlusLinear.warning_2,
                    title: message,
                    actionLabel: AppStrings.retry,
                    onAction: () => context
                        .read<StatisticsBloc>()
                        .add(const StatisticsLoadRequested()),
                  ),
                StatisticsLoaded() => _LoadedBody(state: state),
                StatisticsInitial() => const SekkaLoading(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Bar ──

class _TabBar extends StatelessWidget {
  const _TabBar({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      buildWhen: (prev, curr) => prev.tab != curr.tab,
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: Responsive.w(20),
            vertical: Responsive.h(12),
          ),
          padding: EdgeInsets.all(Responsive.w(4)),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: StatisticsTab.values.map((tab) {
              final isSelected = state.tab == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context
                      .read<StatisticsBloc>()
                      .add(StatisticsTabChanged(tab)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _tabLabel(tab),
                      style: AppTypography.titleMedium.copyWith(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : (isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _tabLabel(StatisticsTab tab) => switch (tab) {
        StatisticsTab.daily => AppStrings.dailyStats,
        StatisticsTab.weekly => AppStrings.weeklyStats,
        StatisticsTab.monthly => AppStrings.monthlyStats,
      };
}

// ── Loaded Body ──

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});
  final StatisticsLoaded state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Responsive.h(8)),
          ..._buildContent(isDark),
          SizedBox(height: Responsive.h(24)),

          // ── Expandable Sections ──
          _ShiftSummarySection(isDark: isDark),
          SizedBox(height: Responsive.h(12)),
          _HealthScoreSection(isDark: isDark),
          SizedBox(height: Responsive.h(12)),
          _AnalyticsSection(isDark: isDark),

          SizedBox(height: Responsive.h(40)),
        ],
      ),
    );
  }

  List<Widget> _buildContent(bool isDark) => switch (state.tab) {
        StatisticsTab.daily when state.daily != null =>
          _buildDaily(state.daily!, isDark),
        StatisticsTab.weekly when state.weekly != null =>
          _buildWeekly(state.weekly!, isDark),
        StatisticsTab.monthly when state.monthly != null =>
          _buildMonthly(state.monthly!, isDark),
        _ => [const SekkaLoading()],
      };

  // ── Daily ──

  List<Widget> _buildDaily(DailyStatsEntity s, bool isDark) {
    return [
      _summaryGrid(
        totalOrders: s.totalOrders,
        earnings: s.earnings,
        successRate: s.successRate,
        netProfit: s.netProfit,
      ),
      SizedBox(height: Responsive.h(20)),
      _sectionTitle(AppStrings.moreDetails, isDark),
      SizedBox(height: Responsive.h(8)),
      SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(16),
          vertical: Responsive.h(8),
        ),
        child: Column(
          children: [
            StatDetailRow(
              icon: IconsaxPlusLinear.tick_circle,
              label: AppStrings.successful,
              value: '${s.successfulOrders}',
              iconColor: AppColors.success,
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.close_circle,
              label: AppStrings.failed,
              value: '${s.failedOrders}',
              iconColor: AppColors.error,
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.minus_cirlce,
              label: AppStrings.cancelled,
              value: '${s.cancelledOrders}',
              iconColor: AppColors.statusCancelled,
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.routing_2,
              label: AppStrings.totalDistance,
              value: '${s.distanceKm.toStringAsFixed(1)} ${AppStrings.km}',
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.clock,
              label: AppStrings.timeWorked,
              value: _formatMinutes(s.timeWorkedMinutes),
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.money_recive,
              label: AppStrings.cashCollected,
              value: '${s.tips.toInt()} ${AppStrings.currency}',
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.percentage_circle,
              label: AppStrings.commissions,
              value: '${s.commissions.toInt()} ${AppStrings.currency}',
            ),
            if (s.averageDeliveryTimeMinutes > 0)
              StatDetailRow(
                icon: IconsaxPlusLinear.timer_1,
                label: AppStrings.avgDeliveryTime,
                value: _formatMinutes(s.averageDeliveryTimeMinutes),
              ),
            if (s.peakHour > 0)
              StatDetailRow(
                icon: IconsaxPlusLinear.flash_1,
                label: AppStrings.peakHour,
                value: _formatHour(s.peakHour),
                iconColor: AppColors.warning,
              ),
          ],
        ),
      ),
    ];
  }

  // ── Weekly ──

  List<Widget> _buildWeekly(WeeklyStatsEntity s, bool isDark) {
    final dayLabels = s.dailyBreakdown
        .map((d) => _shortDayName(d.date))
        .toList();
    final earningsValues = s.dailyBreakdown
        .map((d) => d.earnings)
        .toList();

    return [
      _summaryGrid(
        totalOrders: s.totalOrders,
        earnings: s.earnings,
        successRate: s.successRate,
        netProfit: s.netProfit,
      ),
      if (s.dailyBreakdown.isNotEmpty) ...[
        SizedBox(height: Responsive.h(20)),
        _sectionTitle(AppStrings.totalEarningsLabel, isDark),
        SizedBox(height: Responsive.h(8)),
        StatsBarChart(
          labels: dayLabels,
          values: earningsValues,
        ),
      ],
      SizedBox(height: Responsive.h(20)),
      _sectionTitle(AppStrings.moreDetails, isDark),
      SizedBox(height: Responsive.h(8)),
      SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(16),
          vertical: Responsive.h(8),
        ),
        child: Column(
          children: [
            StatDetailRow(
              icon: IconsaxPlusLinear.tick_circle,
              label: AppStrings.successful,
              value: '${s.successfulOrders}',
              iconColor: AppColors.success,
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.routing_2,
              label: AppStrings.totalDistance,
              value: '${s.distanceKm.toStringAsFixed(1)} ${AppStrings.km}',
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.clock,
              label: AppStrings.timeWorked,
              value: _formatMinutes(s.timeWorkedMinutes),
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.percentage_circle,
              label: AppStrings.commissions,
              value: '${s.commissions.toInt()} ${AppStrings.currency}',
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.money_send,
              label: AppStrings.expensesLabel,
              value: '${s.expenses.toInt()} ${AppStrings.currency}',
              iconColor: AppColors.error,
            ),
            if (s.bestDay != null)
              StatDetailRow(
                icon: IconsaxPlusLinear.star_1,
                label: AppStrings.bestDay,
                value: _shortDayName(s.bestDay!),
                iconColor: AppColors.warning,
              ),
          ],
        ),
      ),
    ];
  }

  // ── Monthly ──

  List<Widget> _buildMonthly(MonthlyStatsEntity s, bool isDark) {
    final weekLabels = List.generate(
      s.weeklyBreakdown.length,
      (i) => '${AppStrings.weeklyStats} ${i + 1}',
    );
    final earningsValues = s.weeklyBreakdown
        .map((w) => w.earnings)
        .toList();

    return [
      _summaryGrid(
        totalOrders: s.totalOrders,
        earnings: s.earnings,
        successRate: s.successRate,
        netProfit: s.netProfit,
      ),
      if (s.weeklyBreakdown.isNotEmpty) ...[
        SizedBox(height: Responsive.h(20)),
        _sectionTitle(AppStrings.totalEarningsLabel, isDark),
        SizedBox(height: Responsive.h(8)),
        StatsBarChart(
          labels: weekLabels,
          values: earningsValues,
        ),
      ],
      SizedBox(height: Responsive.h(20)),
      _sectionTitle(AppStrings.moreDetails, isDark),
      SizedBox(height: Responsive.h(8)),
      SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(16),
          vertical: Responsive.h(8),
        ),
        child: Column(
          children: [
            StatDetailRow(
              icon: IconsaxPlusLinear.tick_circle,
              label: AppStrings.successful,
              value: '${s.successfulOrders}',
              iconColor: AppColors.success,
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.routing_2,
              label: AppStrings.totalDistance,
              value: '${s.distanceKm.toStringAsFixed(1)} ${AppStrings.km}',
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.clock,
              label: AppStrings.timeWorked,
              value: _formatMinutes(s.timeWorkedMinutes),
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.chart_1,
              label: AppStrings.avgDailyOrders,
              value: s.averageDailyOrders.toStringAsFixed(1),
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.money_recive,
              label: AppStrings.avgDailyEarnings,
              value: '${s.averageDailyEarnings.toInt()} ${AppStrings.currency}',
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.percentage_circle,
              label: AppStrings.commissions,
              value: '${s.commissions.toInt()} ${AppStrings.currency}',
            ),
            StatDetailRow(
              icon: IconsaxPlusLinear.money_send,
              label: AppStrings.expensesLabel,
              value: '${s.expenses.toInt()} ${AppStrings.currency}',
              iconColor: AppColors.error,
            ),
          ],
        ),
      ),
    ];
  }

  // ── Shared Widgets ──

  Widget _summaryGrid({
    required int totalOrders,
    required double earnings,
    required double successRate,
    required double netProfit,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: Responsive.h(12),
      crossAxisSpacing: Responsive.w(12),
      childAspectRatio: 1.25,
      children: [
        StatSummaryCard(
          label: AppStrings.totalOrders,
          value: '$totalOrders',
          icon: IconsaxPlusLinear.clipboard_text,
        ),
        StatSummaryCard(
          label: AppStrings.totalEarningsLabel,
          value: '${earnings.toInt()} ${AppStrings.currency}',
          icon: IconsaxPlusLinear.money_recive,
          iconColor: AppColors.success,
        ),
        StatSummaryCard(
          label: AppStrings.successRate,
          value: '${successRate.toInt()}%',
          icon: IconsaxPlusLinear.chart_success,
          iconColor: AppColors.info,
        ),
        StatSummaryCard(
          label: AppStrings.netProfit,
          value: '${netProfit.toInt()} ${AppStrings.currency}',
          icon: IconsaxPlusLinear.wallet_2,
          valueColor: netProfit >= 0 ? AppColors.success : AppColors.error,
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.titleLarge.copyWith(
        color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
      ),
    );
  }

  // ── Helpers ──

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0
          ? '$h ${AppStrings.hours} $m ${AppStrings.minutes}'
          : '$h ${AppStrings.hours}';
    }
    return '$minutes ${AppStrings.minutes}';
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  String _shortDayName(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final isAr = AppStrings.currentLang == 'ar';
      const arDays = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
      const enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return isAr ? arDays[date.weekday - 1] : enDays[date.weekday - 1];
    } catch (_) {
      return dateStr;
    }
  }
}

// ── Expandable Section Wrapper ──

class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ExpansionTile(
              initiallyExpanded: false,
              tilePadding: EdgeInsets.symmetric(
                horizontal: Responsive.w(16),
                vertical: Responsive.h(4),
              ),
              childrenPadding: EdgeInsets.only(
                right: Responsive.w(16),
                left: Responsive.w(16),
                bottom: Responsive.h(16),
              ),
              leading: Container(
                width: Responsive.r(36),
                height: Responsive.r(36),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Responsive.r(10)),
                ),
                child: Icon(icon, size: Responsive.r(18), color: iconColor),
              ),
              title: Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconColor:
                  isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              collapsedIconColor:
                  isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 1. Shift Summary Section ──

class _ShiftSummarySection extends StatelessWidget {
  const _ShiftSummarySection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShiftBloc, ShiftState>(
      builder: (context, state) {
        final summary =
            state is ShiftLoaded ? state.summary : null;

        return _ExpandableSection(
          title: AppStrings.shiftSummaryTitle,
          icon: IconsaxPlusLinear.timer_start,
          iconColor: AppColors.info,
          isDark: isDark,
          children: [
            if (summary != null)
              _ShiftStatsContent(summary: summary, isDark: isDark)
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                child: Center(
                  child: Text(
                    AppStrings.analyticsNoData,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ShiftStatsContent extends StatelessWidget {
  const _ShiftStatsContent({
    required this.summary,
    required this.isDark,
  });

  final ShiftSummaryEntity summary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ShiftMiniCard(
                icon: IconsaxPlusLinear.calendar_1,
                label: AppStrings.totalShifts,
                value: '${summary.totalShifts}',
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
            SizedBox(width: Responsive.w(8)),
            Expanded(
              child: _ShiftMiniCard(
                icon: IconsaxPlusLinear.clock,
                label: AppStrings.totalHoursWorked,
                value: '${summary.totalHoursWorked.toStringAsFixed(1)} ${AppStrings.hours}',
                color: AppColors.info,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(8)),
        Row(
          children: [
            Expanded(
              child: _ShiftMiniCard(
                icon: IconsaxPlusLinear.box_1,
                label: AppStrings.totalOrdersCompleted,
                value: '${summary.totalOrdersCompleted}',
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
            SizedBox(width: Responsive.w(8)),
            Expanded(
              child: _ShiftMiniCard(
                icon: IconsaxPlusLinear.money_recive,
                label: AppStrings.totalEarnings,
                value: '${summary.totalEarnings.toStringAsFixed(0)} ${AppStrings.currency}',
                color: AppColors.warning,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(8)),
        Row(
          children: [
            Expanded(
              child: _ShiftMiniCard(
                icon: IconsaxPlusLinear.routing_2,
                label: AppStrings.totalDistanceKm,
                value: summary.totalDistanceKm.toStringAsFixed(1),
                color: AppColors.statusReturned,
                isDark: isDark,
              ),
            ),
            SizedBox(width: Responsive.w(8)),
            Expanded(
              child: _ShiftMiniCard(
                icon: IconsaxPlusLinear.timer_1,
                label: AppStrings.avgShiftDuration,
                value: '${summary.averageShiftDurationHours.toStringAsFixed(1)} ${AppStrings.hours}',
                color: AppColors.statusOnTheWay,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShiftMiniCard extends StatelessWidget {
  const _ShiftMiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(12)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Responsive.r(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: Responsive.r(16), color: color),
          SizedBox(height: Responsive.h(6)),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Responsive.h(2)),
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: isDark
                  ? AppColors.textCaptionDark
                  : AppColors.textCaption,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── 2. Health Score Section ──

class _HealthScoreSection extends StatelessWidget {
  const _HealthScoreSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final healthScore = profileState is ProfileLoaded
            ? profileState.healthScore
            : null;

        return _ExpandableSection(
          title: AppStrings.healthScore,
          icon: IconsaxPlusLinear.health,
          iconColor: AppColors.success,
          isDark: isDark,
          children: [
            if (healthScore != null)
              HealthScoreCard(healthScore: healthScore)
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                child: Center(
                  child: Text(
                    AppStrings.analyticsNoData,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── 3. Analytics Section ──

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        return _ExpandableSection(
          title: AppStrings.analyticsTitle,
          icon: IconsaxPlusLinear.chart_1,
          iconColor: AppColors.primary,
          isDark: isDark,
          children: [
            if (state is AnalyticsLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                child: const SekkaLoading(),
              )
            else if (state is AnalyticsLoaded) ...[
              ProfitabilityTrendsCard(data: state.profitabilityTrends),
              SizedBox(height: Responsive.h(10)),
              TimeAnalysisCard(data: state.timeAnalysis),
              SizedBox(height: Responsive.h(10)),
              RegionAnalysisCard(data: state.regionAnalysis),
              SizedBox(height: Responsive.h(10)),
              SourceBreakdownCard(data: state.sourceBreakdown),
              SizedBox(height: Responsive.h(10)),
              CustomerProfitabilityCard(data: state.customerProfitability),
              SizedBox(height: Responsive.h(10)),
              CancellationReportCard(data: state.cancellationReport),
            ] else if (state is AnalyticsError)
              Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textBodyDark
                              : AppColors.textBody,
                        ),
                      ),
                      SizedBox(height: Responsive.h(8)),
                      TextButton(
                        onPressed: () => context
                            .read<AnalyticsBloc>()
                            .add(const AnalyticsLoadRequested()),
                        child: Text(
                          AppStrings.retry,
                          style: AppTypography.titleMedium
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                child: Center(
                  child: Text(
                    AppStrings.analyticsNoData,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
