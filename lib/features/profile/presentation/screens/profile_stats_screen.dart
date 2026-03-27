import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../domain/entities/profile_stats_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

class ProfileStatsScreen extends StatelessWidget {
  const ProfileStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title:
            Text(AppStrings.detailedStats, style: AppTypography.headlineSmall),
        leading: const SekkaBackButton(),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is! ProfileLoaded) return const SekkaLoading();
          return _buildContent(context, state.stats, isDark);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProfileStatsEntity stats,
    bool isDark,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      children: [
        SizedBox(height: AppSizes.lg),

        // Main stats grid
        Row(
          children: [
            _StatCard(
              icon: IconsaxPlusLinear.box_1,
              label: AppStrings.totalOrders,
              value: '${stats.totalOrders}',
              isDark: isDark,
            ),
            SizedBox(width: AppSizes.sm),
            _StatCard(
              icon: IconsaxPlusLinear.tick_circle,
              label: AppStrings.delivered,
              value: '${stats.totalDelivered}',
              color: AppColors.success,
              isDark: isDark,
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        Row(
          children: [
            _StatCard(
              icon: IconsaxPlusLinear.close_circle,
              label: AppStrings.totalFailed,
              value: '${stats.totalFailed}',
              color: AppColors.error,
              isDark: isDark,
            ),
            SizedBox(width: AppSizes.sm),
            _StatCard(
              icon: IconsaxPlusLinear.slash,
              label: AppStrings.totalCancelled,
              value: '${stats.totalCancelled}',
              color: AppColors.textCaption,
              isDark: isDark,
            ),
          ],
        ),
        SizedBox(height: AppSizes.xxl),

        // Detail cards
        _DetailTile(
          icon: IconsaxPlusLinear.chart_2,
          label: AppStrings.successRate,
          value: '${stats.successRate.toStringAsFixed(1)}%',
          isDark: isDark,
        ),
        _DetailTile(
          icon: IconsaxPlusLinear.star_1,
          label: AppStrings.successRate,
          value: stats.averageRating.toStringAsFixed(1),
          isDark: isDark,
        ),
        _DetailTile(
          icon: IconsaxPlusLinear.money_recive,
          label: AppStrings.totalEarningsLabel,
          value: '${stats.totalEarnings.toStringAsFixed(0)} ${AppStrings.currency}',
          isDark: isDark,
        ),
        _DetailTile(
          icon: IconsaxPlusLinear.percentage_circle,
          label: AppStrings.todayCommissions,
          value: '${stats.totalCommissions.toStringAsFixed(0)} ${AppStrings.currency}',
          isDark: isDark,
        ),
        _DetailTile(
          icon: IconsaxPlusLinear.timer_1,
          label: AppStrings.avgDeliveryTime,
          value: '${stats.averageDeliveryTimeMinutes.toStringAsFixed(0)} ${AppStrings.minutes}',
          isDark: isDark,
        ),
        if (stats.bestDay != null)
          _DetailTile(
            icon: IconsaxPlusLinear.crown_1,
            label: AppStrings.bestDay,
            value: '${stats.bestDay} (${stats.bestDayOrders} ${AppStrings.orders})',
            isDark: isDark,
          ),

        SizedBox(height: AppSizes.xxxl),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;

    return Expanded(
      child: Container(
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
          children: [
            Container(
              width: Responsive.r(36),
              height: Responsive.r(36),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(icon, size: AppSizes.iconMd, color: c),
            ),
            SizedBox(height: AppSizes.md),
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color:
                    isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color:
                    isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.primary),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color:
                  isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
            ),
          ),
        ],
      ),
    );
  }
}
