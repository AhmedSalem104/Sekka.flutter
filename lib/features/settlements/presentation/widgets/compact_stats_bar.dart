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
    final s = widget.summary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(Responsive.r(20)),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(Responsive.r(20)),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(Responsive.r(20)),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.md,
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
                        color: _whiteSoft,
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
                        color: _whiteSoft,
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
                        label: AppStrings.settleCollectedShort,
                        value: s.totalCollected,
                      ),
                      TextSpan(
                        text: '  •  ',
                        style: AppTypography.bodySmall
                            .copyWith(color: _whiteSoft),
                      ),
                      _inlineMetric(
                        label: AppStrings.settleSettledShort,
                        value: s.totalSettled,
                      ),
                      TextSpan(
                        text: '  •  ',
                        style: AppTypography.bodySmall
                            .copyWith(color: _whiteSoft),
                      ),
                      _inlineMetric(
                        label: AppStrings.settleRemainingShort,
                        value: s.remainingBalance,
                        highlight: s.remainingBalance > 0,
                      ),
                    ],
                  ),
                  style: AppTypography.bodyMedium
                      .copyWith(color: _whiteSoft),
                  maxLines: 2,
                ),
                // Expanded details
                if (_expanded) ...[
                  SizedBox(height: AppSizes.md),
                  Divider(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                    height: 1,
                  ),
                  SizedBox(height: AppSizes.md),
                  _OrangeDetailRow(
                    icon: IconsaxPlusLinear.money_recive,
                    label: AppStrings.settleCollectedFromCustomers,
                    value: '${s.totalCollected.toStringAsFixed(0)} ${AppStrings.currency}',
                  ),
                  _OrangeDetailRow(
                    icon: IconsaxPlusLinear.money_send,
                    label: AppStrings.settleSettledToPartners,
                    value: '${s.totalSettled.toStringAsFixed(0)} ${AppStrings.currency}',
                  ),
                  _OrangeDetailRow(
                    icon: IconsaxPlusLinear.wallet_3,
                    label: AppStrings.settleRemainingWithYou,
                    value: '${s.remainingBalance.toStringAsFixed(0)} ${AppStrings.currency}',
                    highlight: s.remainingBalance > 0,
                  ),
                  _OrangeDetailRow(
                    icon: IconsaxPlusLinear.tick_circle,
                    label: AppStrings.settleCountToday,
                    value: '${s.settlementCount}',
                  ),
                ],
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  static const _whiteSoft = Color(0xDAFFFFFF); // 85% white
  static const _white = AppColors.textOnPrimary;

  TextSpan _inlineMetric({
    required String label,
    required double value,
    bool highlight = false,
  }) {
    return TextSpan(
      children: [
        TextSpan(
          text: '$label ',
          style: AppTypography.bodySmall.copyWith(color: _whiteSoft),
        ),
        TextSpan(
          text: value.toStringAsFixed(0),
          style: AppTypography.bodyMedium.copyWith(
            color: highlight ? _white : _whiteSoft,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _OrangeDetailRow extends StatelessWidget {
  const _OrangeDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  static const _whiteSoft = Color(0xDAFFFFFF);
  static const _white = AppColors.textOnPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Icon(
            icon,
            size: Responsive.r(16),
            color: highlight ? _white : _whiteSoft,
          ),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: _whiteSoft),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: highlight ? _white : _whiteSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
