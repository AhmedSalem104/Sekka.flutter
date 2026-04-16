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
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_hint_tip.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/cash_status_bar.dart';
import '../widgets/transaction_card.dart';
import '../widgets/wallet_summary_row.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<WalletBloc>();
    if (bloc.state is WalletLoaded) {
      bloc.add(const WalletRefreshRequested());
    } else {
      bloc.add(const WalletLoadRequested());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WalletBloc>().add(const WalletNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(
        title: AppStrings.walletTitle,
        showBack: false,
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listenWhen: (prev, curr) => curr is WalletError,
        listener: (context, state) {
          if (state is WalletError) {
            SekkaMessageDialog.show(context, message: state.message);
          }
        },
        buildWhen: (prev, curr) {
          if (prev is WalletLoaded && curr is WalletLoaded) {
            return prev.balance != curr.balance ||
                prev.transactions != curr.transactions ||
                prev.activeFilter != curr.activeFilter ||
                prev.isLoadingMore != curr.isLoadingMore ||
                prev.cashStatus != curr.cashStatus ||
                prev.summary != curr.summary;
          }
          return true;
        },
        builder: (context, state) {
          if (state is WalletLoading) return const SekkaLoading();
          if (state is WalletLoaded) return _buildContent(state, isDark);
          if (state is WalletError) return _buildError(state.message);
          return const SizedBox.shrink();
        },
      ),
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
            onPressed: () =>
                context.read<WalletBloc>().add(const WalletLoadRequested()),
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

  Widget _buildContent(WalletLoaded state, bool isDark) {
    final filterLabels = [
      AppStrings.allTransactions,
      AppStrings.incomeFilter,
      AppStrings.expenseFilter,
      AppStrings.settlementsFilter,
    ];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<WalletBloc>().add(const WalletRefreshRequested());
      },
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
        children: [
          SizedBox(height: AppSizes.lg),
          BalanceCard(balance: state.balance),
          SizedBox(height: AppSizes.sm),
          SekkaHintTip(
            hintKey: 'wallet_balance',
            message: AppStrings.hintWalletBalance,
          ),
          SizedBox(height: AppSizes.lg),
          CashStatusBar(
            status: state.cashStatus,
            onSettleTap: () => context.push(RouteNames.settlements),
          ),
          SizedBox(height: AppSizes.sm),
          SekkaHintTip(
            hintKey: 'wallet_cash_status',
            message: AppStrings.hintCashStatus,
          ),
          SizedBox(height: AppSizes.lg),
          WalletSummaryRow(summary: state.summary),
          SizedBox(height: AppSizes.sm),
          SekkaHintTip(
            hintKey: 'wallet_summary',
            message: AppStrings.hintWalletSummary,
          ),
          SizedBox(height: AppSizes.lg),

          // Invoices button
          Directionality(
            textDirection: TextDirection.rtl,
            child: SekkaCard(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(16),
                vertical: Responsive.h(14),
              ),
              onTap: () => context.push(RouteNames.invoices),
              child: Row(
                children: [
                  Container(
                    width: Responsive.r(40),
                    height: Responsive.r(40),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Responsive.r(10)),
                    ),
                    child: Icon(
                      IconsaxPlusLinear.receipt_item,
                      color: AppColors.primary,
                      size: Responsive.r(20),
                    ),
                  ),
                  SizedBox(width: Responsive.w(12)),
                  Expanded(
                    child: Text(
                      AppStrings.invoicesTitle,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    IconsaxPlusLinear.arrow_left_2,
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                    size: Responsive.r(18),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.xxl),

          // Filter tabs
          SizedBox(
            height: AppSizes.buttonHeight * 0.7,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filterLabels.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSizes.sm),
              itemBuilder: (context, index) {
                final isActive = state.activeFilter == index;
                return GestureDetector(
                  onTap: () => context
                      .read<WalletBloc>()
                      .add(WalletFilterChanged(index)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.border),
                        width: 0.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filterLabels[index],
                      style: AppTypography.titleMedium.copyWith(
                        color: isActive
                            ? AppColors.textOnPrimary
                            : (isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption),
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSizes.lg),

          // Transactions
          if (state.transactions.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.xxxl),
              child: Center(
                child: Text(
                  AppStrings.noTransactions,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textBodyDark
                        : AppColors.textBody,
                  ),
                ),
              ),
            )
          else
            ...state.transactions.map((t) => Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.sm),
                  child: TransactionCard(transaction: t),
                )),

          if (state.isLoadingMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),

          SizedBox(height: AppSizes.bottomNavHeight + AppSizes.md),
        ],
      ),
    );
  }
}
