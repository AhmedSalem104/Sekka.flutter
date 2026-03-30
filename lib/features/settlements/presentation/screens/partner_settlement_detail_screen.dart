import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../partners/data/models/partner_model.dart';
import '../../domain/entities/partner_balance_entity.dart';
import '../bloc/settlement_bloc.dart';
import '../utils/settlement_helpers.dart';
import '../widgets/settlement_history_item.dart';

class PartnerSettlementDetailScreen extends StatefulWidget {
  const PartnerSettlementDetailScreen({super.key, required this.partner});

  final PartnerModel partner;

  @override
  State<PartnerSettlementDetailScreen> createState() =>
      _PartnerSettlementDetailScreenState();
}

class _PartnerSettlementDetailScreenState
    extends State<PartnerSettlementDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load balance for this partner
    context
        .read<SettlementBloc>()
        .add(PartnerBalanceRequested(widget.partner.id));
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final partnerColor = _parseColor(widget.partner.color);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.partnerDetails),
      body: BlocBuilder<SettlementBloc, SettlementState>(
        builder: (context, state) {
          if (state is! SettlementLoaded) return const SekkaLoading();

          final balance = state.partnerBalances[widget.partner.id];
          final partnerSettlements = state.settlements
              .where((s) => s.partnerId == widget.partner.id)
              .toList();

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            children: [
              SizedBox(height: AppSizes.lg),

              // Partner header
              _buildHeader(isDark, partnerColor),
              SizedBox(height: AppSizes.lg),

              // Balance card
              if (balance != null) ...[
                _buildBalanceCard(balance, isDark),
                SizedBox(height: AppSizes.xxl),
              ],

              // Quick action
              SekkaButton(
                label: AppStrings.newHandover,
                icon: IconsaxPlusLinear.money_send,
                onPressed: () => context.push(
                  RouteNames.createSettlement,
                  extra: widget.partner,
                ),
              ),
              SizedBox(height: AppSizes.xxl),

              // Settlement history
              Text(
                AppStrings.handoverHistory,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
              SizedBox(height: AppSizes.md),

              if (partnerSettlements.isEmpty)
                SekkaEmptyState(
                  icon: IconsaxPlusLinear.money_send,
                  title: AppStrings.noSettlements,
                )
              else
                ...partnerSettlements.map(
                  (s) => Padding(
                    padding: EdgeInsets.only(bottom: AppSizes.sm),
                    child: SettlementHistoryItem(settlement: s),
                  ),
                ),

              SizedBox(height: AppSizes.xxxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color partnerColor) {
    return Container(
      padding: EdgeInsets.all(AppSizes.xxl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarLg,
            height: AppSizes.avatarLg,
            decoration: BoxDecoration(
              color: partnerColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.partner.name.isNotEmpty ? widget.partner.name[0] : '?',
              style: AppTypography.headlineLarge.copyWith(
                color: partnerColor,
              ),
            ),
          ),
          SizedBox(width: AppSizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.partner.name,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                if (widget.partner.address != null) ...[
                  SizedBox(height: AppSizes.xs),
                  Text(
                    widget.partner.address!,
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(PartnerBalanceEntity balance, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSizes.xxl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.partnerBalance,
            style: AppTypography.titleMedium.copyWith(
              color:
                  isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: AppStrings.totalCollectedToday,
                  value: formatAmount(balance.totalCollected),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _BalanceStat(
                  label: AppStrings.totalSettledToday,
                  value: formatAmount(balance.totalSettled),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: AppStrings.pendingBalance,
                  value: formatAmount(balance.pendingBalance),
                  isDark: isDark,
                  valueColor: balance.pendingBalance > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
              Expanded(
                child: _BalanceStat(
                  label: AppStrings.pendingOrderCount,
                  value: '${balance.pendingOrderCount}',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.captionSmall.copyWith(
            color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
          ),
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: valueColor ??
                (isDark ? AppColors.textHeadlineDark : AppColors.textHeadline),
          ),
        ),
      ],
    );
  }
}
