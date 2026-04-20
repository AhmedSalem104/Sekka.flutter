import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/wallet_bloc.dart';
import '../utils/wallet_pdf_generator.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/transaction_card.dart';

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
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(
        title: AppStrings.walletNavLabel,
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
                prev.isLoadingMore != curr.isLoadingMore;
          }
          return true;
        },
        builder: (context, state) {
          if (state is WalletLoading) return const SekkaLoading();
          if (state is WalletLoaded) return _buildContent(state, isDark);
          if (state is WalletError) return _buildError(state.message, isDark);
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(String message, bool isDark) {
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
              style:
                  AppTypography.titleMedium.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePdf(WalletLoaded state) async {
    await WalletPdfGenerator.generateAndShare(
      balance: state.balance,
      summary: state.summary,
      transactions: state.transactions,
    );
  }

  Widget _buildContent(WalletLoaded state, bool isDark) {
    final filterLabels = [
      AppStrings.allTransactions,
      AppStrings.incomeFilter,
      AppStrings.expenseFilter,
      AppStrings.settlementsFilter,
    ];

    final grouped = _groupByDate(state.transactions);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<WalletBloc>().add(const WalletRefreshRequested());
      },
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.lg,
          AppSizes.pagePadding,
          Responsive.h(120),
        ),
        children: [
          // 1. Hero — one clear number
          _WalletHero(
            netBalance: state.summary.netBalance,
            pendingSettlements: state.balance.pendingSettlements,
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.lg),

          // 2. Quick actions
          Row(
            children: [
              Expanded(
                child: _QuickChip(
                  icon: IconsaxPlusLinear.receipt_item,
                  label: AppStrings.invoicesTitle,
                  isDark: isDark,
                  onTap: () => context.push(RouteNames.invoices),
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _QuickChip(
                  icon: IconsaxPlusLinear.chart_2,
                  label: AppStrings.homeQuickToday,
                  isDark: isDark,
                  onTap: () => context.push(RouteNames.detailedStats),
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: _QuickChip(
                  icon: IconsaxPlusLinear.document_upload,
                  label: AppStrings.walletSharePdf,
                  isDark: isDark,
                  onTap: () => _sharePdf(state),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.xl),

          // 3. Filter tabs (full width)
          Row(
            children: List.generate(filterLabels.length, (index) {
              final isActive = state.activeFilter == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index > 0 ? AppSizes.xs : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => context
                        .read<WalletBloc>()
                        .add(WalletFilterChanged(index)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface),
                        borderRadius:
                            BorderRadius.circular(AppSizes.chipRadius),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filterLabels[index],
                        style: AppTypography.captionSmall.copyWith(
                          color: isActive
                              ? AppColors.textOnPrimary
                              : (isDark
                                  ? AppColors.textBodyDark
                                  : AppColors.textBody),
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: AppSizes.lg),

          // 4. Transactions grouped by date
          if (state.transactions.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.xxxl),
              child: Center(
                child: Text(
                  AppStrings.noTransactions,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textCaption,
                  ),
                ),
              ),
            )
          else
            for (final entry in grouped.entries) ...[
              _DateHeader(date: entry.key, isDark: isDark),
              SizedBox(height: AppSizes.xs),
              for (final t in entry.value) ...[
                TransactionCard(transaction: t),
                SizedBox(height: AppSizes.xs),
              ],
              SizedBox(height: AppSizes.md),
            ],

          if (state.isLoadingMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  /// Group transactions by date (day).
  Map<DateTime, List<TransactionEntity>> _groupByDate(
    List<TransactionEntity> transactions,
  ) {
    final map = <DateTime, List<TransactionEntity>>{};
    for (final t in transactions) {
      final key =
          DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Hero ──
// ════════════════════════════════════════════════════════════════════════

class _WalletHero extends StatelessWidget {
  const _WalletHero({
    required this.netBalance,
    required this.pendingSettlements,
    required this.isDark,
  });

  final double netBalance;
  final double pendingSettlements;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(Responsive.r(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.walletMoneyWithYou,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                netBalance.toStringAsFixed(0),
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: Responsive.w(6)),
              Text(
                AppStrings.currency,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          if (pendingSettlements > 0) ...[
            SizedBox(height: AppSizes.md),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    IconsaxPlusBold.info_circle,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                    size: Responsive.r(16),
                  ),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      '${AppStrings.walletPendingNote} ${pendingSettlements.toStringAsFixed(0)} ${AppStrings.currency}',
                      style: AppTypography.bodySmall.copyWith(
                        color:
                            AppColors.textOnPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        context.push(RouteNames.createSettlement),
                    borderRadius:
                        BorderRadius.circular(AppSizes.chipRadius),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: Responsive.h(4),
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.textOnPrimary.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppSizes.chipRadius),
                      ),
                      child: Text(
                        AppStrings.settleNow,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Quick action chip ──
// ════════════════════════════════════════════════════════════════════════

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        splashColor: AppColors.primary.withValues(alpha: 0.15),
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
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
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

// ════════════════════════════════════════════════════════════════════════
// ── Date header ──
// ════════════════════════════════════════════════════════════════════════

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date, required this.isDark});
  final DateTime date;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String label;
    if (date == today) {
      label = AppStrings.walletToday;
    } else if (date == yesterday) {
      label = AppStrings.walletYesterday;
    } else {
      label = DateFormat('d MMMM yyyy', AppStrings.currentLang).format(date);
    }

    return Padding(
      padding: EdgeInsets.only(top: AppSizes.sm),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textCaption,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
