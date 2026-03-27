import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
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
    context.read<WalletBloc>().add(const WalletLoadRequested());
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
      appBar: AppBar(
        title: Text(AppStrings.walletTitle, style: AppTypography.headlineSmall),
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            SekkaMessageDialog.show(context, message: state.message);
          }
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: AppTypography.bodyMedium),
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
          SizedBox(height: AppSizes.lg),
          CashStatusBar(
            status: state.cashStatus,
            onSettleTap: () => context.push(RouteNames.settlements),
          ),
          SizedBox(height: AppSizes.lg),
          WalletSummaryRow(summary: state.summary),
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
                          : isDark
                              ? AppColors.surfaceDark
                              : AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filterLabels[index],
                      style: AppTypography.bodySmall.copyWith(
                        color: isActive
                            ? AppColors.textOnPrimary
                            : isDark
                                ? AppColors.textBodyDark
                                : AppColors.textBody,
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
                  style: AppTypography.bodyMedium,
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

          SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }
}
