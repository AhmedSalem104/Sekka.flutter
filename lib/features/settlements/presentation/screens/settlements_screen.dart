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
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../bloc/settlement_bloc.dart';
import '../widgets/add_partner_sheet.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/onboarding_overlay.dart';
import '../widgets/partner_balance_tile.dart';
import '../widgets/settlement_history_item.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  final _scrollController = ScrollController();
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    context.read<SettlementBloc>().add(const SettlementsLoadRequested());
    _scrollController.addListener(_onScroll);
    _checkOnboarding();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkOnboarding() async {
    final seen = await hasSeenSettlementOnboarding();
    if (!seen && mounted) {
      setState(() => _showOnboarding = true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SettlementBloc>().add(const SettlementsNextPage());
    }
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
              onPressed: () => context.push(RouteNames.createSettlement),
              backgroundColor: AppColors.primary,
              icon: const Icon(IconsaxPlusLinear.add, color: AppColors.textOnPrimary),
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
            listener: (context, state) {
              if (state is SettlementError) {
                SekkaMessageDialog.show(context, message: state.message);
              }
              if (state is SettlementCreated) {
                context
                    .read<SettlementBloc>()
                    .add(const SettlementRefreshRequested());
              }
            },
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: AppTypography.bodyMedium),
          SizedBox(height: AppSizes.lg),
          TextButton(
            onPressed: () => context
                .read<SettlementBloc>()
                .add(const SettlementsLoadRequested()),
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

  Widget _buildContent(SettlementLoaded state, bool isDark) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context
            .read<SettlementBloc>()
            .add(const SettlementRefreshRequested());
      },
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
        children: [
          SizedBox(height: AppSizes.lg),

          // Daily summary
          DailySummaryCard(summary: state.summary),
          SizedBox(height: AppSizes.xxl),

          // Partners section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.partners,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
              GestureDetector(
                onTap: () => showAddPartnerSheet(
                  context,
                  onPartnerCreated: () {
                    context
                        .read<SettlementBloc>()
                        .add(const SettlementRefreshRequested());
                  },
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusLinear.add_circle,
                      size: AppSizes.iconSm,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      AppStrings.addPartner,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          if (state.partners.isNotEmpty) ...[
            ...state.partners.map(
              (partner) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm),
                child: PartnerBalanceTile(
                  partner: partner,
                  balance: state.partnerBalances[partner.id],
                  onTap: () {
                    // Load balance if not cached
                    if (!state.partnerBalances.containsKey(partner.id)) {
                      context
                          .read<SettlementBloc>()
                          .add(PartnerBalanceRequested(partner.id));
                    }
                    context.push(
                      RouteNames.partnerSettlementDetail,
                      extra: partner,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: AppSizes.xxl),
          ],

          // Settlement history header
          Text(
            AppStrings.handoverHistory,
            style: AppTypography.titleMedium.copyWith(
              color:
                  isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
            ),
          ),
          SizedBox(height: AppSizes.md),

          // Settlement list
          if (state.settlements.isEmpty)
            SekkaEmptyState(
              icon: IconsaxPlusLinear.money_send,
              title: AppStrings.noSettlements,
            )
          else
            ...state.settlements.map(
              (s) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm),
                child: SettlementHistoryItem(settlement: s),
              ),
            ),

          // Loading more indicator
          if (state.isLoadingMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),

          SizedBox(height: AppSizes.xxxl * 2),
        ],
      ),
    );
  }
}
