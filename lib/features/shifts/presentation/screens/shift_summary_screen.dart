import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_event.dart';
import '../../../analytics/presentation/bloc/analytics_state.dart';
import '../../../analytics/presentation/widgets/analytics_section.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/presentation/widgets/health_score_card.dart';
import '../../domain/entities/shift_summary_entity.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';
import '../bloc/shift_state.dart';

class ShiftSummaryScreen extends StatefulWidget {
  const ShiftSummaryScreen({super.key});

  @override
  State<ShiftSummaryScreen> createState() => _ShiftSummaryScreenState();
}

class _ShiftSummaryScreenState extends State<ShiftSummaryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShiftBloc>().add(const ShiftSummaryRequested());
    context.read<AnalyticsBloc>().add(const AnalyticsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.shiftPerformanceTitle),
      body: BlocBuilder<ShiftBloc, ShiftState>(
        builder: (context, state) {
          if (state is ShiftLoading) return const SekkaLoading();

          if (state is ShiftLoaded && state.summary != null) {
            final summary = state.summary!;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<ShiftBloc>().add(const ShiftSummaryRequested());
                context
                    .read<AnalyticsBloc>()
                    .add(const AnalyticsLoadRequested());
              },
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
                children: [
                  SizedBox(height: AppSizes.lg),

                  // Shift stats grid
                  _buildStatsGrid(context, isDark, summary),
                  SizedBox(height: AppSizes.xl),

                  // Health Score section from profile
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, profileState) {
                      if (profileState is ProfileLoaded &&
                          profileState.healthScore != null) {
                        return Column(
                          children: [
                            HealthScoreCard(
                              healthScore: profileState.healthScore!,
                            ),
                            SizedBox(height: AppSizes.xl),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Analytics section
                  _buildAnalyticsSection(isDark),

                  SizedBox(height: AppSizes.xxl),
                ],
              ),
            );
          }

          if (state is ShiftError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                  ),
                  SizedBox(height: AppSizes.lg),
                  TextButton(
                    onPressed: () => context
                        .read<ShiftBloc>()
                        .add(const ShiftSummaryRequested()),
                    child: Text(
                      AppStrings.retry,
                      style: AppTypography.titleMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SekkaLoading();
        },
      ),
    );
  }

  Widget _buildAnalyticsSection(bool isDark) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
            child: const SekkaLoading(),
          );
        }

        if (state is AnalyticsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  AppStrings.analyticsTitle,
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.lg),

              // 1. Profitability Trends
              ProfitabilityTrendsCard(data: state.profitabilityTrends),
              SizedBox(height: AppSizes.md),

              // 2. Time Analysis
              TimeAnalysisCard(data: state.timeAnalysis),
              SizedBox(height: AppSizes.md),

              // 3. Region Analysis
              RegionAnalysisCard(data: state.regionAnalysis),
              SizedBox(height: AppSizes.md),

              // 4. Source Breakdown
              SourceBreakdownCard(data: state.sourceBreakdown),
              SizedBox(height: AppSizes.md),

              // 5. Customer Profitability
              CustomerProfitabilityCard(data: state.customerProfitability),
              SizedBox(height: AppSizes.md),

              // 6. Cancellation Report
              CancellationReportCard(data: state.cancellationReport),
            ],
          );
        }

        if (state is AnalyticsError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                  ),
                  SizedBox(height: AppSizes.sm),
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
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    bool isDark,
    ShiftSummaryEntity summary,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: IconsaxPlusLinear.calendar_1,
                label: AppStrings.totalShifts,
                value: '${summary.totalShifts}',
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: _StatCard(
                icon: IconsaxPlusLinear.clock,
                label: AppStrings.totalHoursWorked,
                value: summary.totalHoursWorked.toStringAsFixed(1),
                suffix: AppStrings.hours,
                color: AppColors.info,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: IconsaxPlusLinear.box_1,
                label: AppStrings.totalOrdersCompleted,
                value: '${summary.totalOrdersCompleted}',
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: _StatCard(
                icon: IconsaxPlusLinear.money_recive,
                label: AppStrings.totalEarnings,
                value: summary.totalEarnings.toStringAsFixed(0),
                suffix: AppStrings.currency,
                color: AppColors.warning,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: IconsaxPlusLinear.routing_2,
                label: AppStrings.totalDistanceKm,
                value: summary.totalDistanceKm.toStringAsFixed(1),
                color: AppColors.statusReturned,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: _StatCard(
                icon: IconsaxPlusLinear.timer_1,
                label: AppStrings.avgShiftDuration,
                value: summary.averageShiftDurationHours.toStringAsFixed(1),
                suffix: AppStrings.hours,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.suffix,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Responsive.r(36),
              height: Responsive.r(36),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Responsive.r(10)),
              ),
              child: Icon(icon, size: Responsive.r(18), color: color),
            ),
            SizedBox(height: AppSizes.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (suffix != null) ...[
                  SizedBox(width: Responsive.w(4)),
                  Text(
                    suffix!,
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppSizes.xs),
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
      ),
    );
  }
}
