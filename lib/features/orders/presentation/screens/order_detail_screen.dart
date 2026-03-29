import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      OrderStatus.inTransit => badge.OrderStatus.onTheWay,
      OrderStatus.arrivedAtDestination => badge.OrderStatus.arrived,
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
      OrderStatus.inTransit => AppColors.statusOnTheWay,
      OrderStatus.arrivedAtDestination => AppColors.statusArrived,
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
              Text('اختار نوع الصورة', style: AppTypography.headlineSmall),
              SizedBox(height: AppSizes.md),
              ...PhotoType.values.map(
                (pt) => ListTile(
                  title: Text(pt.arabic, style: AppTypography.bodyLarge),
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
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: const SekkaBackButton(),
      title: Text(AppStrings.orderDetails, style: AppTypography.headlineSmall),
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(state.actionMessage!),
            ),
            backgroundColor: AppColors.success,
          ),
        );
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

  Widget _buildBody(OrderModel order, bool isActionInProgress) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            children: [
              _StatusHeaderCard(order: order),
              SizedBox(height: AppSizes.md),
              _CustomerAddressCard(order: order),
              SizedBox(height: AppSizes.md),
              _FinancialCard(order: order),
              SizedBox(height: AppSizes.md),
              _DetailsCard(order: order),
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
//  1. STATUS HEADER CARD
// ═══════════════════════════════════════════════════════════════════════════
class _StatusHeaderCard extends StatelessWidget {
  const _StatusHeaderCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return SekkaCard(
      child: Column(
        children: [
          Row(
            children: [
              badge.StatusBadge(status: _mapToBadgeStatus(order.status)),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  order.status.arabic,
                  style: AppTypography.titleLarge.copyWith(color: color),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          _infoRow(
            IconsaxPlusLinear.calendar_1,
            AppStrings.createdAt,
            _dateFmt.format(order.createdAt),
          ),
          if (order.deliveredAt != null) ...[
            SizedBox(height: AppSizes.sm),
            _infoRow(
              IconsaxPlusLinear.tick_circle,
              AppStrings.deliveredAt,
              _dateFmt.format(order.deliveredAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: AppColors.textCaption),
        SizedBox(width: AppSizes.sm),
        Text('$label: ', style: AppTypography.caption),
        Expanded(
          child: Text(value, style: AppTypography.bodySmall),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  2. CUSTOMER & ADDRESSES CARD
// ═══════════════════════════════════════════════════════════════════════════
class _CustomerAddressCard extends StatelessWidget {
  const _CustomerAddressCard({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      child: Column(
        children: [
          // Customer name
          if (order.customerName != null && order.customerName!.isNotEmpty)
            _row(
              context,
              IconsaxPlusLinear.user,
              order.customerName!,
            ),
          // Phone + Quick Message
          if (order.customerPhone != null && order.customerPhone!.isNotEmpty) ...[
            SizedBox(height: AppSizes.sm),
            GestureDetector(
              onTap: () => _callPhone(order.customerPhone!),
              onLongPress: () => _copyPhone(context, order.customerPhone!),
              child: _row(
                context,
                IconsaxPlusLinear.call,
                order.customerPhone!,
                valueColor: AppColors.primary,
              ),
            ),
          ],
          // Quick Message Button
          SizedBox(height: AppSizes.sm),
          GestureDetector(
            onTap: () => _showQuickMessages(context, order.customerPhone),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(12),
                vertical: Responsive.h(10),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    IconsaxPlusBold.message_text,
                    size: AppSizes.iconMd,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSizes.sm),
                  Text(
                    AppStrings.quickMessages,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Delivery address
          SizedBox(height: AppSizes.sm),
          _row(
            context,
            IconsaxPlusLinear.location,
            order.deliveryAddress,
          ),
          // Pickup address
          if (order.pickupAddress != null && order.pickupAddress!.isNotEmpty) ...[
            SizedBox(height: AppSizes.sm),
            _row(
              context,
              IconsaxPlusLinear.location_tick,
              order.pickupAddress!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text,
      {Color? valueColor,}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMd, color: AppColors.textCaption),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: valueColor,
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
        onTemplateSelected: (messageText) {
          if (phone != null && phone.isNotEmpty) {
            _sendWhatsApp(phone, messageText);
          } else {
            Clipboard.setData(ClipboardData(text: messageText));
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
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
        const SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(AppStrings.phoneCopied),
          ),
          backgroundColor: AppColors.success,
        ),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: multiLine
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption),
                SizedBox(height: AppSizes.xs),
                Text(value, style: AppTypography.bodyMedium),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTypography.caption),
                Flexible(
                  child: Text(
                    value,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: AppColors.border);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  5. WAITING TIMER SECTION
// ═══════════════════════════════════════════════════════════════════════════
class _WaitingTimerSection extends StatelessWidget {
  const _WaitingTimerSection({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      child: Column(
        children: [
          Text('مؤقت الانتظار', style: AppTypography.titleLarge),
          SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: SekkaButton(
                  label: 'ابدأ المؤقت',
                  type: SekkaButtonType.primary,
                  icon: IconsaxPlusLinear.timer_1,
                  onPressed: () {
                    context.read<OrdersBloc>().add(
                          OrderWaitingStartRequested(orderId: orderId),
                        );
                  },
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: SekkaButton(
                  label: 'وقّف المؤقت',
                  type: SekkaButtonType.secondary,
                  icon: IconsaxPlusLinear.timer_pause,
                  onPressed: () {
                    context.read<OrdersBloc>().add(
                          OrderWaitingStopRequested(orderId: orderId),
                        );
                  },
                ),
              ),
            ],
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

    // Terminal states with no actions
    if (status == OrderStatus.delivered ||
        status == OrderStatus.cancelled ||
        status == OrderStatus.returned ||
        status == OrderStatus.partiallyDelivered) {
      return const SizedBox.shrink();
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

  Widget _buildActions(BuildContext context, OrderStatus status) {
    return switch (status) {
      OrderStatus.pending || OrderStatus.retryPending => SekkaButton(
          label: AppStrings.acceptOrder,
          isLoading: isLoading,
          onPressed: () => _dispatch(context, 1),
        ),
      OrderStatus.accepted => SekkaButton(
          label: AppStrings.pickedUpOrder,
          isLoading: isLoading,
          onPressed: () => _dispatch(context, 2),
        ),
      OrderStatus.pickedUp => SekkaButton(
          label: AppStrings.startDelivery,
          isLoading: isLoading,
          onPressed: () => _dispatch(context, 3),
        ),
      OrderStatus.inTransit || OrderStatus.arrivedAtDestination => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SekkaSwipeAction(
              label: AppStrings.swipeToDeliver,
              onCompleted: () => _showDeliverSheet(context),
            ),
            SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: SekkaButton(
                    label: 'تسليم جزئي',
                    type: SekkaButtonType.text,
                    onPressed: () => _showPartialSheet(context),
                  ),
                ),
                Expanded(
                  child: SekkaButton(
                    label: AppStrings.failDelivery,
                    type: SekkaButtonType.text,
                    onPressed: () => _showFailSheet(context),
                  ),
                ),
                Expanded(
                  child: SekkaButton(
                    label: 'ألغي',
                    type: SekkaButtonType.text,
                    onPressed: () => _showCancelSheet(context),
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
          currentAmount: order.amount,
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

// ═══════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET 1: DELIVER
// ═══════════════════════════════════════════════════════════════════════════
class _DeliverBottomSheet extends StatefulWidget {
  const _DeliverBottomSheet({
    required this.orderId,
    required this.currentAmount,
  });

  final String orderId;
  final double currentAmount;

  @override
  State<_DeliverBottomSheet> createState() => _DeliverBottomSheetState();
}

class _DeliverBottomSheetState extends State<_DeliverBottomSheet> {
  late final TextEditingController _amountCtrl;
  final _notesCtrl = TextEditingController();
  int _rating = 5;

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
                SekkaInputField(
                  controller: _amountCtrl,
                  hint: AppStrings.collectedAmount,
                  keyboardType: TextInputType.number,
                  prefixIcon: IconsaxPlusLinear.money_recive,
                ),
                SizedBox(height: AppSizes.md),
                // Star rating
                Text('تقييم التسليم', style: AppTypography.titleMedium),
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
                    final amount = double.tryParse(_amountCtrl.text);
                    context.read<OrdersBloc>().add(
                          OrderDeliverRequested(
                            orderId: widget.orderId,
                            actualAmount: amount,
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
  bool _canSubmit = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _onAddressChanged(String value) {
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
                Text('غيّر العنوان', style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.lg),
                SekkaInputField(
                  controller: _addressCtrl,
                  hint: 'العنوان الجديد',
                  prefixIcon: IconsaxPlusLinear.location,
                  maxLines: 2,
                  onChanged: _onAddressChanged,
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
  final _contentCtrl = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  void _onContentChanged(String value) {
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
                Text('إخلاء مسؤولية', style: AppTypography.headlineSmall),
                SizedBox(height: AppSizes.lg),
                SekkaInputField(
                  controller: _contentCtrl,
                  hint: 'اكتب نص إخلاء المسؤولية',
                  maxLines: 5,
                  onChanged: _onContentChanged,
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
                                  data: {'content': _contentCtrl.text.trim()},
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
