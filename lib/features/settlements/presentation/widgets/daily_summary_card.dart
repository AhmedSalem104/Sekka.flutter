import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/bloc/daily_stats_bloc.dart';
import '../../domain/entities/daily_settlement_summary_entity.dart';
import '../utils/settlement_helpers.dart';

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({super.key, required this.summary});

  final DailySettlementSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.xxl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dailySummary,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: AppStrings.totalCollectedToday,
                  value: '${formatAmount(summary.totalCollected)} ${AppStrings.currency}',
                ),
              ),
              Expanded(
                child: _SummaryStat(
                  label: AppStrings.totalSettledToday,
                  value: '${formatAmount(summary.totalSettled)} ${AppStrings.currency}',
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: AppStrings.remainingBalance,
                  value: '${formatAmount(summary.remainingBalance)} ${AppStrings.currency}',
                ),
              ),
              Expanded(
                child: _SummaryStat(
                  label: AppStrings.settlementCountToday,
                  value: '${summary.settlementCount}',
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),

          // Today's earnings
          BlocBuilder<DailyStatsBloc, DailyStatsState>(
            builder: (context, statsState) {
              final stats =
                  statsState is DailyStatsLoaded ? statsState.stats : null;
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryStat(
                        label: AppStrings.invoiceNetAmount,
                        value: stats != null
                            ? '${stats.netProfit.toInt()} ${AppStrings.currency}'
                            : '--',
                      ),
                    ),
                    Expanded(
                      child: _SummaryStat(
                        label: AppStrings.invoiceCommissions,
                        value: stats != null
                            ? '${stats.commissions.toInt()} ${AppStrings.currency}'
                            : '--',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.85),
          ),
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
