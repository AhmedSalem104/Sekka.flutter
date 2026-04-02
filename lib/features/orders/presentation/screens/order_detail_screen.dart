import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_map_picker.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../core/widgets/sekka_swipe_action.dart';
import '../../../../core/widgets/status_badge.dart' as badge;
import '../../../../shared/enums/order_enums.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../messages/data/repositories/message_template_repository.dart';
import '../../../messages/presentation/widgets/quick_messages_sheet.dart';
import '../../data/models/order_model.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import 'create_order_screen.dart';

// ---------------------------------------------------------------------------
// Helper: map OrderStatus → StatusBadge.OrderStatus
// ---------------------------------------------------------------------------
badge.OrderStatus _mapToBadgeStatus(OrderStatus s) => switch (s) {
      OrderStatus.pending || OrderStatus.retryPending => badge.OrderStatus.newOrder,
      OrderStatus.accepted || OrderStatus.pickedUp => badge.OrderStatus.newOrder,
      OrderStatus.inTransit || OrderStatus.arrivedAtDestination => badge.OrderStatus.onTheWay,
      OrderStatus.delivered => badge.OrderStatus.delivered,
      OrderStatus.failed => badge.OrderStatus.failed,
      OrderStatus.cancelled => badge.OrderStatus.cancelled,
      OrderStatus.returned => badge.OrderStatus.returned,
      OrderStatus.partiallyDelivered => badge.OrderStatus.delivered,
    };

// ---------------------------------------------------------------------------
// Helper: status color
// ---------------------------------------------------------------------------
Color _statusColor(OrderStatus s) => switch (s) {
      OrderStatus.pending || OrderStatus.retryPending => AppColors.statusNew,
      OrderStatus.accepted || OrderStatus.pickedUp => AppColors.statusNew,
      OrderStatus.inTransit || OrderStatus.arrivedAtDestination => AppColors.statusOnTheWay,
      OrderStatus.delivered || OrderStatus.partiallyDelivered => AppColors.statusDelivered,
      OrderStatus.failed => AppColors.statusFailed,
      OrderStatus.cancelled => AppColors.statusCancelled,
      OrderStatus.returned => AppColors.statusReturned,
    };

// ---------------------------------------------------------------------------
// Date formatter
// ---------------------------------------------------------------------------
final _dateFmt = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');

// ═══════════════════════════════════════════════════════════════════════════
//  ORDER DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(
          OrderDetailLoadRequested(orderId: widget.orderId),
        );
  }

  // ── Menu helpers ──────────────────────────────────────────────────────

  bool _isActiveStatus(OrderStatus s) => s.isActive;

  void _showPhotoTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              SizedBox(height: AppSizes.md),
              Builder(
                builder: (ctx) {
                  final isDark = Theme.of(ctx).brightness == Brightness.dark;
                  return Text(
                    'اختار نوع الصورة',
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                  );
                },
              ),
              SizedBox(height: AppSizes.md),
              ...PhotoType.values.map(
                (pt) => ListTile(
                  title: Builder(
                    builder: (ctx) {
                      final isDark = Theme.of(ctx).brightness == Brightness.dark;
                      return Text(
                        pt.arabic,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.textBodyDark
                              : AppColors.textBody,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto(pt);
                  },
                ),
              ),
              SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(PhotoType photoType) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (xFile == null || !mounted) return;
    context.read<OrdersBloc>().add(
          OrderPhotoUploadRequested(
            orderId: widget.orderId,
            imageFile: File(xFile.path),
            photoType: photoType.value,
          ),
        );
  }

  void _confirmDelete() {
    SekkaMessageDialog.show(
      context,
      title: AppStrings.deleteOrder,
      message: AppStrings.deleteOrderConfirm,
      type: SekkaMessageType.info,
      buttonText: AppStrings.confirm,
    ).then((_) {
      if (!mounted) return;
      context.read<OrdersBloc>().add(
            OrderDeleteRequested(orderId: widget.orderId),
          );
      Navigator.pop(context);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: BlocConsumer<OrdersBloc, OrdersState>(
          listener: _blocListener,
          builder: (context, state) {
            final order = switch (state) {
              OrdersLoaded(selectedOrder: final o?) => o,
              _ => null,
            };
            if (order == null) return const SekkaLoading();
            final isActionInProgress = switch (state) {
              OrdersLoaded(isActionInProgress: final v) => v,
              _ => false,
            };
            return _buildBody(order, isActionInProgress);
          },
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: const SekkaBackButton(),
      title: Text(
        AppStrings.orderDetails,
        style: AppTypography.headlineSmall.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textHeadlineDark
              : AppColors.textHeadline,
        ),
      ),
      actions: [
        BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            final order = switch (state) {
              OrdersLoaded(selectedOrder: final o?) => o,
              _ => null,
            };
            if (order == null) return const SizedBox.shrink();
            return _buildPopupMenu(order);
          },
        ),
      ],
    );
  }

  Widget _buildPopupMenu(OrderModel order) {
    final status = order.status;
    final canEdit = status.canEdit;
    final isActive = _isActiveStatus(status);
    final isDelivered = status == OrderStatus.delivered;
    final isFailed = status == OrderStatus.failed;
    final isDeliveredOrFailed = isDelivered || isFailed;

    return PopupMenuButton<String>(
      icon: Icon(IconsaxPlusLinear.more, size: AppSizes.iconLg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      onSelected: (value) => _onMenuSelected(value, order),
      itemBuilder: (_) => [
        if (canEdit)
          const PopupMenuItem(value: 'edit', child: Text('عدّل الطلب')),
        if (canEdit)
          const PopupMenuItem(value: 'delete', child: Text('امسح الطلب')),
        if (isActive)
          const PopupMenuItem(value: 'transfer', child: Text('حوّل لسائق تاني')),
        if (isActive)
          const PopupMenuItem(value: 'swap_address', child: Text('غيّر العنوان')),
        const PopupMenuItem(value: 'photo', child: Text('صوّر الطلب')),
        const PopupMenuItem(value: 'disclaimer', child: Text('إخلاء مسؤولية')),
        if (isDeliveredOrFailed)
          const PopupMenuItem(value: 'dispute', child: Text('فتح نزاع')),
        if (isDelivered)
          const PopupMenuItem(value: 'refund', child: Text('طلب استرداد')),
        if (isActive)
          const PopupMenuItem(value: 'book_slot', child: Text('احجز موعد تسليم')),
      ],
    );
  }

  void _onMenuSelected(String value, OrderModel order) {
    switch (value) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => CreateOrderScreen(order: order),
          ),
        );
      case 'delete':
        _confirmDelete();
      case 'transfer':
        _showSheet(_TransferBottomSheet(orderId: widget.orderId));
      case 'swap_address':
        _showSheet(_SwapAddressBottomSheet(orderId: widget.orderId));
      case 'photo':
        _showPhotoTypePicker();
      case 'disclaimer':
        _showSheet(_DisclaimerBottomSheet(orderId: widget.orderId));
      case 'dispute':
        _showSheet(_DisputeBottomSheet(orderId: widget.orderId));
      case 'refund':
        _showSheet(
          _RefundBottomSheet(
            orderId: widget.orderId,
            currentAmount: order.amount,
          ),
        );
      case 'book_slot':
        _showSheet(_BookSlotBottomSheet(orderId: widget.orderId));
    }
  }

  void _showSheet(Widget sheet) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<OrdersBloc>(),
        child: sheet,
      ),
    );
  }

  // ── BLoC listener ─────────────────────────────────────────────────────

  void _blocListener(BuildContext context, OrdersState state) {
    if (state is OrdersLoaded && state.actionMessage != null) {
      final msg = state.actionMessage!;
      final isError = state.isActionError;

      final isTerminalAction = !isError &&
          (msg == AppStrings.orderDeliveredSuccess ||
              msg == AppStrings.orderCancelledSuccess ||
              msg == AppStrings.orderDeletedSuccess ||
              msg == AppStrings.partialDeliverySuccess);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(msg),
            ),
            backgroundColor: isError ? AppColors.error : AppColors.success,
          ),
        );

      // امسح الرسالة عشان متتعرضش تاني
      context.read<OrdersBloc>().add(const OrdersClearMessage());

      // لو تسليم/إلغاء/حذف → ارجع للقائمة
      if (isTerminalAction && mounted) {
        Navigator.of(context).pop();
      }
    }
    if (state is OrdersError) {
      SekkaMessageDialog.show(
        context,
        message: state.message,
        type: SekkaMessageType.error,
      );
    }
  }

  // ── Body ──────────────────────────────────────────────────────────────

  /// Find recurring data for this order (if it's a recurring order).
  Widget _buildBody(OrderModel order, bool isActionInProgress) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            children: [
              _OrderHeaderCard(order: order),
              if (order.isRecurring) ...[
                SizedBox(height: AppSizes.md),
                _RecurringInfoCard(order: order),
              ],
              SizedBox(height: AppSizes.md),
              _AddressCard(order: order),
              SizedBox(height: AppSizes.md),
              _FinancialCard(order: order),
              SizedBox(height: AppSizes.md),
              _DetailsCard(order: order),
              if (order.photos.isNotEmpty) ...[
                SizedBox(height: AppSizes.md),
                _PhotosSection(photos: order.photos),
              ],
              if (order.status == OrderStatus.inTransit ||
                  order.status == OrderStatus.arrivedAtDestination) ...[
                SizedBox(height: AppSizes.md),
                _WaitingTimerSection(orderId: widget.orderId),
              ],
              SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
        _ActionArea(
          order: order,
          orderId: widget.orderId,
          isLoading: isActionInProgress,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  1. ORDER HEADER CARD — حالة + عميل + تواصل + تابع ع الخريطة
// ═══════════════════════════════════════════════════════════════════════════
class _OrderHeaderCard extends StatelessWidget {
  const _OrderHeaderCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActuallyDelivered = order.deliveredAt != null;
    final effectiveStatus =
        isActuallyDelivered ? OrderStatus.delivered : order.status;
    final color = _statusColor(effectiveStatus);
    final isTracking = order.status == OrderStatus.inTransit ||
        order.status == OrderStatus.arrivedAtDestination;

    return SekkaCard(
      child: Column(
        children: [
          // ── اسم + رقم (يمين) | حالة الطلب (شمال) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الاسم والرقم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.customerName != null &&
                        order.customerName!.isNotEmpty)
                      Text(
                        order.customerName!,
                        style: AppTypography.titleLarge.copyWith(
                          color: isDark
                              ? AppColors.textHeadlineDark
                              : AppColors.textHeadline,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (order.customerPhone != null &&
                        order.customerPhone!.isNotEmpty) ...[
                      SizedBox(height: AppSizes.xs),
                      GestureDetector(
                        onTap: () => _callPhone(order.customerPhone!),
                        onLongPress: () =>
                            _copyPhone(context, order.customerPhone!),
                        child: Text(
                          order.customerPhone!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // حالة الطلب
              badge.StatusBadge(status: _mapToBadgeStatus(effectiveStatus)),
            ],
          ),
          SizedBox(height: AppSizes.sm),

          // ── تاريخ الإنشاء / التسليم ──
          _infoRow(
            context,
            IconsaxPlusLinear.calendar_1,
            AppStrings.createdAt,
            _dateFmt.format(order.createdAt),
          ),
          if (order.deliveredAt != null) ...[
            SizedBox(height: AppSizes.xs),
            _infoRow(
              context,
              IconsaxPlusLinear.tick_circle,
              AppStrings.deliveredAt,
              _dateFmt.format(order.deliveredAt!),
            ),
          ],
          SizedBox(height: AppSizes.md),

          // ── رسائل سريعة + مراسلة + اتصال ──
          Row(
            children: [
              // رسائل سريعة
              Expanded(
                child: GestureDetector(
                  onTap: () => _showQuickMessages(
                    context,
                    order.customerPhone,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(12),
                      vertical: Responsive.h(12),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IconsaxPlusBold.message_text,
                          size: AppSizes.iconMd,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSizes.xs),
                        Flexible(
                          child: Text(
                            AppStrings.quickMessages,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSizes.sm),
              // مراسلة
              if (order.customerPhone != null &&
                  order.customerPhone!.isNotEmpty)
                GestureDetector(
                  onTap: () => _openMessagingApps(order.customerPhone!),
                  child: Container(
                    padding: EdgeInsets.all(Responsive.r(12)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      IconsaxPlusBold.message,
                      size: AppSizes.iconMd,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              SizedBox(width: AppSizes.sm),
              // اتصال
              if (order.customerPhone != null &&
                  order.customerPhone!.isNotEmpty)
                GestureDetector(
                  onTap: () => _callPhone(order.customerPhone!),
                  child: Container(
                    padding: EdgeInsets.all(Responsive.r(12)),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      IconsaxPlusBold.call,
                      size: AppSizes.iconMd,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),

          // ── تابع ع الخريطة (يظهر فقط أثناء الرحلة) ──
          if (isTracking) ...[
            SizedBox(height: AppSizes.md),
            SekkaButton(
              label: AppStrings.trackOnMap,
              icon: IconsaxPlusLinear.map,
              onPressed: () => _openMapTracking(
                context,
                order.deliveryAddress,
                order.deliveryLatitude,
                order.deliveryLongitude,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.iconSm,
          color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
        ),
        SizedBox(width: AppSizes.sm),
        Text(
          '$label: ',
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
        ),
      ],
    );
  }

  void _showQuickMessages(BuildContext context, String? phone) {
    final dio = context.read<DioClient>().dio;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickMessagesSheet(
        repository: MessageTemplateRepository(dio),
        customerPhone: phone,
        onTemplateSelected: (messageText) {
          if (phone != null && phone.isNotEmpty) {
            _sendWhatsApp(phone, messageText);
          } else {
            Clipboard.setData(ClipboardData(text: messageText));
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(AppStrings.messageCopied),
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
          }
        },
      ),
    );
  }

  Future<void> _openMessagingApps(String phone) async {
    var normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized.startsWith('0')) {
      normalized = '+2$normalized';
    } else if (!normalized.startsWith('+')) {
      normalized = '+$normalized';
    }
    final uri = Uri(scheme: 'sms', path: normalized);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendWhatsApp(String phone, String message) async {
    var normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized.startsWith('0')) {
      normalized = '+2$normalized';
    } else if (!normalized.startsWith('+')) {
      normalized = '+$normalized';
    }
    final uri = Uri.parse(
      'https://wa.me/$normalized?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyPhone(BuildContext context, String phone) {
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(AppStrings.phoneCopied),
          ),
          backgroundColor: AppColors.success,
        ),
      );
  }

  Future<void> _openMapTracking(
    BuildContext context,
    String address,
    double? lat,
    double? lng,
  ) async {
    // Deep link to Google Maps with destination
    final String query;
    if (lat != null && lng != null && lat != 0 && lng != 0) {
      query = '$lat,$lng';
    } else {
      query = Uri.encodeComponent(address);
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  1b. RECURRING INFO CARD
// ═══════════════════════════════════════════════════════════════════════════
class _RecurringInfoCard extends StatelessWidget {
  const _RecurringInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pattern = order.recurrencePattern ?? '';
    final isPaused = order.isPaused;
    final nextDate = order.nextScheduledDate ?? '';
    final totalOccurrences = order.totalOccurrences ?? 0;

    final patternLabel = switch (pattern) {
      'Daily' => AppStrings.recurrenceDaily,
      'Weekly' => AppStrings.recurrenceWeekly,
      'Monthly' => AppStrings.recurrenceMonthly,
      _ => pattern,
    };

    return SekkaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(IconsaxPlusLinear.repeat,
                  size: AppSizes.iconSm, color: AppColors.primary),
              SizedBox(width: AppSizes.sm),
              Text(
                AppStrings.orderTypeRecurring,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: isPaused
                      ? AppColors.warning.withValues(alpha: 0.12)
                      : AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  isPaused ? AppStrings.pauseRecurring : AppStrings.resumeRecurring,
                  style: AppTypography.captionSmall.copyWith(
                    color: isPaused ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSizes.md),

          // Info rows
          _recInfoRow(
            icon: IconsaxPlusLinear.calendar_1,
            label: AppStrings.recurrencePatternLabel,
            value: patternLabel,
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.sm),
          if (nextDate.isNotEmpty && !nextDate.startsWith('0001'))
            _recInfoRow(
              icon: IconsaxPlusLinear.calendar_tick,
              label: AppStrings.nextScheduled,
              value: nextDate.length >= 10 ? nextDate.substring(0, 10) : nextDate,
              isDark: isDark,
            ),
          if (totalOccurrences > 0) ...[
            SizedBox(height: AppSizes.sm),
            _recInfoRow(
              icon: IconsaxPlusLinear.chart,
              label: AppStrings.totalOccurrences,
              value: '$totalOccurrences',
              isDark: isDark,
            ),
          ],

          SizedBox(height: AppSizes.md),

          // Pause/Resume + Delete buttons
          Row(
            children: [
              Expanded(
                child: SekkaButton(
                  label: isPaused ? AppStrings.resumeRecurring : AppStrings.pauseRecurring,
                  icon: isPaused ? IconsaxPlusLinear.play : IconsaxPlusLinear.pause,
                  type: isPaused ? SekkaButtonType.primary : SekkaButtonType.secondary,
                  onPressed: () {
                    if (isPaused) {
                      context.read<OrdersBloc>().add(
                            RecurringOrderResumeRequested(orderId: order.id),
                          );
                    } else {
                      context.read<OrdersBloc>().add(
                            RecurringOrderPauseRequested(orderId: order.id),
                          );
                    }
                  },
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: SekkaButton(
                  label: AppStrings.deleteRecurring,
                  icon: IconsaxPlusLinear.trash,
                  type: SekkaButtonType.text,
                  onPressed: () => _confirmDelete(context, order.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String orderId) {
    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Text(AppStrings.deleteRecurring,
              style: AppTypography.titleMedium),
          content: Text(AppStrings.confirmDeleteRecurring,
              style: AppTypography.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppStrings.cancel, style: AppTypography.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<OrdersBloc>().add(
                      RecurringOrderDeleteRequested(orderId: orderId),
                    );
                Navigator.of(context).pop(); // Close detail screen
              },
              child: Text(
                AppStrings.deleteRecurring,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: AppColors.textCaption),
        SizedBox(width: AppSizes.sm),
        Text('$label: ',
            style: AppTypography.caption),
        Expanded(
          child: Text(value, style: AppTypography.bodySmall),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  2. ADDRESS CARD — العناوين (with reverse geocoding)
// ═══════════════════════════════════════════════════════════════════════════
class _AddressCard extends StatefulWidget {
  const _AddressCard({required this.order});
  final OrderModel order;

  @override
  State<_AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<_AddressCard> {
  String? _resolvedDeliveryAddress;
  String? _resolvedPickupAddress;

  @override
  void initState() {
    super.initState();
    _resolveAddresses();
  }

  Future<void> _resolveAddresses() async {
    // Delivery address
    _resolvedDeliveryAddress = await _resolveAddress(
      widget.order.deliveryAddress,
      widget.order.deliveryLatitude,
      widget.order.deliveryLongitude,
    );
    // Pickup address
    if (widget.order.pickupAddress != null &&
        widget.order.pickupAddress!.isNotEmpty) {
      _resolvedPickupAddress = await _resolveAddress(
        widget.order.pickupAddress!,
        widget.order.pickupLatitude,
        widget.order.pickupLongitude,
      );
    }
    if (mounted) setState(() {});
  }

  /// If address looks like coordinates, reverse geocode it.
  Future<String> _resolveAddress(
    String address,
    double? lat,
    double? lng,
  ) async {
    // Check if address is just coordinates (e.g. "30.0444, 31.2357")
    final isCoords = RegExp(r'^[-\d.,\s]+$').hasMatch(address.trim());
    if (!isCoords && address.length > 10) return address;

    // Try reverse geocoding from lat/lng
    final double? useLat;
    final double? useLng;
    if (lat != null && lng != null && lat != 0 && lng != 0) {
      useLat = lat;
      useLng = lng;
    } else {
      // Try parsing from address string
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
    } catch (_) {
      // Geocoding failed — return original
    }
    return address;
  }

  @override
  Widget build(BuildContext context) {
    final deliveryText =
        _resolvedDeliveryAddress ?? widget.order.deliveryAddress;
    final pickupText =
        _resolvedPickupAddress ?? widget.order.pickupAddress;

    return SekkaCard(
      child: Column(
        children: [
          _row(
            context,
            IconsaxPlusLinear.location,
            deliveryText,
            label: 'هيتوصّل فين',
          ),
          if (pickupText != null && pickupText.isNotEmpty) ...[
            SizedBox(height: AppSizes.md),
            _row(
              context,
              IconsaxPlusLinear.location_tick,
              pickupText,
              label: 'هيتستلم منين',
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String text, {
    String? label,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMd, color: AppColors.textCaption),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Text(
                  label,
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.textCaption,
                  ),
                ),
              Text(
                text,
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  3. FINANCIAL MINI CARDS
// ═══════════════════════════════════════════════════════════════════════════
class _FinancialCard extends StatelessWidget {
  const _FinancialCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      child: Row(
        children: [
          Expanded(
            child: _miniCol(
              AppStrings.amount,
              '${order.amount.toStringAsFixed(0)} ${AppStrings.currency}',
              AppColors.primary,
              isBold: true,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _miniCol(
              AppStrings.paymentMethodLabel,
              order.paymentMethod.arabic,
              AppColors.textBody,
            ),
          ),
          if (order.commissionAmount != null) ...[
            _verticalDivider(),
            Expanded(
              child: _miniCol(
                AppStrings.commission,
                '${order.commissionAmount!.toStringAsFixed(0)} ${AppStrings.currency}',
                AppColors.textBody,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniCol(String label, String value, Color valueColor,
      {bool isBold = false,}) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption),
        SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: valueColor,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: Responsive.h(40),
      color: AppColors.border,
      margin: EdgeInsets.symmetric(horizontal: AppSizes.sm),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  4. DETAILS CARD
// ═══════════════════════════════════════════════════════════════════════════
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      child: Column(
        children: [
          _detailRow(AppStrings.orderNumberLabel, order.orderNumber),
          if (order.partnerName != null && order.partnerName!.isNotEmpty) ...[
            _divider(),
            _detailRow('الشريك/التاجر', order.partnerName!),
          ],
          if (order.description != null && order.description!.isNotEmpty) ...[
            _divider(),
            _detailRow('وصف الشحنة', order.description!),
          ],
          _divider(),
          _detailRow(AppStrings.priorityLabel, order.priority.arabic),
          if (order.itemCount != null) ...[
            _divider(),
            _detailRow(AppStrings.itemCount, '${order.itemCount}'),
          ],
          if (order.distanceKm != null) ...[
            _divider(),
            _detailRow(
              AppStrings.distance,
              '${order.distanceKm!.toStringAsFixed(1)} ${AppStrings.km}',
            ),
          ],
          if (order.worthScore != null) ...[
            _divider(),
            _detailRow('نقاط القيمة', '${order.worthScore!.toStringAsFixed(1)}'),
          ],
          if (order.sequenceIndex != null) ...[
            _divider(),
            _detailRow('ترتيب التوصيل', '#${order.sequenceIndex}'),
          ],
          if (order.scheduledDate != null && order.scheduledDate!.isNotEmpty) ...[
            _divider(),
            _detailRow(AppStrings.scheduledDate, order.scheduledDate!),
          ],
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            _divider(),
            _detailRow(AppStrings.notes, order.notes!, multiLine: true),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool multiLine = false}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: multiLine
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      value,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        value,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textBodyDark
                              : AppColors.textBody,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _divider() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Divider(
          height: 1,
          color: isDark ? AppColors.borderDark : AppColors.border,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  4b. PHOTOS SECTION
// ═══════════════════════════════════════════════════════════════════════════
class _PhotosSection extends StatelessWidget {
  const _PhotosSection({required this.photos});
  final List<OrderPhotoModel> photos;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SekkaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconsaxPlusBold.gallery,
                size: AppSizes.iconMd,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.sm),
              Text(
                'صور الطلب (${photos.length})',
                style: AppTypography.titleMedium,
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          SizedBox(
            height: Responsive.h(120),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: photos.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSizes.sm),
              itemBuilder: (_, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () => _openFullPhoto(context, photo),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                        child: CachedNetworkImage(
                          imageUrl: photo.fullUrl,
                          width: Responsive.w(90),
                          height: Responsive.h(90),
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: Responsive.w(90),
                            height: Responsive.h(90),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMd),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: Responsive.w(90),
                            height: Responsive.h(90),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMd),
                            ),
                            child: Icon(
                              IconsaxPlusLinear.gallery_slash,
                              color: AppColors.textCaption,
                              size: AppSizes.iconXl,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSizes.xs),
                      Text(
                        photo.typeLabel,
                        style: AppTypography.captionSmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openFullPhoto(BuildContext context, OrderPhotoModel photo) {
    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(AppSizes.md),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: photo.fullUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Center(
                      child: Icon(
                        IconsaxPlusLinear.gallery_slash,
                        color: Colors.white54,
                        size: Responsive.r(64),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppSizes.md,
                right: AppSizes.md,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.sm),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: AppSizes.iconMd,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: AppSizes.lg,
                left: 0,
                right: 0,
                child: Text(
                  photo.typeLabel,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  5. WAITING TIMER SECTION
// ═══════════════════════════════════════════════════════════════════════════
class _WaitingTimerSection extends StatefulWidget {
  const _WaitingTimerSection({required this.orderId});
  final String orderId;

  @override
  State<_WaitingTimerSection> createState() => _WaitingTimerSectionState();
}

class _WaitingTimerSectionState extends State<_WaitingTimerSection> {
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  late final Stopwatch _stopwatch;
  Stream<int>? _timerStream;
  late StreamSubscription<int>? _timerSub;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timerSub = null;
  }

  @override
  void dispose() {
    _timerSub?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _start() {
    context.read<OrdersBloc>().add(
          OrderWaitingStartRequested(orderId: widget.orderId),
        );

    _stopwatch.reset();
    _stopwatch.start();
    _timerStream =
        Stream.periodic(const Duration(seconds: 1), (i) => i + 1);
    _timerSub = _timerStream!.listen((_) {
      if (mounted) {
        setState(() => _elapsedSeconds = _stopwatch.elapsed.inSeconds);
      }
    });
    setState(() => _isRunning = true);
  }

  void _stop() {
    context.read<OrdersBloc>().add(
          OrderWaitingStopRequested(orderId: widget.orderId),
        );

    _stopwatch.stop();
    _timerSub?.cancel();
    setState(() => _isRunning = false);
  }

  String _formatElapsed(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SekkaCard(
      child: Column(
        children: [
          // العنوان
          Row(
            children: [
              Icon(
                IconsaxPlusBold.timer_1,
                size: AppSizes.iconMd,
                color: _isRunning ? AppColors.warning : AppColors.textCaption,
              ),
              SizedBox(width: AppSizes.sm),
              Text('مؤقت الانتظار', style: AppTypography.titleMedium),
            ],
          ),
          SizedBox(height: AppSizes.lg),

          // الساعة
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
            decoration: BoxDecoration(
              color: _isRunning
                  ? AppColors.warning.withValues(alpha: 0.08)
                  : isDark
                      ? AppColors.backgroundDark
                      : AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: _isRunning
                    ? AppColors.warning.withValues(alpha: 0.3)
                    : isDark
                        ? AppColors.borderDark
                        : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatElapsed(_elapsedSeconds),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: Responsive.sp(48),
                    fontWeight: FontWeight.w700,
                    color: _isRunning
                        ? AppColors.warning
                        : isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  _isRunning ? 'المؤقت شغال...' : 'المؤقت واقف',
                  style: AppTypography.caption.copyWith(
                    color: _isRunning
                        ? AppColors.warning
                        : isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.lg),

          // الأزرار
          _isRunning
              ? SekkaButton(
                  label: 'وقّف المؤقت',
                  type: SekkaButtonType.secondary,
                  icon: IconsaxPlusLinear.timer_pause,
                  onPressed: _stop,
                )
              : SekkaButton(
                  label: 'ابدأ المؤقت',
                  icon: IconsaxPlusLinear.timer_1,
                  onPressed: _start,
                ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  6. ACTION AREA (fixed at bottom)
// ═══════════════════════════════════════════════════════════════════════════
class _ActionArea extends StatelessWidget {
  const _ActionArea({
    required this.order,
    required this.orderId,
    required this.isLoading,
  });

  final OrderModel order;
  final String orderId;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final status = order.status;

    // Terminal states — show status banner
    // لو عنده deliveredAt يعني اتسلّم حتى لو الـ status رقم مختلف
    final isActuallyDelivered = order.deliveredAt != null;

    if (status == OrderStatus.delivered ||
        status == OrderStatus.cancelled ||
        status == OrderStatus.returned ||
        status == OrderStatus.partiallyDelivered ||
        isActuallyDelivered) {
      final effectiveStatus =
          isActuallyDelivered ? OrderStatus.delivered : status;
      return _buildTerminalBanner(context, effectiveStatus);
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.md,
        AppSizes.pagePadding,
        AppSizes.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textHeadline.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _buildActions(context, status),
    );
  }

  Widget _buildTerminalBanner(BuildContext context, OrderStatus status) {
    final (icon, label, color) = switch (status) {
      OrderStatus.delivered => (
          IconsaxPlusBold.tick_circle,
          'الطلب اتسلّم بنجاح',
          AppColors.success,
        ),
      OrderStatus.partiallyDelivered => (
          IconsaxPlusBold.box_tick,
          'اتسلّم جزء من الطلب',
          AppColors.warning,
        ),
      OrderStatus.cancelled => (
          IconsaxPlusBold.close_circle,
          'الطلب ده اتلغى',
          AppColors.error,
        ),
      OrderStatus.returned => (
          IconsaxPlusBold.box_remove,
          'الطلب رجع تاني',
          AppColors.error,
        ),
      _ => (
          IconsaxPlusBold.info_circle,
          status.arabic,
          AppColors.textCaption,
        ),
    };

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.lg,
        AppSizes.pagePadding,
        AppSizes.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border(
          top: BorderSide(color: color.withValues(alpha: 0.2), width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizes.iconLg, color: color),
          SizedBox(width: AppSizes.md),
          Text(
            label,
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, OrderStatus status) {
    return switch (status) {
      OrderStatus.pending ||
      OrderStatus.retryPending ||
      OrderStatus.accepted ||
      OrderStatus.pickedUp => SekkaButton(
          label: AppStrings.startDelivery,
          isLoading: isLoading,
          onPressed: () => _dispatch(context, 3),
        ),
      OrderStatus.inTransit || OrderStatus.arrivedAtDestination => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زرار التسليم الرئيسي (swipe)
            SekkaSwipeAction(
              label: AppStrings.swipeToDeliver,
              onCompleted: () => _showDeliverSheet(context),
            ),
            SizedBox(height: AppSizes.md),
            // الأزرار الثانوية — صف أول
            Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    label: 'تسليم جزئي',
                    icon: IconsaxPlusLinear.box_tick,
                    color: AppColors.warning,
                    onTap: () => _showPartialSheet(context),
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _ActionChip(
                    label: 'معرفتش أسلّم',
                    icon: IconsaxPlusLinear.close_circle,
                    color: AppColors.error,
                    onTap: () => _showFailSheet(context),
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _ActionChip(
                    label: 'ألغي الطلب',
                    icon: IconsaxPlusLinear.trash,
                    color: AppColors.textCaption,
                    onTap: () => _showCancelSheet(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      OrderStatus.failed => SekkaButton(
          label: AppStrings.retryDelivery,
          isLoading: isLoading,
          onPressed: () => _dispatch(context, 9),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  void _dispatch(BuildContext context, int newStatus) {
    context.read<OrdersBloc>().add(
          OrderStatusChangeRequested(orderId: orderId, newStatus: newStatus),
        );
  }

  void _showDeliverSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<OrdersBloc>(),
        child: _DeliverBottomSheet(
          orderId: orderId,
        ),
      ),
    );
  }

  void _showFailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<OrdersBloc>(),
        child: _FailBottomSheet(orderId: orderId),
      ),
    );
  }

  void _showCancelSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<OrdersBloc>(),
        child: _CancelBottomSheet(orderId: orderId),
      ),
    );
  }

  void _showPartialSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<OrdersBloc>(),
        child: _PartialDeliveryBottomSheet(
          orderId: orderId,
          totalItemCount: order.itemCount ?? 1,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SHARED: handle bar for bottom sheets
// ═══════════════════════════════════════════════════════════════════════════
Widget _buildHandle() {
  return Center(
    child: Container(
      margin: EdgeInsets.only(top: AppSizes.md),
      width: Responsive.w(40),
      height: Responsive.h(4),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
    ),
  );
}

// ───────────────── ACTION CHIP ─────────────────

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.xs,
          vertical: Responsive.h(10),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconMd, color: color),
            SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 1: DELIVER
// ═══════════════════════════════════════════════════════════════════════════
class _DeliverBottomSheet extends StatefulWidget {
  const _DeliverBottomSheet({
    required this.orderId,
  });

  final String orderId;

  @override
  State<_DeliverBottomSheet> createState() => _DeliverBottomSheetState();
}

class _DeliverBottomSheetState extends State<_DeliverBottomSheet> {
  final _notesCtrl = TextEditingController();
  int _rating = 5;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
        });
      }
    } catch (_) {
      // موقع مش متاح — مش مشكلة، optional
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                SizedBox(height: AppSizes.lg),
                Text(AppStrings.confirmDelivery, style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.lg),
                // Star rating
                Text('قيّم العميل', style: AppTypography.titleMedium),
                SizedBox(height: AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(
                        i < _rating
                            ? IconsaxPlusBold.star_1
                            : IconsaxPlusLinear.star_1,
                        color: i < _rating
                            ? AppColors.warning
                            : AppColors.textCaption,
                        size: AppSizes.iconXl,
                      ),
                      onPressed: () => setState(() => _rating = i + 1),
                    );
                  }),
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _notesCtrl,
                  hint: AppStrings.additionalNotes,
                  maxLines: 3,
                  prefixIcon: IconsaxPlusLinear.note_text,
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirmDelivery,
                  onPressed: () {
                    context.read<OrdersBloc>().add(
                          OrderDeliverRequested(
                            orderId: widget.orderId,
                            latitude: _lat,
                            longitude: _lng,
                            notes: _notesCtrl.text.isEmpty
                                ? null
                                : _notesCtrl.text,
                            rating: _rating,
                          ),
                        );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 2: FAIL
// ═══════════════════════════════════════════════════════════════════════════
class _FailBottomSheet extends StatefulWidget {
  const _FailBottomSheet({required this.orderId});
  final String orderId;

  @override
  State<_FailBottomSheet> createState() => _FailBottomSheetState();
}

class _FailBottomSheetState extends State<_FailBottomSheet> {
  DeliveryFailReason? _selectedReason;
  final _detailsCtrl = TextEditingController();

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                SizedBox(height: AppSizes.lg),
                Text(AppStrings.failDelivery, style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.md),
                Text(AppStrings.failReason, style: AppTypography.titleMedium),
                SizedBox(height: AppSizes.sm),
                ...DeliveryFailReason.values.map(
                  (r) => RadioListTile<DeliveryFailReason>(
                    title: Text(r.arabic, style: AppTypography.bodyMedium),
                    value: r,
                    groupValue: _selectedReason,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _selectedReason = v),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _detailsCtrl,
                  hint: 'تفاصيل أكتر (اختياري)',
                  maxLines: 3,
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirm,
                  onPressed: _selectedReason == null
                      ? null
                      : () {
                          context.read<OrdersBloc>().add(
                                OrderFailRequested(
                                  orderId: widget.orderId,
                                  reason: _selectedReason!.value,
                                  reasonText: _detailsCtrl.text.isEmpty
                                      ? null
                                      : _detailsCtrl.text,
                                ),
                              );
                          Navigator.pop(context);
                        },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 3: CANCEL
// ═══════════════════════════════════════════════════════════════════════════
class _CancelBottomSheet extends StatefulWidget {
  const _CancelBottomSheet({required this.orderId});
  final String orderId;

  @override
  State<_CancelBottomSheet> createState() => _CancelBottomSheetState();
}

class _CancelBottomSheetState extends State<_CancelBottomSheet> {
  CancellationReason? _selectedReason;
  final _detailsCtrl = TextEditingController();

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                SizedBox(height: AppSizes.lg),
                Text(AppStrings.cancelOrder, style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.md),
                Text(AppStrings.cancelReason, style: AppTypography.titleMedium),
                SizedBox(height: AppSizes.sm),
                ...CancellationReason.values.map(
                  (r) => RadioListTile<CancellationReason>(
                    title: Text(r.arabic, style: AppTypography.bodyMedium),
                    value: r,
                    groupValue: _selectedReason,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _selectedReason = v),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _detailsCtrl,
                  hint: 'تفاصيل أكتر (اختياري)',
                  maxLines: 3,
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirm,
                  onPressed: _selectedReason == null
                      ? null
                      : () {
                          context.read<OrdersBloc>().add(
                                OrderCancelRequested(
                                  orderId: widget.orderId,
                                  reason: _selectedReason!.value,
                                  reasonText: _detailsCtrl.text.isEmpty
                                      ? null
                                      : _detailsCtrl.text,
                                ),
                              );
                          Navigator.pop(context);
                        },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 4: PARTIAL DELIVERY
// ═══════════════════════════════════════════════════════════════════════════
class _PartialDeliveryBottomSheet extends StatefulWidget {
  const _PartialDeliveryBottomSheet({
    required this.orderId,
    required this.totalItemCount,
  });

  final String orderId;
  final int totalItemCount;

  @override
  State<_PartialDeliveryBottomSheet> createState() =>
      _PartialDeliveryBottomSheetState();
}

class _PartialDeliveryBottomSheetState
    extends State<_PartialDeliveryBottomSheet> {
  final _deliveredCountCtrl = TextEditingController();
  late final TextEditingController _totalCountCtrl;
  final _collectedAmountCtrl = TextEditingController();
  final _remainingAmountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _totalCountCtrl = TextEditingController(
      text: '${widget.totalItemCount}',
    );
  }

  @override
  void dispose() {
    _deliveredCountCtrl.dispose();
    _totalCountCtrl.dispose();
    _collectedAmountCtrl.dispose();
    _remainingAmountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                SizedBox(height: AppSizes.lg),
                Text('تسليم جزئي', style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.lg),
                SekkaInputField(
                  controller: _deliveredCountCtrl,
                  hint: 'كام قطعة سلّمت؟',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _totalCountCtrl,
                  hint: 'إجمالي القطع',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _collectedAmountCtrl,
                  hint: 'المبلغ اللي حصّلته',
                  keyboardType: TextInputType.number,
                  prefixIcon: IconsaxPlusLinear.money_recive,
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _remainingAmountCtrl,
                  hint: 'المبلغ المتبقي',
                  keyboardType: TextInputType.number,
                  prefixIcon: IconsaxPlusLinear.money_send,
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _reasonCtrl,
                  hint: 'السبب (اختياري)',
                  maxLines: 2,
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirm,
                  onPressed: () {
                    final delivered =
                        int.tryParse(_deliveredCountCtrl.text) ?? 0;
                    final total = int.tryParse(_totalCountCtrl.text) ??
                        widget.totalItemCount;
                    final collected =
                        double.tryParse(_collectedAmountCtrl.text) ?? 0;
                    final remaining =
                        double.tryParse(_remainingAmountCtrl.text) ?? 0;
                    context.read<OrdersBloc>().add(
                          OrderPartialDeliveryRequested(
                            orderId: widget.orderId,
                            deliveredItemCount: delivered,
                            totalItemCount: total,
                            collectedAmount: collected,
                            remainingAmount: remaining,
                            reason: _reasonCtrl.text.isEmpty
                                ? null
                                : _reasonCtrl.text,
                          ),
                        );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 5: TRANSFER
// ═══════════════════════════════════════════════════════════════════════════
class _TransferBottomSheet extends StatefulWidget {
  const _TransferBottomSheet({required this.orderId});
  final String orderId;

  @override
  State<_TransferBottomSheet> createState() => _TransferBottomSheetState();
}

class _TransferBottomSheetState extends State<_TransferBottomSheet> {
  final _driverIdCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _driverIdCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _onDriverIdChanged(String value) {
    final canNow = value.trim().isNotEmpty;
    if (canNow != _canSubmit) setState(() => _canSubmit = canNow);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                SizedBox(height: AppSizes.lg),
                Text('حوّل لسائق تاني', style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.lg),
                SekkaInputField(
                  controller: _driverIdCtrl,
                  hint: 'رقم السائق',
                  prefixIcon: IconsaxPlusLinear.user,
                  onChanged: _onDriverIdChanged,
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _reasonCtrl,
                  hint: 'السبب (اختياري)',
                  maxLines: 2,
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirm,
                  onPressed: !_canSubmit
                      ? null
                      : () {
                          context.read<OrdersBloc>().add(
                                OrderTransferRequested(
                                  orderId: widget.orderId,
                                  targetDriverId: _driverIdCtrl.text.trim(),
                                  reason: _reasonCtrl.text.isEmpty
                                      ? null
                                      : _reasonCtrl.text,
                                ),
                              );
                          Navigator.pop(context);
                        },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 6: SWAP ADDRESS
// ═══════════════════════════════════════════════════════════════════════════
class _SwapAddressBottomSheet extends StatefulWidget {
  const _SwapAddressBottomSheet({required this.orderId});
  final String orderId;

  @override
  State<_SwapAddressBottomSheet> createState() =>
      _SwapAddressBottomSheetState();
}

class _SwapAddressBottomSheetState extends State<_SwapAddressBottomSheet> {
  final _addressCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  double? _newLat;
  double? _newLng;
  bool get _canSubmit => _addressCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await SekkaMapPicker.show(
      context,
      title: 'حدد العنوان الجديد',
    );
    if (result == null || !mounted) return;

    setState(() {
      _newLat = result.latitude;
      _newLng = result.longitude;
      _addressCtrl.text = result.address ??
          '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final hasCoords = _newLat != null && _newLng != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                SizedBox(height: AppSizes.lg),
                Text('غيّر العنوان', style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.lg),
                // Address field — tap to open map
                GestureDetector(
                  onTap: _openMapPicker,
                  child: Container(
                    constraints:
                        BoxConstraints(minHeight: AppSizes.inputHeight),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.md,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius:
                          BorderRadius.circular(AppSizes.inputRadius),
                      border: Border.all(
                        color: hasCoords ? AppColors.success : borderColor,
                        width: hasCoords ? 2 : 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          IconsaxPlusLinear.location,
                          size: AppSizes.iconLg,
                          color:
                              hasCoords ? AppColors.success : captionColor,
                        ),
                        SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Text(
                            _addressCtrl.text.isNotEmpty
                                ? _addressCtrl.text
                                : 'اضغط عشان تحدد العنوان الجديد',
                            style: _addressCtrl.text.isNotEmpty
                                ? AppTypography.bodyMedium
                                : AppTypography.bodyMedium
                                    .copyWith(color: captionColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: AppSizes.sm),
                        if (hasCoords)
                          Icon(
                            Icons.check_circle,
                            size: AppSizes.iconMd,
                            color: AppColors.success,
                          )
                        else
                          Icon(
                            IconsaxPlusLinear.map,
                            size: AppSizes.iconMd,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _reasonCtrl,
                  hint: 'السبب (اختياري)',
                  maxLines: 2,
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirm,
                  onPressed: !_canSubmit
                      ? null
                      : () {
                          context.read<OrdersBloc>().add(
                                OrderSwapAddressRequested(
                                  orderId: widget.orderId,
                                  newAddress: _addressCtrl.text.trim(),
                                  reason: _reasonCtrl.text.isEmpty
                                      ? null
                                      : _reasonCtrl.text,
                                ),
                              );
                          Navigator.pop(context);
                        },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 7: DISCLAIMER
// ═══════════════════════════════════════════════════════════════════════════
class _DisclaimerBottomSheet extends StatefulWidget {
  const _DisclaimerBottomSheet({required this.orderId});
  final String orderId;

  @override
  State<_DisclaimerBottomSheet> createState() => _DisclaimerBottomSheetState();
}

class _DisclaimerBottomSheetState extends State<_DisclaimerBottomSheet> {
  final _conditionCtrl = TextEditingController();
  final _itemsCtrl = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _conditionCtrl.dispose();
    _itemsCtrl.dispose();
    super.dispose();
  }

  void _checkCanSubmit() {
    final canNow =
        _conditionCtrl.text.trim().isNotEmpty &&
        _itemsCtrl.text.trim().isNotEmpty;
    if (canNow != _canSubmit) setState(() => _canSubmit = canNow);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                SizedBox(height: AppSizes.lg),
                Text('إخلاء مسؤولية', style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.lg),
                SekkaInputField(
                  controller: _conditionCtrl,
                  hint: 'حالة الشحنة (مثلاً: مكسورة، مفتوحة)',
                  label: 'حالة الشحنة',
                  maxLines: 3,
                  onChanged: (_) => _checkCanSubmit(),
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _itemsCtrl,
                  hint: 'وصف المحتويات (مثلاً: 2 كرتونة، علبة)',
                  label: 'وصف المحتويات',
                  maxLines: 3,
                  onChanged: (_) => _checkCanSubmit(),
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirm,
                  onPressed: !_canSubmit
                      ? null
                      : () {
                          context.read<OrdersBloc>().add(
                                OrderDisclaimerPostRequested(
                                  orderId: widget.orderId,
                                  data: {
                                    'condition': _conditionCtrl.text.trim(),
                                    'itemsDescription': _itemsCtrl.text.trim(),
                                  },
                                ),
                              );
                          Navigator.pop(context);
                        },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 8: DISPUTE
// ═══════════════════════════════════════════════════════════════════════════
class _DisputeBottomSheet extends StatefulWidget {
  const _DisputeBottomSheet({required this.orderId});
  final String orderId;

  @override
  State<_DisputeBottomSheet> createState() => _DisputeBottomSheetState();
}

class _DisputeBottomSheetState extends State<_DisputeBottomSheet> {
  final _descriptionCtrl = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _onDescriptionChanged(String value) {
    final canNow = value.trim().isNotEmpty;
    if (canNow != _canSubmit) setState(() => _canSubmit = canNow);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                SizedBox(height: AppSizes.lg),
                Text('فتح نزاع', style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.lg),
                SekkaInputField(
                  controller: _descriptionCtrl,
                  hint: 'اوصف المشكلة بالتفصيل',
                  maxLines: 5,
                  onChanged: _onDescriptionChanged,
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirm,
                  onPressed: !_canSubmit
                      ? null
                      : () {
                          context.read<OrdersBloc>().add(
                                OrderDisputeRequested(
                                  orderId: widget.orderId,
                                  data: {
                                    'description':
                                        _descriptionCtrl.text.trim(),
                                  },
                                ),
                              );
                          Navigator.pop(context);
                        },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 9: REFUND
// ═══════════════════════════════════════════════════════════════════════════
class _RefundBottomSheet extends StatefulWidget {
  const _RefundBottomSheet({
    required this.orderId,
    required this.currentAmount,
  });

  final String orderId;
  final double currentAmount;

  @override
  State<_RefundBottomSheet> createState() => _RefundBottomSheetState();
}

class _RefundBottomSheetState extends State<_RefundBottomSheet> {
  late final TextEditingController _amountCtrl;
  final _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.currentAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                SizedBox(height: AppSizes.lg),
                Text('طلب استرداد', style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.lg),
                SekkaInputField(
                  controller: _amountCtrl,
                  hint: 'مبلغ الاسترداد',
                  keyboardType: TextInputType.number,
                  prefixIcon: IconsaxPlusLinear.money_recive,
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _reasonCtrl,
                  hint: 'سبب الاسترداد',
                  maxLines: 3,
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirm,
                  onPressed: () {
                    final amount = double.tryParse(_amountCtrl.text);
                    context.read<OrdersBloc>().add(
                          OrderRefundRequested(
                            orderId: widget.orderId,
                            data: {
                              'amount': amount,
                              'reason': _reasonCtrl.text,
                            },
                          ),
                        );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  BOOK SLOT BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════

class _BookSlotBottomSheet extends StatefulWidget {
  const _BookSlotBottomSheet({required this.orderId});
  final String orderId;

  @override
  State<_BookSlotBottomSheet> createState() => _BookSlotBottomSheetState();
}

class _BookSlotBottomSheetState extends State<_BookSlotBottomSheet> {
  final _slotIdCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  @override
  void dispose() {
    _slotIdCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: Responsive.w(40),
                    height: Responsive.h(4),
                    margin: EdgeInsets.only(bottom: AppSizes.lg),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                  ),
                ),
                Text(
                  'احجز موعد تسليم',
                  style: AppTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.xxl),
                SekkaInputField(
                  controller: _slotIdCtrl,
                  hint: 'رقم الموعد',
                  prefixIcon: IconsaxPlusLinear.timer_1,
                ),
                SizedBox(height: AppSizes.lg),
                SekkaInputField(
                  controller: _dateCtrl,
                  hint: 'التاريخ (مثال: 2026-03-28)',
                  prefixIcon: IconsaxPlusLinear.calendar_1,
                ),
                SizedBox(height: AppSizes.xxl),
                SekkaButton(
                  label: 'احجز الموعد',
                  icon: IconsaxPlusLinear.tick_circle,
                  onPressed: () {
                    if (_slotIdCtrl.text.trim().isEmpty) return;
                    context.read<OrdersBloc>().add(
                          OrderBookSlotRequested(
                            orderId: widget.orderId,
                            data: {
                              'slotId': _slotIdCtrl.text.trim(),
                              if (_dateCtrl.text.trim().isNotEmpty)
                                'date': _dateCtrl.text.trim(),
                            },
                          ),
                        );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
