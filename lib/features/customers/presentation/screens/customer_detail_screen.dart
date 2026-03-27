import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/network/dio_client.dart';
import '../../data/models/address_model.dart';
import '../../data/models/customer_detail_model.dart';
import '../../data/models/customer_order_model.dart';
import '../../data/models/customer_rating_model.dart';
import '../../data/repositories/customer_repository.dart';
import '../bloc/customer_detail_bloc.dart';
import '../widgets/rate_customer_sheet.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final CustomerDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    final dioClient = context.read<DioClient>();
    final repository = CustomerRepository(dioClient.dio);
    _bloc = CustomerDetailBloc(repository: repository);
    _bloc.add(CustomerDetailLoadRequested(widget.customerId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.customerDetails,
          style: AppTypography.titleLarge.copyWith(
            color:
                isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            IconsaxPlusLinear.arrow_right_3,
            color:
                isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<CustomerDetailBloc, CustomerDetailState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is CustomerDetailActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            CustomerDetailInitial() ||
            CustomerDetailLoading() =>
              const SekkaLoading(),
            CustomerDetailError(:final message) => SekkaEmptyState(
                icon: IconsaxPlusLinear.warning_2,
                title: message,
                actionLabel: 'جرّب تاني',
                onAction: () {
                  _bloc.add(
                    CustomerDetailLoadRequested(widget.customerId),
                  );
                },
              ),
            CustomerDetailActionSuccess() => const SekkaLoading(),
            CustomerDetailLoaded(:final customer) =>
              _buildContent(customer, isDark),
          };
        },
      ),
    );
  }

  Widget _buildContent(CustomerDetailModel customer, bool isDark) {
    final displayName = customer.name ?? customer.phone;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Responsive.h(16)),

          // Profile header
          _buildProfileHeader(customer, displayName, isDark),

          SizedBox(height: Responsive.h(20)),

          // Stats row
          _buildStatsRow(customer, isDark),

          SizedBox(height: Responsive.h(24)),

          // Addresses section
          if (customer.addresses.isNotEmpty) ...[
            _buildSectionTitle(AppStrings.addresses, isDark),
            SizedBox(height: Responsive.h(12)),
            ...customer.addresses.map(
              (address) => _buildAddressCard(address, isDark),
            ),
            SizedBox(height: Responsive.h(24)),
          ],

          // Recent orders section
          if (customer.recentOrders.isNotEmpty) ...[
            _buildSectionTitle(AppStrings.orders, isDark),
            SizedBox(height: Responsive.h(12)),
            ...customer.recentOrders.map(
              (order) => _buildOrderCard(order, isDark),
            ),
            SizedBox(height: Responsive.h(24)),
          ],

          // Ratings section
          if (customer.ratings.isNotEmpty) ...[
            _buildSectionTitle(AppStrings.averageRating, isDark),
            SizedBox(height: Responsive.h(12)),
            ...customer.ratings.map(
              (rating) => _buildRatingCard(rating, isDark),
            ),
            SizedBox(height: Responsive.h(24)),
          ],

          // Action buttons
          _buildActionButtons(customer, isDark),

          SizedBox(height: Responsive.h(40)),
        ],
      ),
    );
  }

  // ── Profile Header ──

  Widget _buildProfileHeader(
    CustomerDetailModel customer,
    String displayName,
    bool isDark,
  ) {
    final initial = displayName.characters.first;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(Responsive.r(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(Responsive.w(24)),
      child: Column(
        children: [
          // Avatar
          Container(
            width: Responsive.r(80),
            height: Responsive.r(80),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: Responsive.sp(32),
                ),
              ),
            ),
          ),

          SizedBox(height: Responsive.h(14)),

          // Name
          Text(
            displayName,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: Responsive.h(6)),

          // Phone
          Text(
            customer.phone,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
            ),
          ),

          SizedBox(height: Responsive.h(12)),

          // Rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconsaxPlusBold.star_1,
                size: Responsive.r(20),
                color: AppColors.warning,
              ),
              SizedBox(width: Responsive.w(6)),
              Text(
                customer.averageRating.toStringAsFixed(1),
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Blocked badge
          if (customer.isBlocked) ...[
            SizedBox(height: Responsive.h(12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(16),
                vertical: Responsive.h(6),
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                AppStrings.blocked,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Stats Row ──

  Widget _buildStatsRow(CustomerDetailModel customer, bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          value: '${customer.totalDeliveries}',
          label: AppStrings.totalDeliveries,
          isDark: isDark,
        ),
        SizedBox(width: Responsive.w(10)),
        _buildStatCard(
          value: '${customer.successfulDeliveries}',
          label: AppStrings.successfulDeliveries,
          isDark: isDark,
        ),
        SizedBox(width: Responsive.w(10)),
        _buildStatCard(
          value: customer.averageRating.toStringAsFixed(1),
          label: AppStrings.averageRating,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Expanded(
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.symmetric(
          vertical: Responsive.h(14),
          horizontal: Responsive.w(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: Responsive.h(4)),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(
                color:
                    isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Title ──

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.titleLarge.copyWith(
        color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
      ),
    );
  }

  // ── Address Card ──

  Widget _buildAddressCard(AddressModel address, bool isDark) {
    final addressTypeLabel = _addressTypeLabel(address.addressType);

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.location,
                  size: Responsive.r(18),
                  color: AppColors.primary,
                ),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Text(
                    address.addressText,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(10),
                    vertical: Responsive.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    addressTypeLabel,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (address.landmarks != null &&
                address.landmarks!.isNotEmpty) ...[
              SizedBox(height: Responsive.h(8)),
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.map_1,
                    size: Responsive.r(14),
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  SizedBox(width: Responsive.w(6)),
                  Expanded(
                    child: Text(
                      address.landmarks!,
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
            ],
            if (address.deliveryNotes != null &&
                address.deliveryNotes!.isNotEmpty) ...[
              SizedBox(height: Responsive.h(6)),
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.note_1,
                    size: Responsive.r(14),
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  SizedBox(width: Responsive.w(6)),
                  Expanded(
                    child: Text(
                      address.deliveryNotes!,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _addressTypeLabel(int type) {
    return switch (type) {
      0 => AppStrings.addressHome,
      1 => AppStrings.addressWork,
      2 => AppStrings.addressShop,
      3 => AppStrings.addressRestaurant,
      4 => AppStrings.addressWarehouse,
      _ => AppStrings.addressOther,
    };
  }

  // ── Order Card ──

  Widget _buildOrderCard(CustomerOrderModel order, bool isDark) {
    final orderStatus = _mapStatus(order.status);

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.orderId}',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    _formatDate(order.orderDate),
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${order.total.toStringAsFixed(0)} ${AppStrings.currency}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Responsive.h(6)),
                StatusBadge(
                  status: orderStatus,
                  compact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  OrderStatus _mapStatus(String status) {
    return switch (status.toLowerCase()) {
      'new' || 'neworder' => OrderStatus.newOrder,
      'ontheway' => OrderStatus.onTheWay,
      'arrived' => OrderStatus.arrived,
      'delivered' => OrderStatus.delivered,
      'failed' => OrderStatus.failed,
      'cancelled' => OrderStatus.cancelled,
      'returned' => OrderStatus.returned,
      'postponed' => OrderStatus.postponed,
      _ => OrderStatus.newOrder,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ── Rating Card ──

  Widget _buildRatingCard(CustomerRatingModel rating, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Stars
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.ratingValue
                          ? IconsaxPlusBold.star_1
                          : IconsaxPlusLinear.star,
                      size: Responsive.r(16),
                      color: AppColors.warning,
                    );
                  }),
                ),
                const Spacer(),
                Text(
                  _formatDate(rating.createdAt),
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ),
            if (rating.driverName != null) ...[
              SizedBox(height: Responsive.h(8)),
              Text(
                rating.driverName!,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (rating.feedbackText != null &&
                rating.feedbackText!.isNotEmpty) ...[
              SizedBox(height: Responsive.h(6)),
              Text(
                rating.feedbackText!,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Action Buttons ──

  Widget _buildActionButtons(CustomerDetailModel customer, bool isDark) {
    return Column(
      children: [
        SekkaButton(
          label: AppStrings.rateCustomer,
          icon: IconsaxPlusLinear.star,
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => RateCustomerSheet(
                onSubmit: (rating) {
                  Navigator.of(context).pop();
                  _bloc.add(CustomerRateRequested(
                    customerId: widget.customerId,
                    rating: rating,
                  ));
                },
              ),
            );
          },
        ),
        SizedBox(height: Responsive.h(12)),
        SekkaButton(
          label: customer.isBlocked
              ? AppStrings.unblockCustomer
              : AppStrings.blockCustomer,
          icon: customer.isBlocked
              ? IconsaxPlusLinear.unlock
              : IconsaxPlusLinear.lock,
          type: SekkaButtonType.secondary,
          onPressed: () {
            if (customer.isBlocked) {
              _bloc.add(
                CustomerUnblockRequested(widget.customerId),
              );
            } else {
              _showBlockDialog(isDark);
            }
          },
        ),
      ],
    );
  }

  void _showBlockDialog(bool isDark) {
    final reasonController = TextEditingController();
    var reportToCommunity = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              title: Text(
                AppStrings.blockCustomer,
                style: AppTypography.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: reasonController,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.bodyMedium,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: AppStrings.blockReason,
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textCaption,
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),
                  Row(
                    children: [
                      Checkbox(
                        value: reportToCommunity,
                        onChanged: (value) {
                          setDialogState(() {
                            reportToCommunity = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: Text(
                          AppStrings.reportToCommunity,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textBodyDark
                                : AppColors.textBody,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    AppStrings.cancel,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _bloc.add(CustomerBlockRequested(
                      customerId: widget.customerId,
                      reason: reasonController.text,
                      reportToCommunity: reportToCommunity,
                    ));
                  },
                  child: Text(
                    AppStrings.confirm,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
