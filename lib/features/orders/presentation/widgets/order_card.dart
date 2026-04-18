import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../shared/enums/order_enums.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../data/models/order_model.dart';

class OrderCard extends StatefulWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final OrderModel order;
  final VoidCallback? onTap;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  String? _resolvedDeliveryAddress;
  StreamSubscription<bool>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _resolve();
    // Retry reverse-geocoding when the device reconnects — the initial
    // attempt fails silently when the order was created offline, so the
    // card would stay showing lat/lng forever otherwise.
    _connectivitySub =
        ConnectivityService.instance.onConnectivityChanged.listen((online) {
      if (online && _needsResolve()) _resolve();
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id ||
        oldWidget.order.deliveryAddress != widget.order.deliveryAddress) {
      _resolvedDeliveryAddress = null;
      _resolve();
    }
  }

  bool _needsResolve() {
    final current = _resolvedDeliveryAddress ?? widget.order.deliveryAddress;
    return RegExp(r'^[-\d.,\s]+$').hasMatch(current.trim());
  }

  Future<void> _resolve() async {
    final resolved = await _resolveAddress(
      widget.order.deliveryAddress,
      widget.order.deliveryLatitude,
      widget.order.deliveryLongitude,
    );
    if (!mounted) return;
    // Only cache when the resolver actually produced readable text — if it
    // still looks like raw coordinates, leave the cache null so the next
    // reconnect/refresh retries.
    final stillCoords = RegExp(r'^[-\d.,\s]+$').hasMatch(resolved.trim());
    if (stillCoords) return;
    setState(() => _resolvedDeliveryAddress = resolved);
  }

  /// If address looks like coordinates, reverse geocode it.
  Future<String> _resolveAddress(
    String address,
    double? lat,
    double? lng,
  ) async {
    final isCoords = RegExp(r'^[-\d.,\s]+$').hasMatch(address.trim());
    if (!isCoords && address.length > 10) return address;

    final double? useLat;
    final double? useLng;
    if (lat != null && lng != null && lat != 0 && lng != 0) {
      useLat = lat;
      useLng = lng;
    } else {
      final parts = address.split(RegExp(r'[,\s]+'));
      if (parts.length >= 2) {
        useLat = double.tryParse(parts[0].trim());
        useLng = double.tryParse(parts[1].trim());
      } else {
        return address;
      }
    }

    if (useLat == null || useLng == null) return address;

    try {
      final placemarks = await placemarkFromCoordinates(useLat, useLng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.street?.isNotEmpty == true) place.street!,
          if (place.subLocality?.isNotEmpty == true) place.subLocality!,
          if (place.locality?.isNotEmpty == true) place.locality!,
          if (place.administrativeArea?.isNotEmpty == true)
            place.administrativeArea!,
        ];
        if (parts.isNotEmpty) return parts.join('، ');
      }
    } catch (_) {}
    return address;
  }

  OrderModel get order => widget.order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final partnerColor = _parsePartnerColor(order.partnerColor);
    final displayAddress =
        _resolvedDeliveryAddress ?? order.deliveryAddress;

    return SekkaCard(
      onTap: widget.onTap,
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
                    _buildTopRow(isDark, displayAddress),
                    SizedBox(height: AppSizes.sm),

                    // Delivery address
                    _buildInfoRow(
                      icon: IconsaxPlusLinear.location,
                      text: displayAddress,
                      isDark: isDark,
                      maxLines: 1,
                    ),
                    SizedBox(height: AppSizes.sm),

                    // Recurring badge
                    if (order.isRecurring)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSizes.sm),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: Responsive.h(2),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(IconsaxPlusLinear.repeat,
                                      size: Responsive.r(12),
                                      color: AppColors.primary),
                                  SizedBox(width: Responsive.w(4)),
                                  Text(
                                    _recurrenceLabel(order.recurrencePattern),
                                    style: AppTypography.captionSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppSizes.xs),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: Responsive.h(2),
                              ),
                              decoration: BoxDecoration(
                                color: order.isPaused
                                    ? AppColors.warning.withValues(alpha: 0.12)
                                    : AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                              ),
                              child: Text(
                                order.isPaused
                                    ? AppStrings.pauseRecurring
                                    : AppStrings.resumeRecurring,
                                style: AppTypography.captionSmall.copyWith(
                                  color: order.isPaused
                                      ? AppColors.warning
                                      : AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

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

  Widget _buildTopRow(bool isDark, String fallbackAddress) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Text(
            order.customerName ?? fallbackAddress,
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
        OrderStatus.accepted => (AppColors.statusNew, AppStrings.statusNew),
        OrderStatus.pickedUp => (AppColors.statusOnTheWay, AppStrings.statusOnTheWay),
        OrderStatus.inTransit => (AppColors.statusOnTheWay, AppStrings.statusOnTheWay),
        OrderStatus.arrivedAtDestination => (AppColors.statusOnTheWay, AppStrings.statusOnTheWay),
        OrderStatus.delivered => (AppColors.statusDelivered, AppStrings.statusDelivered),
        OrderStatus.failed => (AppColors.statusFailed, AppStrings.statusFailed),
        OrderStatus.cancelled => (AppColors.statusCancelled, AppStrings.statusCancelled),
        OrderStatus.partiallyDelivered => (AppColors.statusDelivered, AppStrings.statusPartiallyDelivered),
        OrderStatus.retryPending => (AppColors.statusPostponed, AppStrings.statusPostponed),
        OrderStatus.returned => (AppColors.statusReturned, AppStrings.statusReturned),
      };

  static String _recurrenceLabel(String? pattern) => switch (pattern) {
        'Daily' => AppStrings.recurrenceDaily,
        'Weekly' => AppStrings.recurrenceWeekly,
        'Monthly' => AppStrings.recurrenceMonthly,
        _ => pattern ?? '',
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
