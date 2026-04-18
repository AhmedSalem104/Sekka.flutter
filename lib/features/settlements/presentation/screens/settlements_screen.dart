import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:flutter_svg/flutter_svg.dart';

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
import '../utils/settlement_pdf_generator.dart';
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
        if (b == null) continue;
        if (b.pendingBalance > 0) {
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
          SizedBox(height: AppSizes.lg),

          // 2. Quick Actions row
          _SettlementQuickActions(state: state),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/settle_pending.svg',
            width: Responsive.w(180),
            height: Responsive.h(140),
          ),
          SizedBox(height: AppSizes.lg),
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
// ── Quick Actions Row ──
// ════════════════════════════════════════════════════════════════════════

class _SettlementQuickActions extends StatelessWidget {
  const _SettlementQuickActions({required this.state});
  final SettlementLoaded state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: _QuickChip(
            icon: IconsaxPlusLinear.money_send,
            label: AppStrings.newHandover,
            primary: true,
            isDark: isDark,
            onTap: () => context.push(RouteNames.createSettlement),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: _QuickChip(
            icon: IconsaxPlusLinear.add_circle,
            label: AppStrings.addPartner,
            isDark: isDark,
            onTap: () => showAddPartnerSheet(
              context,
              onPartnerCreated: () {
                context
                    .read<SettlementBloc>()
                    .add(const SettlementRefreshRequested());
              },
            ),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: _QuickChip(
            icon: IconsaxPlusLinear.clock_1,
            label: AppStrings.settleFullHistoryLink,
            isDark: isDark,
            onTap: () => context.push(RouteNames.settlementHistory),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: _QuickChip(
            icon: IconsaxPlusLinear.document_upload,
            label: AppStrings.settleShareSummary,
            isDark: isDark,
            onTap: () => _sharePdf(context),
          ),
        ),
      ],
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    final today = DateTime.now();
    final todaySettled = state.settlements
        .where((s) =>
            s.settledAt.year == today.year &&
            s.settledAt.month == today.month &&
            s.settledAt.day == today.day)
        .toList();

    final unsettled = <PartnerModel>[];
    for (final p in state.partners) {
      final b = state.partnerBalances[p.id];
      if (b != null && b.pendingBalance > 0) {
        unsettled.add(p);
      }
    }

    await SettlementPdfGenerator.generateAndShare(
      summary: state.summary,
      todaySettlements: todaySettled,
      unsettledPartners: unsettled,
      balances: state.partnerBalances,
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final bg = primary
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDark : AppColors.surface);
    final fg = primary
        ? AppColors.textOnPrimary
        : (isDark ? AppColors.textBodyDark : AppColors.textBody);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        splashColor: primary
            ? AppColors.textOnPrimary.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.15),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.md,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: primary
                      ? AppColors.textOnPrimary.withValues(alpha: 0.18)
                      : AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: primary ? AppColors.textOnPrimary : AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

