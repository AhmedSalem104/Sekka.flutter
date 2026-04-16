import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../partners/data/models/partner_model.dart';
import '../bloc/settlement_bloc.dart';
import '../widgets/add_partner_sheet.dart';
import '../widgets/compact_stats_bar.dart';
import '../widgets/onboarding_overlay.dart';
import '../widgets/settlement_history_item.dart';
import '../widgets/unsettled_partner_tile.dart';

/// Settlements tab — reimagined as a "handover checklist" rather than a
/// ledger view.
///
/// Layout (top to bottom):
///   1. Compact one-line stats bar (expandable) — today's collected/settled
///   2. Unsettled partners list — the driver's primary focus
///   3. Today's completed settlements (small, reassurance section)
///   4. Footer: "+ شريك جديد" and link to full history
class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<SettlementBloc>();
    if (bloc.state is SettlementLoaded) {
      bloc.add(const SettlementRefreshRequested());
    } else {
      bloc.add(const SettlementsLoadRequested());
    }
    _checkOnboarding();
    _loadAllPartnerBalances();
  }

  Future<void> _checkOnboarding() async {
    final seen = await hasSeenSettlementOnboarding();
    if (!seen && mounted) {
      setState(() => _showOnboarding = true);
    }
  }

  /// Proactively fetch balances for every partner in parallel (single event,
  /// handled with Future.wait in the bloc). Much faster than firing a
  /// PartnerBalanceRequested per partner (which serializes).
  void _loadAllPartnerBalances() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<SettlementBloc>()
          .add(const AllPartnerBalancesRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.background,
          appBar: SekkaAppBar(
            title: AppStrings.accountHandover,
            showBack: false,
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: AppSizes.bottomNavHeight + 8),
            child: FloatingActionButton.extended(
              heroTag: 'settlements_fab',
              onPressed: () => context.push(RouteNames.createSettlement),
              backgroundColor: AppColors.primary,
              icon: const Icon(
                IconsaxPlusLinear.add,
                color: AppColors.textOnPrimary,
              ),
              label: Text(
                AppStrings.newHandover,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          body: BlocConsumer<SettlementBloc, SettlementState>(
            listenWhen: (prev, curr) =>
                curr is SettlementError || curr is SettlementCreated,
            listener: (context, state) {
              if (state is SettlementError) {
                SekkaMessageDialog.show(context, message: state.message);
              }
              if (state is SettlementCreated) {
                context
                    .read<SettlementBloc>()
                    .add(const SettlementRefreshRequested());
                // After refresh, re-load balances to reflect the new settlement.
                _loadAllPartnerBalances();
              }
            },
            buildWhen: (prev, curr) =>
                curr is! SettlementCreated &&
                    prev.runtimeType != curr.runtimeType ||
                (prev is SettlementLoaded &&
                    curr is SettlementLoaded &&
                    prev != curr),
            builder: (context, state) {
              if (state is SettlementLoading) return const SekkaLoading();
              if (state is SettlementLoaded) {
                return _buildContent(state, isDark);
              }
              if (state is SettlementError) {
                return _buildError(state.message);
              }
              return const SizedBox.shrink();
            },
          ),
        ),

        // Onboarding overlay
        if (_showOnboarding)
          SettlementOnboardingOverlay(
            onDismiss: () => setState(() => _showOnboarding = false),
          ),
      ],
    );
  }

  Widget _buildError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          TextButton(
            onPressed: () => context
                .read<SettlementBloc>()
                .add(const SettlementsLoadRequested()),
            child: Text(
              AppStrings.retry,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SettlementLoaded state, bool isDark) {
    // Balances are still loading in batch → show skeleton, don't flash the
    // full partner list only to filter it down a second later.
    final balancesPending = state.isLoadingBalances ||
        (state.partners.isNotEmpty && state.partnerBalances.isEmpty);

    // Partners who actually owe us money (pendingBalance > 0 OR orders
    // still in flight). Only computed once balances are known.
    final unsettled = <PartnerModel>[];
    if (!balancesPending) {
      for (final p in state.partners) {
        final b = state.partnerBalances[p.id];
        if (b == null) continue; // silently failed fetch — skip, don't mislead
        if (b.pendingBalance > 0 || b.pendingOrderCount > 0) {
          unsettled.add(p);
        }
      }
    }

    // Today's completed settlements only.
    final today = DateTime.now();
    final todaySettled = state.settlements
        .where((s) =>
            s.settledAt.year == today.year &&
            s.settledAt.month == today.month &&
            s.settledAt.day == today.day)
        .toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context
            .read<SettlementBloc>()
            .add(const SettlementRefreshRequested());
        _loadAllPartnerBalances();
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.lg,
          AppSizes.pagePadding,
          AppSizes.bottomNavHeight + AppSizes.xxxl,
        ),
        children: [
          // 1. Compact stats bar (tappable to expand)
          CompactStatsBar(summary: state.summary),
          SizedBox(height: AppSizes.xl),

          // 2. Unsettled partners checklist (the primary focus)
          if (state.partners.isEmpty)
            _EmptyPartnersState(isDark: isDark)
          else if (balancesPending)
            _BalancesLoadingSkeleton(
              count: state.partners.length.clamp(1, 4),
              isDark: isDark,
            )
          else if (unsettled.isEmpty)
            _AllSettledState(isDark: isDark)
          else ...[
            _SectionHeader(
              title: AppStrings.settleUnsettledTitle,
              badge: '${unsettled.length}',
              isDark: isDark,
            ),
            SizedBox(height: AppSizes.sm),
            for (final p in unsettled) ...[
              UnsettledPartnerTile(
                partner: p,
                balance: state.partnerBalances[p.id],
              ),
              SizedBox(height: AppSizes.xs),
            ],
          ],

          SizedBox(height: AppSizes.xl),

          // 3. Today's completed settlements
          if (todaySettled.isNotEmpty) ...[
            _SectionHeader(
              title: AppStrings.settleTodayCompletedTitle,
              badge: '${todaySettled.length}',
              isDark: isDark,
              muted: true,
            ),
            SizedBox(height: AppSizes.sm),
            for (final s in todaySettled) ...[
              SettlementHistoryItem(settlement: s),
              SizedBox(height: AppSizes.xs),
            ],
            SizedBox(height: AppSizes.xl),
          ],

          // 4. Footer: Add partner + Full history link
          _FooterActions(
            hasHistory: state.settlements.length > todaySettled.length,
          ),
          SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Section header ──
// ════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.isDark,
    this.badge,
    this.muted = false,
  });

  final String title;
  final bool isDark;
  final String? badge;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: muted
                  ? AppColors.textCaption
                  : (isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (badge != null) ...[
            SizedBox(width: AppSizes.xs),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.xs,
                vertical: Responsive.h(2),
              ),
              decoration: BoxDecoration(
                color: muted
                    ? (isDark ? AppColors.backgroundDark : AppColors.background)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.chipRadius),
              ),
              child: Text(
                badge!,
                style: AppTypography.captionSmall.copyWith(
                  color: muted ? AppColors.textCaption : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Empty states ──
// ════════════════════════════════════════════════════════════════════════

class _BalancesLoadingSkeleton extends StatelessWidget {
  const _BalancesLoadingSkeleton({
    required this.count,
    required this.isDark,
  });

  final int count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: AppStrings.settleUnsettledTitle,
          isDark: isDark,
          muted: true,
        ),
        SizedBox(height: AppSizes.sm),
        for (var i = 0; i < count; i++) ...[
          Container(
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Row(
              children: [
                Container(
                  width: Responsive.r(40),
                  height: Responsive.r(40),
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: Responsive.w(120),
                        height: Responsive.h(12),
                        decoration: BoxDecoration(
                          color: AppColors.border.withValues(alpha: 0.5),
                          borderRadius:
                              BorderRadius.circular(AppSizes.chipRadius),
                        ),
                      ),
                      SizedBox(height: Responsive.h(8)),
                      Container(
                        width: Responsive.w(80),
                        height: Responsive.h(10),
                        decoration: BoxDecoration(
                          color: AppColors.border.withValues(alpha: 0.3),
                          borderRadius:
                              BorderRadius.circular(AppSizes.chipRadius),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.xs),
        ],
      ],
    );
  }
}

class _AllSettledState extends StatelessWidget {
  const _AllSettledState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        children: [
          Icon(
            IconsaxPlusBold.tick_circle,
            color: AppColors.success,
            size: AppSizes.iconXl,
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            AppStrings.settleAllDoneTitle,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Responsive.h(4)),
          Text(
            AppStrings.settleAllDoneSubtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textCaption,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyPartnersState extends StatelessWidget {
  const _EmptyPartnersState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SekkaEmptyState(
      icon: IconsaxPlusLinear.shop,
      title: AppStrings.settleEmptyStateTitle,
      description: AppStrings.settleEmptyStateSubtitle,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Footer actions ──
// ════════════════════════════════════════════════════════════════════════

class _FooterActions extends StatelessWidget {
  const _FooterActions({required this.hasHistory});
  final bool hasHistory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FooterChip(
          icon: IconsaxPlusLinear.add_circle,
          label: AppStrings.addPartner,
          onTap: () => showAddPartnerSheet(
            context,
            onPartnerCreated: () {
              context
                  .read<SettlementBloc>()
                  .add(const SettlementRefreshRequested());
            },
          ),
        ),
        if (hasHistory) ...[
          SizedBox(height: AppSizes.sm),
          _FooterChip(
            icon: IconsaxPlusLinear.clock_1,
            label: AppStrings.settleFullHistoryLink,
            onTap: () =>
                context.push(RouteNames.settlementHistory),
          ),
        ],
      ],
    );
  }
}

class _FooterChip extends StatelessWidget {
  const _FooterChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppSizes.iconSm,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                IconsaxPlusLinear.arrow_left_2,
                size: AppSizes.iconSm,
                color: AppColors.textCaption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

