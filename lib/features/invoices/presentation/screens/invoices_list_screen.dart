import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_summary_entity.dart';
import '../bloc/invoices_bloc.dart';
import '../bloc/invoices_event.dart';
import '../bloc/invoices_state.dart';
import 'invoice_detail_screen.dart';

class InvoicesListScreen extends StatelessWidget {
  const InvoicesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.invoicesTitle),
      body: BlocConsumer<InvoicesBloc, InvoicesState>(
        listenWhen: (prev, curr) =>
            curr is InvoicesLoaded && curr.actionMessage != null,
        listener: (context, state) {
          if (state is InvoicesLoaded && state.actionMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage!),
                backgroundColor: state.isActionError
                    ? AppColors.error
                    : AppColors.success,
              ),
            );
            context
                .read<InvoicesBloc>()
                .add(const InvoicesClearMessage());
          }
        },
        buildWhen: (prev, curr) {
          if (prev is InvoicesLoaded && curr is InvoicesLoaded) {
            return prev.invoices != curr.invoices ||
                prev.summary != curr.summary ||
                prev.statusFilter != curr.statusFilter ||
                prev.isLoadingMore != curr.isLoadingMore;
          }
          return true;
        },
        builder: (context, state) => switch (state) {
          InvoicesInitial() || InvoicesLoading() =>
            const SekkaShimmerList(itemCount: 5),
          InvoicesError(:final message) => SekkaEmptyState(
              icon: IconsaxPlusLinear.warning_2,
              title: message,
              actionLabel: AppStrings.retry,
              onAction: () => context
                  .read<InvoicesBloc>()
                  .add(const InvoicesLoadRequested()),
            ),
          InvoicesLoaded() => _buildContent(context, state, isDark),
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    InvoicesLoaded state,
    bool isDark,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => context
          .read<InvoicesBloc>()
          .add(const InvoicesRefreshRequested()),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
        children: [
          SizedBox(height: AppSizes.lg),
          _buildSummaryCard(state.summary, isDark),
          SizedBox(height: AppSizes.lg),
          _buildFilterChips(context, state.statusFilter, isDark),
          SizedBox(height: AppSizes.lg),
          if (state.invoices.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSizes.xxxl),
              child: SekkaEmptyState(
                icon: IconsaxPlusLinear.receipt_item,
                title: AppStrings.noInvoices,
                description: AppStrings.noInvoicesDesc,
              ),
            )
          else
            ...state.invoices.map((invoice) => Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.sm),
                  child: _buildInvoiceCard(context, invoice, isDark),
                )),
          if (state.isLoadingMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(InvoiceSummaryEntity summary, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(20)),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.invoiceSummaryTitle,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: Responsive.h(16)),
            Row(
              children: [
                _buildSummaryItem(
                  label: AppStrings.invoiceTotalPaid,
                  value: '${summary.totalPaid.toInt()}',
                  icon: IconsaxPlusLinear.tick_circle,
                ),
                SizedBox(width: Responsive.w(12)),
                _buildSummaryItem(
                  label: AppStrings.invoiceTotalOutstanding,
                  value: '${summary.totalOutstanding.toInt()}',
                  icon: IconsaxPlusLinear.clock,
                ),
                SizedBox(width: Responsive.w(12)),
                _buildSummaryItem(
                  label: AppStrings.invoicesTitle,
                  value: '${summary.totalInvoices}',
                  icon: IconsaxPlusLinear.receipt_item,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.h(12),
          horizontal: Responsive.w(8),
        ),
        decoration: BoxDecoration(
          color: AppColors.textOnPrimary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Responsive.r(12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textOnPrimary, size: Responsive.r(20)),
            SizedBox(height: Responsive.h(6)),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: Responsive.h(2)),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.textOnPrimary.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    int? activeFilter,
    bool isDark,
  ) {
    final filters = [
      (null, AppStrings.invoiceAll),
      (0, AppStrings.invoicePending),
      (1, AppStrings.invoicePaid),
      (2, AppStrings.invoiceOverdue),
      (3, AppStrings.invoiceVoided),
    ];

    return SizedBox(
      height: Responsive.h(40),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => SizedBox(width: AppSizes.sm),
          itemBuilder: (context, index) {
            final (status, label) = filters[index];
            final isActive = activeFilter == status;

            return GestureDetector(
              onTap: () => context
                  .read<InvoicesBloc>()
                  .add(InvoicesFilterChanged(status)),
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
                  label,
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
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    InvoiceEntity invoice,
    bool isDark,
  ) {
    final (statusLabel, statusColor) = _invoiceStatus(invoice.status);

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      onTap: () => Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: context.read<InvoicesBloc>(),
            child: InvoiceDetailScreen(invoice: invoice),
          ),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: invoice number + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppStrings.invoiceNumber}${invoice.invoiceNumber}',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(10),
                    vertical: Responsive.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTypography.captionSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(10)),

            // Period
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.calendar_1,
                  size: Responsive.r(14),
                  color: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                ),
                SizedBox(width: Responsive.w(6)),
                Text(
                  '${invoice.periodStart} - ${invoice.periodEnd}',
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(12)),

            // Bottom: net amount + orders count
            Row(
              children: [
                Text(
                  '${invoice.netAmount.toInt()} ${AppStrings.currency}',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(
                  IconsaxPlusLinear.box,
                  size: Responsive.r(14),
                  color: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                ),
                SizedBox(width: Responsive.w(4)),
                Text(
                  '${invoice.totalOrders} ${AppStrings.statOrders}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _invoiceStatus(int status) => switch (status) {
        0 => (AppStrings.invoicePending, AppColors.warning),
        1 => (AppStrings.invoicePaid, AppColors.success),
        2 => (AppStrings.invoiceOverdue, AppColors.error),
        3 => (AppStrings.invoiceVoided, AppColors.textCaption),
        _ => (AppStrings.invoicePending, AppColors.warning),
      };
}
