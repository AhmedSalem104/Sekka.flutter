import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/daily_settlement_summary_entity.dart';

/// A one-line stats bar that shows today's cash flow summary, tappable to
/// expand into a detailed breakdown. Replaces the heavy gradient card.
class CompactStatsBar extends StatefulWidget {
  const CompactStatsBar({super.key, required this.summary});

  final DailySettlementSummaryEntity summary;

  @override
  State<CompactStatsBar> createState() => _CompactStatsBarState();
}

class _CompactStatsBarState extends State<CompactStatsBar> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = widget.summary;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row — always visible
                Row(
                  children: [
                    Text(
                      AppStrings.settleTodayLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textCaption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        IconsaxPlusLinear.arrow_down_1,
                        size: Responsive.r(14),
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(4)),
                // Single-line values
                Text.rich(
                  TextSpan(
                    children: [
                      _inlineMetric(
                        isDark: isDark,
                        label: AppStrings.settleCollectedShort,
                        value: s.totalCollected,
                      ),
                      const TextSpan(text: '  •  '),
                      _inlineMetric(
                        isDark: isDark,
                        label: AppStrings.settleSettledShort,
                        value: s.totalSettled,
                      ),
                      const TextSpan(text: '  •  '),
                      _inlineMetric(
                        isDark: isDark,
                        label: AppStrings.settleRemainingShort,
                        value: s.remainingBalance,
                        highlight: s.remainingBalance > 0,
                      ),
                    ],
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textBodyDark
                        : AppColors.textBody,
                  ),
                  maxLines: 2,
                ),
                // Expanded details
                if (_expanded) ...[
                  SizedBox(height: AppSizes.md),
                  _DetailRow(
                    icon: IconsaxPlusLinear.money_recive,
                    label: AppStrings.settleCollectedFromCustomers,
                    value: '${s.totalCollected.toStringAsFixed(0)} ${AppStrings.currency}',
                    isDark: isDark,
                  ),
                  _DetailRow(
                    icon: IconsaxPlusLinear.money_send,
                    label: AppStrings.settleSettledToPartners,
                    value: '${s.totalSettled.toStringAsFixed(0)} ${AppStrings.currency}',
                    isDark: isDark,
                  ),
                  _DetailRow(
                    icon: IconsaxPlusLinear.wallet_3,
                    label: AppStrings.settleRemainingWithYou,
                    value: '${s.remainingBalance.toStringAsFixed(0)} ${AppStrings.currency}',
                    isDark: isDark,
                    highlight: s.remainingBalance > 0,
                  ),
                  _DetailRow(
                    icon: IconsaxPlusLinear.tick_circle,
                    label: AppStrings.settleCountToday,
                    value: '${s.settlementCount}',
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextSpan _inlineMetric({
    required bool isDark,
    required String label,
    required double value,
    bool highlight = false,
  }) {
    return TextSpan(
      children: [
        TextSpan(
          text: '$label ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textCaption,
          ),
        ),
        TextSpan(
          text: value.toStringAsFixed(0),
          style: AppTypography.bodyMedium.copyWith(
            color: highlight
                ? AppColors.primary
                : (isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Icon(
            icon,
            size: Responsive.r(16),
            color: highlight ? AppColors.primary : AppColors.textCaption,
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
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: highlight
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
