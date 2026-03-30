import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../shared/enums/order_enums.dart';
import '../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final OrderModel order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final partnerColor = _parsePartnerColor(order.partnerColor);

    return SekkaCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(bottom: AppSizes.md),
      child: IntrinsicHeight(
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Partner color stripe (right edge in RTL)
            if (partnerColor != null)
              Container(
                width: Responsive.w(4),
                decoration: BoxDecoration(
                  color: partnerColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppSizes.cardRadius),
                    bottomRight: Radius.circular(AppSizes.cardRadius),
                  ),
                ),
              ),

            // Card content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    // Top row: customer name (or order number) + status chip
                    _buildTopRow(isDark),
                    SizedBox(height: AppSizes.sm),

                    // Delivery address
                    _buildInfoRow(
                      icon: IconsaxPlusLinear.location,
                      text: order.deliveryAddress,
                      isDark: isDark,
                      maxLines: 1,
                    ),
                    SizedBox(height: AppSizes.sm),

                    // Bottom row: amount + payment method + priority
                    _buildBottomRow(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(bool isDark) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Text(
            order.customerName ?? order.deliveryAddress,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: AppSizes.sm),
        _buildStatusChip(
          order.deliveredAt != null ? OrderStatus.delivered : order.status,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required bool isDark,
    int maxLines = 2,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          icon,
          size: AppSizes.iconSm,
          color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
        ),
        SizedBox(width: AppSizes.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
            textDirection: TextDirection.rtl,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow(bool isDark) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        // Amount
        Text(
          '${order.amount.toStringAsFixed(0)} ج.م',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: AppSizes.sm),

        // Payment method badge
        _buildSmallChip(
          label: order.paymentMethod.arabic,
          color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
          backgroundColor: isDark
              ? AppColors.borderDark
              : AppColors.border.withValues(alpha: 0.5),
        ),

        const Spacer(),

        // Priority badge
        if (order.priority == OrderPriority.urgent)
          _buildSmallChip(
            label: order.priority.arabic,
            color: AppColors.statusOnTheWay,
            backgroundColor: AppColors.statusOnTheWay.withValues(alpha: 0.12),
          ),
        if (order.priority == OrderPriority.vip)
          _buildSmallChip(
            label: order.priority.arabic,
            color: AppColors.warning,
            backgroundColor: AppColors.warning.withValues(alpha: 0.12),
          ),
      ],
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    final (color, label) = _statusInfo(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSmallChip({
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: Responsive.h(2),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static (Color, String) _statusInfo(OrderStatus status) => switch (status) {
        OrderStatus.pending => (AppColors.statusNew, AppStrings.statusNew),
        OrderStatus.accepted => (AppColors.statusNew, status.arabic),
        OrderStatus.pickedUp => (AppColors.statusOnTheWay, status.arabic),
        OrderStatus.inTransit => (AppColors.statusOnTheWay, AppStrings.statusOnTheWay),
        OrderStatus.arrivedAtDestination => (
          AppColors.statusArrived,
          AppStrings.statusArrived,
        ),
        OrderStatus.delivered => (AppColors.statusDelivered, AppStrings.statusDelivered),
        OrderStatus.failed => (AppColors.statusFailed, AppStrings.statusFailed),
        OrderStatus.cancelled => (AppColors.statusCancelled, AppStrings.statusCancelled),
        OrderStatus.partiallyDelivered => (
          AppColors.statusReturned,
          status.arabic,
        ),
        OrderStatus.retryPending => (AppColors.statusPostponed, AppStrings.statusPostponed),
        OrderStatus.returned => (AppColors.statusReturned, AppStrings.statusReturned),
      };

  static Color? _parsePartnerColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6 && cleaned.length != 8) return null;
    final value = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    );
    return value != null ? Color(value) : null;
  }
}
