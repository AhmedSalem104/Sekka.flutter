import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../customers/data/models/caller_id_model.dart';
import '../../../customers/data/repositories/caller_id_repository.dart';
import '../../data/models/partner_model.dart';
import '../../data/models/partner_order_model.dart';
import '../../data/models/pickup_point_model.dart';
import '../../data/repositories/partner_repository.dart';
import '../bloc/partner_detail_bloc.dart';

class PartnerDetailScreen extends StatefulWidget {
  const PartnerDetailScreen({super.key, required this.partner});

  final PartnerModel partner;

  @override
  State<PartnerDetailScreen> createState() => _PartnerDetailScreenState();
}

class _PartnerDetailScreenState extends State<PartnerDetailScreen> {
  late final PartnerRepository _repository;
  late final PartnerDetailBloc _bloc;
  late final CallerIdRepository _callerIdRepo;
  CallerIdModel? _callerInfo;
  bool _callerLoading = false;

  @override
  void initState() {
    super.initState();
    final dioClient = context.read<DioClient>();
    _repository = PartnerRepository(dioClient.dio);
    _bloc = PartnerDetailBloc(repository: _repository);
    _callerIdRepo = CallerIdRepository(dioClient.dio);
    _bloc.add(PartnerDetailLoadRequested(partner: widget.partner));
    // Load caller info if partner has phone
    if (widget.partner.phone != null) {
      _loadCallerInfo(widget.partner.phone!);
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _loadCallerInfo(String phone) async {
    if (_callerLoading) return;
    setState(() => _callerLoading = true);
    final result = await _callerIdRepo.lookup(phone);
    if (!mounted) return;
    setState(() {
      _callerLoading = false;
      _callerInfo = switch (result) {
        ApiSuccess(:final data) => data,
        _ => null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final partnerColor = _parseColor(widget.partner.color);

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        appBar: SekkaAppBar(title: widget.partner.name),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.h(12)),

              // 1. Header Card
              _buildHeaderCard(partnerColor, isDark),
              SizedBox(height: Responsive.h(20)),

              // 2. Commission Section
              _buildCommissionSection(isDark),
              SizedBox(height: Responsive.h(20)),

              // 3. Caller ID Section
              if (widget.partner.phone != null)
                _buildCallerIdSection(widget.partner.phone!, isDark),

              // 4. Pickup Points Section
              BlocBuilder<PartnerDetailBloc, PartnerDetailState>(
                builder: (context, state) => switch (state) {
                  PartnerDetailLoaded(:final pickupPoints, :final orders) =>
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPickupPointsSection(pickupPoints, isDark),
                        SizedBox(height: Responsive.h(20)),
                        _buildRecentOrdersSection(orders.items, isDark),
                      ],
                    ),
                  PartnerDetailLoading() => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.h(40),
                      ),
                      child: const SekkaLoading(),
                    ),
                  PartnerDetailError(:final message) => SekkaEmptyState(
                      icon: IconsaxPlusLinear.warning_2,
                      title: message,
                      actionLabel: 'جرّب تاني',
                      onAction: () => _bloc.add(
                        PartnerDetailLoadRequested(partner: widget.partner),
                      ),
                    ),
                  PartnerDetailInitial() => const SizedBox.shrink(),
                },
              ),

              SizedBox(height: Responsive.h(40)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Card ──

  Widget _buildHeaderCard(Color partnerColor, bool isDark) {
    final partner = widget.partner;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            partnerColor,
            partnerColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(Responsive.r(20)),
        boxShadow: [
          BoxShadow(
            color: partnerColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(Responsive.w(20)),
      child: Column(
        children: [
          Row(
            children: [
              // Logo circle
              Container(
                width: Responsive.r(60),
                height: Responsive.r(60),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: partner.logoUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: partner.logoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              partner.name.isNotEmpty
                                  ? partner.name.characters.first
                                  : '',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          partner.name.isNotEmpty
                              ? partner.name.characters.first
                              : '',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: Responsive.w(16)),

              // Name + type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(6)),
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(10),
                            vertical: Responsive.h(4),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              Responsive.r(100),
                            ),
                          ),
                          child: Text(
                            _partnerTypeLabel(partner.partnerType),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.w(8)),

                        // Verification badge
                        _buildHeaderVerificationBadge(
                          partner.verificationStatus,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (partner.phone != null) ...[
            SizedBox(height: Responsive.h(14)),
            GestureDetector(
              onTap: () => PhoneLauncher.showOptions(
                context,
                partner.phone!,
                contactName: partner.name,
              ),
              child: Row(
                children: [
                  Icon(
                    IconsaxPlusBold.call,
                    size: Responsive.r(16),
                    color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Text(
                    partner.phone!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                      decoration: TextDecoration.underline,
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

  Widget _buildHeaderVerificationBadge(int status) {
    final (Color bgColor, String label) = switch (status) {
      1 => (
          AppColors.success.withValues(alpha: 0.3),
          AppStrings.statusVerified,
        ),
      2 => (
          AppColors.error.withValues(alpha: 0.3),
          AppStrings.statusRejected,
        ),
      _ => (
          AppColors.warning.withValues(alpha: 0.3),
          AppStrings.statusPending,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(10),
        vertical: Responsive.h(4),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Responsive.r(100)),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textOnPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Commission Section ──

  Widget _buildCommissionSection(bool isDark) {
    final partner = widget.partner;
    final commissionLabel = switch (partner.commissionType) {
      0 => AppStrings.fixedPerOrder,
      1 => AppStrings.percentagePerOrder,
      2 => AppStrings.monthlyFlat,
      _ => AppStrings.fixedPerOrder,
    };

    final commissionDisplay = partner.commissionType == 1
        ? '${partner.commissionValue.toStringAsFixed(0)}%'
        : '${partner.commissionValue.toStringAsFixed(0)} ${AppStrings.currency}';

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconsaxPlusBold.percentage_circle,
                color: AppColors.primary,
                size: Responsive.r(22),
              ),
              SizedBox(width: Responsive.w(8)),
              Text(
                AppStrings.commission,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                commissionLabel,
                style: AppTypography.bodyMedium.copyWith(
                  color:
                      isDark ? AppColors.textBodyDark : AppColors.textBody,
                ),
              ),
              Text(
                commissionDisplay,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Pickup Points Section ──

  Widget _buildPickupPointsSection(
    List<PickupPointModel> pickupPoints,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              IconsaxPlusBold.location,
              color: AppColors.primary,
              size: Responsive.r(22),
            ),
            SizedBox(width: Responsive.w(8)),
            Text(
              AppStrings.pickupPoints,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(width: Responsive.w(8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(8),
                vertical: Responsive.h(2),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Responsive.r(100)),
              ),
              child: Text(
                '${pickupPoints.length}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(12)),
        if (pickupPoints.isEmpty)
          SekkaCard(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            padding: EdgeInsets.all(Responsive.w(16)),
            child: Center(
              child: Text(
                'لا توجد نقاط استلام',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                ),
              ),
            ),
          )
        else
          ...pickupPoints.map(
            (point) => Padding(
              padding: EdgeInsets.only(bottom: Responsive.h(10)),
              child: _buildPickupPointCard(point, isDark),
            ),
          ),
      ],
    );
  }

  Widget _buildPickupPointCard(PickupPointModel point, bool isDark) {
    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            point.name,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Responsive.h(6)),
          Row(
            children: [
              Icon(
                IconsaxPlusLinear.location,
                size: Responsive.r(14),
                color:
                    isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              ),
              SizedBox(width: Responsive.w(4)),
              Flexible(
                child: Text(
                  point.address,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          Row(
            children: [
              // Rating
              Icon(
                IconsaxPlusBold.star_1,
                size: Responsive.r(16),
                color: AppColors.warning,
              ),
              SizedBox(width: Responsive.w(4)),
              Text(
                point.driverRating.toStringAsFixed(1),
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: Responsive.w(20)),

              // Waiting time
              Icon(
                IconsaxPlusLinear.clock,
                size: Responsive.r(16),
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
              SizedBox(width: Responsive.w(4)),
              Text(
                '${point.averageWaitingMinutes.toStringAsFixed(0)} ${AppStrings.minutes}',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recent Orders Section ──

  Widget _buildRecentOrdersSection(
    List<PartnerOrderModel> orders,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              IconsaxPlusBold.box_1,
              color: AppColors.primary,
              size: Responsive.r(22),
            ),
            SizedBox(width: Responsive.w(8)),
            Text(
              AppStrings.orders,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(12)),
        if (orders.isEmpty)
          SekkaCard(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            padding: EdgeInsets.all(Responsive.w(16)),
            child: Center(
              child: Text(
                'لا توجد طلبات',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                ),
              ),
            ),
          )
        else
          ...orders.map(
            (order) => Padding(
              padding: EdgeInsets.only(bottom: Responsive.h(10)),
              child: _buildOrderCard(order, isDark),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderCard(PartnerOrderModel order, bool isDark) {
    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: date + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                ),
              ),
              _buildOrderStatusBadge(order.status, isDark),
            ],
          ),
          SizedBox(height: Responsive.h(10)),

          // Customer + total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (order.customerName != null)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        IconsaxPlusLinear.profile_circle,
                        size: Responsive.r(16),
                        color: isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody,
                      ),
                      SizedBox(width: Responsive.w(6)),
                      Flexible(
                        child: Text(
                          order.customerName!,
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark
                                ? AppColors.textHeadlineDark
                                : AppColors.textHeadline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                '${order.total.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Driver name
          if (order.driverName != null) ...[
            SizedBox(height: Responsive.h(6)),
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.truck_fast,
                  size: Responsive.r(14),
                  color: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                ),
                SizedBox(width: Responsive.w(6)),
                Text(
                  order.driverName!,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderStatusBadge(String status, bool isDark) {
    final (Color bgColor, Color textColor) = switch (status.toLowerCase()) {
      'delivered' || 'تم التسليم' => (
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
        ),
      'cancelled' || 'ملغي' => (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error,
        ),
      'failed' || 'فشل' => (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error,
        ),
      _ => (
          AppColors.warning.withValues(alpha: 0.12),
          AppColors.warning,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(10),
        vertical: Responsive.h(4),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Responsive.r(100)),
      ),
      child: Text(
        status,
        style: AppTypography.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Helpers ──

  Color _parseColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  String _partnerTypeLabel(int type) => switch (type) {
        0 => AppStrings.restaurantType,
        1 => AppStrings.shopType,
        2 => AppStrings.pharmacyType,
        3 => AppStrings.supermarketType,
        4 => AppStrings.warehouseType,
        5 => AppStrings.eCommerceType,
        _ => 'أخرى',
      };

  // ── Caller ID Section ──

  String _contactTypeLabel(int type) => switch (type) {
        0 => AppStrings.callerTypeUnknown,
        1 => AppStrings.callerTypeCustomer,
        2 => AppStrings.callerTypePartner,
        3 => AppStrings.callerTypeDriver,
        _ => AppStrings.callerTypeOther,
      };

  Widget _buildCallerIdSection(String phone, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.callerId,
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        SizedBox(height: Responsive.h(12)),
        if (_callerLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_callerInfo != null)
          _buildCallerInfoCard(_callerInfo!, isDark)
        else
          SekkaCard(
            child: Row(
              children: [
                Icon(
                  IconsaxPlusLinear.call,
                  color: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                  size: AppSizes.iconMd,
                ),
                SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    phone,
                    style: AppTypography.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.textBodyDark : AppColors.textBody,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _loadCallerInfo(phone),
                  child: Text(
                    AppStrings.callerCheckTruecaller,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: Responsive.h(20)),
      ],
    );
  }

  Widget _buildCallerInfoCard(CallerIdModel info, bool isDark) {
    return SekkaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact type + note button
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  _contactTypeLabel(info.contactType),
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (info.isBlocked) ...[
                SizedBox(width: AppSizes.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    AppStrings.blocked,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () => _showNoteSheet(info, isDark),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        info.note != null
                            ? IconsaxPlusLinear.edit
                            : IconsaxPlusLinear.add,
                        color: AppColors.primary,
                        size: Responsive.r(12),
                      ),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        info.note != null
                            ? AppStrings.callerEditNote
                            : AppStrings.callerAddNote,
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Rating + last order
          if (info.lastOrderDate != null || info.averageRating != null) ...[
            SizedBox(height: AppSizes.md),
            Row(
              children: [
                if (info.averageRating != null) ...[
                  Icon(
                    IconsaxPlusLinear.star_1,
                    size: Responsive.r(14),
                    color: AppColors.warning,
                  ),
                  SizedBox(width: AppSizes.xs),
                  Text(
                    info.averageRating!.toStringAsFixed(1),
                    style: AppTypography.captionSmall.copyWith(
                      color:
                          isDark ? AppColors.textBodyDark : AppColors.textBody,
                    ),
                  ),
                  SizedBox(width: AppSizes.lg),
                ],
                if (info.lastOrderDate != null) ...[
                  Icon(
                    IconsaxPlusLinear.clock,
                    size: Responsive.r(14),
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  SizedBox(width: AppSizes.xs),
                  Text(
                    '${AppStrings.callerLastOrder}: ${info.lastOrderDate!.day}/${info.lastOrderDate!.month}/${info.lastOrderDate!.year}',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ],
            ),
          ],

          // Note
          if (info.note != null && info.note!.isNotEmpty) ...[
            SizedBox(height: AppSizes.md),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color:
                    isDark ? AppColors.backgroundDark : AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    IconsaxPlusLinear.note_1,
                    size: Responsive.r(14),
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      info.note!,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody,
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

  void _showNoteSheet(CallerIdModel info, bool isDark) {
    final controller = TextEditingController(text: info.note ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.sheetRadius),
        ),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.xxl,
          AppSizes.pagePadding,
          MediaQuery.of(ctx).viewInsets.bottom + AppSizes.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.w(40),
              height: Responsive.h(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
            ),
            SizedBox(height: AppSizes.xxl),
            Text(
              info.note != null
                  ? AppStrings.callerEditNote
                  : AppStrings.callerAddNote,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: AppSizes.xl),
            SekkaInputField(
              controller: controller,
              label: AppStrings.callerNote,
              hint: AppStrings.callerNoteHintPartner,
              prefixIcon: IconsaxPlusLinear.note_1,
              maxLines: 3,
            ),
            SizedBox(height: AppSizes.xxl),
            SekkaButton(
              label: AppStrings.save,
              onPressed: () async {
                Navigator.pop(ctx);
                final note = controller.text.trim();
                final result = await _callerIdRepo.createNote(
                  phoneNumber: info.phoneNumber,
                  contactType: info.contactType,
                  displayName: info.displayName,
                  note: note.isEmpty ? null : note,
                );
                if (!mounted) return;
                if (result is ApiSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.callerNoteSaved,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textOnPrimary),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadCallerInfo(info.phoneNumber);
                }
              },
              icon: IconsaxPlusLinear.tick_circle,
            ),
          ],
        ),
      ),
    );
  }
}
