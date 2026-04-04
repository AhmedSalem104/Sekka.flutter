import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/health_score_entity.dart';

class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({super.key, required this.healthScore});

  final HealthScoreEntity healthScore;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(healthScore.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.xl),
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
        children: [
          // Title row with overall score
          Row(
            children: [
              Container(
                width: Responsive.r(40),
                height: Responsive.r(40),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusBold.health,
                  size: Responsive.r(20),
                  color: statusColor,
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.healthScore,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Row(
                      children: [
                        Text(
                          _statusLabel(healthScore.status),
                          style: AppTypography.captionSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: AppSizes.sm),
                        Icon(
                          _trendIcon(healthScore.trend),
                          size: Responsive.r(14),
                          color: _trendColor(healthScore.trend),
                        ),
                        SizedBox(width: AppSizes.xs),
                        Text(
                          _trendLabel(healthScore.trend),
                          style: AppTypography.captionSmall.copyWith(
                            color: _trendColor(healthScore.trend),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Circular score
              _CircularScore(
                score: healthScore.overallScore,
                color: statusColor,
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),
          Divider(
            color: isDark ? AppColors.borderDark : AppColors.border,
            height: 1,
          ),
          SizedBox(height: AppSizes.lg),

          // Sub-scores
          _ScoreRow(
            label: AppStrings.successRateScore,
            score: healthScore.successRateScore,
            icon: IconsaxPlusLinear.tick_circle,
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.md),
          _ScoreRow(
            label: AppStrings.customerRatingScore,
            score: healthScore.customerRatingScore,
            icon: IconsaxPlusLinear.star_1,
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.md),
          _ScoreRow(
            label: AppStrings.commitmentScore,
            score: healthScore.commitmentScore,
            icon: IconsaxPlusLinear.timer_1,
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.md),
          _ScoreRow(
            label: AppStrings.activityScore,
            score: healthScore.activityScore,
            icon: IconsaxPlusLinear.activity,
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.md),
          _ScoreRow(
            label: AppStrings.cashHandlingScore,
            score: healthScore.cashHandlingScore,
            icon: IconsaxPlusLinear.money_recive,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    return switch (status.toLowerCase()) {
      'good' || 'excellent' => AppColors.success,
      'average' || 'fair' => AppColors.warning,
      'poor' || 'bad' => AppColors.error,
      _ => AppColors.info,
    };
  }

  static String _statusLabel(String status) {
    return switch (status.toLowerCase()) {
      'good' || 'excellent' => AppStrings.healthStatusGood,
      'average' || 'fair' => AppStrings.healthStatusAverage,
      'poor' || 'bad' => AppStrings.healthStatusPoor,
      _ => status,
    };
  }

  static IconData _trendIcon(String trend) {
    return switch (trend.toLowerCase()) {
      'improving' || 'up' => IconsaxPlusLinear.arrow_up_3,
      'declining' || 'down' => IconsaxPlusLinear.arrow_down,
      _ => IconsaxPlusLinear.minus,
    };
  }

  static Color _trendColor(String trend) {
    return switch (trend.toLowerCase()) {
      'improving' || 'up' => AppColors.success,
      'declining' || 'down' => AppColors.error,
      _ => AppColors.textCaption,
    };
  }

  static String _trendLabel(String trend) {
    return switch (trend.toLowerCase()) {
      'improving' || 'up' => AppStrings.trendUp,
      'declining' || 'down' => AppStrings.trendDown,
      _ => AppStrings.trendStable,
    };
  }
}

class _CircularScore extends StatelessWidget {
  const _CircularScore({
    required this.score,
    required this.color,
  });

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Responsive.r(56),
      height: Responsive.r(56),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: Responsive.r(56),
            height: Responsive.r(56),
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 4,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$score',
            style: AppTypography.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.score,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final int score;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);

    return Row(
      children: [
        Icon(
          icon,
          size: Responsive.r(16),
          color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        SizedBox(
          width: Responsive.w(100),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: Responsive.h(6),
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        SizedBox(
          width: Responsive.w(32),
          child: Text(
            '$score',
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  static Color _scoreColor(int score) {
    if (score >= 75) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }
}
