import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../domain/entities/invoice_entity.dart';
import '../bloc/invoices_bloc.dart';
import '../bloc/invoices_event.dart';
import '../bloc/invoices_state.dart';

class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key, required this.invoice});
  final InvoiceEntity invoice;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final _screenshotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context
        .read<InvoicesBloc>()
        .add(InvoiceDetailRequested(widget.invoice.id));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(
        title: AppStrings.invoiceDetail,
        actions: [
          // Share as image
          IconButton(
            onPressed: () => _shareAsImage(context),
            tooltip: AppStrings.shareAsImage,
            icon: Icon(
              IconsaxPlusLinear.image,
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
              size: Responsive.r(22),
            ),
          ),
        ],
      ),
      body: BlocConsumer<InvoicesBloc, InvoicesState>(
        listenWhen: (prev, curr) {
          if (curr is InvoicesLoaded) {
            return curr.pdfBytes != null || curr.actionMessage != null;
          }
          return false;
        },
        listener: (context, state) {
          if (state is InvoicesLoaded) {
            if (state.pdfBytes != null) {
              _savePdf(context, state.pdfBytes!);
            }
            if (state.actionMessage != null) {
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
          }
        },
        buildWhen: (prev, curr) {
          if (prev is InvoicesLoaded && curr is InvoicesLoaded) {
            return prev.selectedInvoice != curr.selectedInvoice ||
                prev.isDownloading != curr.isDownloading;
          }
          return true;
        },
        builder: (context, state) {
          final invoice = state is InvoicesLoaded &&
                  state.selectedInvoice != null
              ? state.selectedInvoice!
              : widget.invoice;
          final isDownloading =
              state is InvoicesLoaded && state.isDownloading;

          return _buildContent(context, invoice, isDark, isDownloading);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    InvoiceEntity invoice,
    bool isDark,
    bool isDownloading,
  ) {
    final (statusLabel, statusColor) = _invoiceStatus(invoice.status);
    final dateFormat = DateFormat('yyyy/MM/dd');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Column(
        children: [
          SizedBox(height: AppSizes.lg),

          // Screenshot-able area
          RepaintBoundary(
            key: _screenshotKey,
            child: Container(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.background,
              child: Column(
                children: [
                  // Header card
                  SekkaCard(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surface,
                    padding: EdgeInsets.all(Responsive.w(20)),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Invoice number + status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${AppStrings.invoiceNumber}${invoice.invoiceNumber}',
                                  style:
                                      AppTypography.headlineSmall.copyWith(
                                    color: isDark
                                        ? AppColors.textHeadlineDark
                                        : AppColors.textHeadline,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.w(12),
                                  vertical: Responsive.h(6),
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusPill),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.h(16)),

                          // Info rows
                          _buildInfoRow(
                            AppStrings.invoicePeriod,
                            '${invoice.periodStart} - ${invoice.periodEnd}',
                            isDark,
                          ),
                          _buildInfoRow(
                            AppStrings.invoiceIssuedAt,
                            dateFormat.format(invoice.issuedAt),
                            isDark,
                          ),
                          _buildInfoRow(
                            AppStrings.invoiceDueDate,
                            invoice.dueDate,
                            isDark,
                          ),
                          if (invoice.paidAt != null)
                            _buildInfoRow(
                              AppStrings.invoicePaidAt,
                              dateFormat.format(invoice.paidAt!),
                              isDark,
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.md),

                  // Financial summary
                  SekkaCard(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surface,
                    padding: EdgeInsets.all(Responsive.w(20)),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        children: [
                          _buildAmountRow(
                            AppStrings.invoiceTotalOrders,
                            '${invoice.totalOrders}',
                            isDark,
                          ),
                          _buildDivider(isDark),
                          _buildAmountRow(
                            AppStrings.invoiceTotalEarnings,
                            '${invoice.totalEarnings.toInt()} ${AppStrings.currency}',
                            isDark,
                            valueColor: AppColors.success,
                          ),
                          _buildDivider(isDark),
                          _buildAmountRow(
                            AppStrings.invoiceCommissions,
                            '- ${invoice.totalCommissions.toInt()} ${AppStrings.currency}',
                            isDark,
                            valueColor: AppColors.error,
                          ),
                          _buildDivider(isDark),
                          _buildAmountRow(
                            AppStrings.invoiceExpenses,
                            '- ${invoice.totalExpenses.toInt()} ${AppStrings.currency}',
                            isDark,
                            valueColor: AppColors.error,
                          ),
                          SizedBox(height: Responsive.h(12)),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(Responsive.w(14)),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                  Responsive.r(12)),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.invoiceNetAmount,
                                  style: AppTypography.titleMedium
                                      .copyWith(
                                    color: isDark
                                        ? AppColors.textHeadlineDark
                                        : AppColors.textHeadline,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${invoice.netAmount.toInt()} ${AppStrings.currency}',
                                  style: AppTypography.headlineSmall
                                      .copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.md),

                  // Line items
                  if (invoice.lineItems.isNotEmpty)
                    SekkaCard(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surface,
                      padding: EdgeInsets.all(Responsive.w(20)),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.invoiceLineItems,
                              style:
                                  AppTypography.titleMedium.copyWith(
                                color: isDark
                                    ? AppColors.textHeadlineDark
                                    : AppColors.textHeadline,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: Responsive.h(12)),
                            ...invoice.lineItems.map(
                              (item) => Padding(
                                padding: EdgeInsets.only(
                                    bottom: Responsive.h(10)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.description,
                                            style: AppTypography
                                                .bodyMedium
                                                .copyWith(
                                              color: isDark
                                                  ? AppColors
                                                      .textHeadlineDark
                                                  : AppColors
                                                      .textHeadline,
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity.toInt()} x ${item.unitPrice.toInt()} ${AppStrings.currency}',
                                            style: AppTypography
                                                .captionSmall
                                                .copyWith(
                                              color: isDark
                                                  ? AppColors
                                                      .textCaptionDark
                                                  : AppColors
                                                      .textCaption,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${item.total.toInt()} ${AppStrings.currency}',
                                      style: AppTypography.titleMedium
                                          .copyWith(
                                        color: isDark
                                            ? AppColors
                                                .textHeadlineDark
                                            : AppColors.textHeadline,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),

          // Download PDF button
          Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: double.infinity,
              height: Responsive.h(52),
              child: ElevatedButton.icon(
                onPressed: isDownloading
                    ? null
                    : () => context
                        .read<InvoicesBloc>()
                        .add(InvoicePdfDownloadRequested(
                            widget.invoice.id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                icon: isDownloading
                    ? SizedBox(
                        width: Responsive.r(20),
                        height: Responsive.r(20),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : Icon(IconsaxPlusLinear.document_download,
                        size: Responsive.r(20)),
                label: Text(
                  AppStrings.downloadPdf,
                  style: AppTypography.button,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textCaptionDark
                  : AppColors.textCaption,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textBodyDark
                  : AppColors.textBody,
            ),
          ),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: valueColor ??
                  (isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? AppColors.borderDark : AppColors.border,
      height: 1,
    );
  }

  (String, Color) _invoiceStatus(int status) => switch (status) {
        0 => (AppStrings.invoicePending, AppColors.warning),
        1 => (AppStrings.invoicePaid, AppColors.success),
        2 => (AppStrings.invoiceOverdue, AppColors.error),
        3 => (AppStrings.invoiceVoided, AppColors.textCaption),
        _ => (AppStrings.invoicePending, AppColors.warning),
      };

  Future<void> _savePdf(BuildContext context, List<int> bytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/invoice_${widget.invoice.invoiceNumber}.pdf');
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.invoicePdfSaved),
          backgroundColor: AppColors.success,
        ),
      );

      // Share the file
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.invoicePdfError),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (context.mounted) {
        context
            .read<InvoicesBloc>()
            .add(const InvoicesClearMessage());
      }
    }
  }

  Future<void> _shareAsImage(BuildContext context) async {
    try {
      final boundary = _screenshotKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/invoice_${widget.invoice.invoiceNumber}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.invoiceImageSaved),
          backgroundColor: AppColors.success,
        ),
      );

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
    } catch (_) {
      // Silently fail
    }
  }
}
