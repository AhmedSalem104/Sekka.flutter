import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/sekka_avatar.dart';
import '../../../../shared/enums/order_enums.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notifications/data/repositories/notification_repository.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_event.dart';
import '../../../orders/presentation/bloc/orders_state.dart';
import '../../../orders/presentation/screens/create_order_screen.dart';
import '../../../orders/presentation/screens/order_detail_screen.dart';
import '../../../orders/presentation/widgets/deliver_bottom_sheet.dart';
import '../../../settlements/presentation/screens/create_settlement_screen.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../routes/presentation/bloc/route_bloc.dart';
import '../../../routes/presentation/bloc/route_event.dart';
import '../../../routes/presentation/screens/navigation_screen.dart';
import '../../../statistics/data/datasources/statistics_remote_datasource.dart';
import '../../../statistics/data/repositories/statistics_repository_impl.dart';
import '../../../statistics/presentation/bloc/statistics_bloc.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';
import '../bloc/daily_stats_bloc.dart';
import '../../../breaks/presentation/bloc/break_bloc.dart';
import '../../../breaks/presentation/widgets/active_break_card.dart';
import '../../../breaks/presentation/widgets/break_suggestion_card.dart';
import '../../../shifts/presentation/bloc/shift_bloc.dart';
import '../../../shifts/presentation/bloc/shift_event.dart';
import '../../../shifts/presentation/bloc/shift_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onAvatarTap});

  final VoidCallback? onAvatarTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _autoRefreshTimer;
  Timer? _shiftDurationTimer;

  @override
  void initState() {
    super.initState();
    // Initial load on first frame so orders/route are fresh on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshAll();
    });
    // Auto-refresh every 30 seconds
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshAll(),
    );
    // Tick every 30s to keep shift-duration pill fresh
    _shiftDurationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _shiftDurationTimer?.cancel();
    super.dispose();
  }

  String _formatShiftDuration(DateTime startTime) {
    final diff = DateTime.now().difference(startTime);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours${AppStrings.hour} $minutes${AppStrings.minute}';
    }
    return '$minutes${AppStrings.minute}';
  }

  void _refreshAll() {
    if (!mounted) return;
    context.read<ShiftBloc>().add(const ShiftCheckRequested());
    context.read<ProfileBloc>().add(const ProfileRefreshRequested());
    context.read<BreakBloc>().add(const BreakCheckRequested());
    context.read<OrdersBloc>().add(const OrdersLoadRequested(refresh: true));
    context.read<RouteBloc>().add(const RouteActiveLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => _refreshAll(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.h(16)),
                _buildAppBar(context, isDark),
                SizedBox(height: Responsive.h(20)),
                _buildGreetingSection(context, isDark),
                SizedBox(height: Responsive.h(20)),
                _buildOrangeSection(context, isDark),
                SizedBox(height: Responsive.h(16)),
                _buildQuickActions(context, isDark),
                SizedBox(height: Responsive.h(24)),
                _buildBreakSection(context, isDark),
                SizedBox(height: Responsive.h(24)),
                _buildRouteCard(context, isDark),
                SizedBox(height: Responsive.h(24)),
                _buildParkingCard(context, isDark),
                SizedBox(height: Responsive.h(24)),
                _buildStatisticsCard(context, isDark),
                SizedBox(height: Responsive.h(120)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openNotifications(BuildContext context) {
    final dio = context.read<DioClient>().dio;
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => NotificationsBloc(
            repository: NotificationRepository(dio),
          )..add(const NotificationsLoadRequested()),
          child: const NotificationsScreen(),
        ),
      ),
    );
  }

  // ── App Bar ──

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final profileState = context.watch<ProfileBloc>().state;
    final imageUrl = profileState is ProfileLoaded
        ? profileState.profile.profileImageUrl
        : null;
    final authState = context.watch<AuthBloc>().state;
    final fullName =
        authState is AuthAuthenticated ? authState.driver.name : '';
    final firstName = fullName.split(' ').first;

    return Row(
      children: [
        GestureDetector(
          onTap: widget.onAvatarTap,
          child: SekkaAvatar(imageUrl: imageUrl, size: 46),
        ),
        SizedBox(width: Responsive.w(10)),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.welcomeBack}، $firstName',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        _buildSmallShiftToggle(context, isDark),
        SizedBox(width: Responsive.w(8)),
        _NotificationBadge(
          isDark: isDark,
          onTap: () async => _openNotifications(context),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  GREETING SECTION — الترحيب + اللوكيشن + احصائيات صغيرة
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildGreetingSection(BuildContext context, bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location
          _LocationChipNeutral(isDark: isDark),
          SizedBox(height: Responsive.h(12)),

          // Small daily stats row (3 fields)
          BlocBuilder<DailyStatsBloc, DailyStatsState>(
            builder: (context, state) {
              final stats = state is DailyStatsLoaded ? state.stats : null;
              return Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.money_recive,
                    size: Responsive.r(14),
                    color: AppColors.success,
                  ),
                  SizedBox(width: Responsive.w(4)),
                  Text(
                    stats != null
                        ? '${stats.netProfit.toInt()} ${AppStrings.currency}'
                        : '--',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: Responsive.w(12)),
                  Icon(
                    IconsaxPlusLinear.wallet_money,
                    size: Responsive.r(14),
                    color: AppColors.warning,
                  ),
                  SizedBox(width: Responsive.w(4)),
                  Text(
                    stats != null
                        ? '${stats.earnings.toInt()} ${AppStrings.currency}'
                        : '--',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: Responsive.w(12)),
                  Icon(
                    IconsaxPlusLinear.box_1,
                    size: Responsive.r(14),
                    color: AppColors.info,
                  ),
                  SizedBox(width: Responsive.w(4)),
                  Text(
                    stats != null
                        ? '${stats.totalOrders} ${AppStrings.statOrders}'
                        : '--',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Small Shift Toggle Button ──

  Widget _buildSmallShiftToggle(BuildContext context, bool isDark) {
    return BlocBuilder<ShiftBloc, ShiftState>(
      builder: (context, state) {
        final isActive = state is ShiftLoaded && state.isActive;
        final isToggling = state is ShiftLoaded && state.isToggling;
        final isLoading = state is ShiftLoading || isToggling;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  if (isActive) {
                    _showEndShiftDialog(context);
                  } else {
                    context
                        .read<ShiftBloc>()
                        .add(const ShiftStartRequested());
                  }
                },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(12),
              vertical: Responsive.h(6),
            ),
            decoration: BoxDecoration(
              gradient: isActive
                  ? null
                  : const LinearGradient(
                      colors: [
                        AppColors.gradientStart,
                        AppColors.gradientEnd,
                      ],
                    ),
              color: isActive ? AppColors.error.withValues(alpha: 0.1) : null,
              borderRadius: BorderRadius.circular(Responsive.r(8)),
              border: isActive
                  ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: Responsive.r(12),
                    height: Responsive.r(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: isActive
                          ? AppColors.error
                          : AppColors.textOnPrimary,
                    ),
                  )
                else
                  Icon(
                    isActive
                        ? IconsaxPlusBold.stop_circle
                        : IconsaxPlusBold.play_circle,
                    size: Responsive.r(14),
                    color: isActive
                        ? AppColors.error
                        : AppColors.textOnPrimary,
                  ),
                SizedBox(width: Responsive.w(4)),
                Text(
                  isActive
                      ? AppStrings.shiftEnd
                      : AppStrings.shiftStart,
                  style: AppTypography.captionSmall.copyWith(
                    color: isActive
                        ? AppColors.error
                        : AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isActive) ...[
                  SizedBox(width: Responsive.w(4)),
                  Container(
                    width: Responsive.r(6),
                    height: Responsive.r(6),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ORANGE SECTION — أضف طلب / طلب في الطريق
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildOrangeSection(BuildContext context, bool isDark) {
    final ordersState = context.watch<OrdersBloc>().state;
    final shiftState = context.watch<ShiftBloc>().state;

    final isShiftActive = shiftState is ShiftLoaded && shiftState.isActive;
    final currentShift =
        shiftState is ShiftLoaded ? shiftState.currentShift : null;

    OrderModel? inTransitOrder;
    OrderModel? firstOrderToday;
    bool hasActiveOrder = false;
    if (ordersState is OrdersLoaded) {
      final activeOrders = ordersState.orders.where((o) =>
          o.status == OrderStatus.pending ||
          o.status == OrderStatus.accepted ||
          o.status == OrderStatus.pickedUp ||
          o.status == OrderStatus.inTransit ||
          o.status == OrderStatus.arrivedAtDestination);
      hasActiveOrder = activeOrders.isNotEmpty;
      final transit = activeOrders
          .where((o) => o.status == OrderStatus.inTransit)
          .toList();
      if (transit.isNotEmpty) inTransitOrder = transit.first;

      final now = DateTime.now();
      final todayPending = activeOrders
          .where((o) =>
              (o.status == OrderStatus.pending ||
                  o.status == OrderStatus.accepted) &&
              o.createdAt.year == now.year &&
              o.createdAt.month == now.month &&
              o.createdAt.day == now.day)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (todayPending.isNotEmpty) firstOrderToday = todayPending.first;
    }

    final Widget content;
    if (inTransitOrder != null) {
      content = _buildInTransitOrder(context, inTransitOrder);
    } else if (isShiftActive) {
      content = _buildIdleHero(context);
    } else if (firstOrderToday != null) {
      content = _buildStartShiftWithOrderHero(context, firstOrderToday);
    } else {
      content = _buildAddOrderCta(context);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(20)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(Responsive.r(16)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isShiftActive && currentShift != null) ...[
              Row(
                children: [
                  _buildShiftPill(currentShift.startTime),
                  const Spacer(),
                  if (inTransitOrder == null)
                    _buildSmallAddOrderButton(context),
                ],
              ),
              SizedBox(height: Responsive.h(12)),
            ],
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildShiftPill(DateTime startTime) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(10),
        vertical: Responsive.h(5),
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(Responsive.r(100)),
        border: Border.all(
          color: AppColors.textOnPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Responsive.r(7),
            height: Responsive.r(7),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: Responsive.w(6)),
          Text(
            '${_formatShiftDuration(startTime)} • ${AppStrings.shiftActive}',
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAddOrderButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const CreateOrderScreen(),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(12),
          vertical: Responsive.h(5),
        ),
        decoration: BoxDecoration(
          color: AppColors.textOnPrimary,
          borderRadius: BorderRadius.circular(Responsive.r(100)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconsaxPlusBold.add_circle,
              size: Responsive.r(14),
              color: AppColors.primary,
            ),
            SizedBox(width: Responsive.w(4)),
            Text(
              AppStrings.addOrder,
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleHero(BuildContext context) {
    final shiftState = context.watch<ShiftBloc>().state;
    final shift = shiftState is ShiftLoaded ? shiftState.currentShift : null;
    final earnings = shift?.earningsTotal ?? 0;
    final ordersCount = shift?.ordersCompleted ?? 0;

    final profileState = context.watch<ProfileBloc>().state;
    final cash =
        profileState is ProfileLoaded ? profileState.profile.cashOnHand : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metrics row: earnings | orders count (compact)
        Row(
          children: [
            Expanded(
              child: _IdleMetricTile(
                icon: IconsaxPlusBold.wallet_money,
                label: AppStrings.shiftEarnings,
                value: '${earnings.toInt()} ${AppStrings.currency}',
              ),
            ),
            SizedBox(width: Responsive.w(8)),
            Expanded(
              child: _IdleMetricTile(
                icon: IconsaxPlusBold.box_1,
                label: AppStrings.shiftOrders,
                value: '$ordersCount',
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(8)),
        // Cash section (compact)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(12),
            vertical: Responsive.h(8),
          ),
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(Responsive.r(10)),
            border: Border.all(
              color: AppColors.textOnPrimary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                IconsaxPlusBold.empty_wallet,
                size: Responsive.r(16),
                color: AppColors.textOnPrimary,
              ),
              SizedBox(width: Responsive.w(8)),
              Expanded(
                child: Text(
                  AppStrings.cashWithYouNow,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${cash.toInt()} ${AppStrings.currency}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  QUICK ACTIONS — 4 كروت إجراءات سريعة
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: IconsaxPlusLinear.money_send,
              label: AppStrings.quickSettleCash,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const CreateSettlementScreen(),
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: _QuickActionCard(
              icon: IconsaxPlusLinear.add_circle,
              label: AppStrings.quickAddOrder,
              isDark: isDark,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const CreateOrderScreen(),
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: _QuickActionCard(
              icon: IconsaxPlusLinear.add,
              label: '',
              isDark: isDark,
              isPlaceholder: true,
              onTap: () {},
            ),
          ),
          SizedBox(width: Responsive.w(8)),
          Expanded(
            child: _QuickActionCard(
              icon: IconsaxPlusLinear.add,
              label: '',
              isDark: isDark,
              isPlaceholder: true,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOrderCta(BuildContext context) {
    return Row(
      children: [
        // Text side
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.startDeliveringNow,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.h(4)),
              Text(
                AppStrings.addOrdersToStart,
                style: AppTypography.captionSmall.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: Responsive.w(12)),
        // Button side
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const CreateOrderScreen(),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(16),
              vertical: Responsive.h(10),
            ),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary,
              borderRadius: BorderRadius.circular(Responsive.r(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  IconsaxPlusBold.add_circle,
                  color: AppColors.primary,
                  size: Responsive.r(18),
                ),
                SizedBox(width: Responsive.w(6)),
                Text(
                  AppStrings.addOrder,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Start-Shift Hero (shift not started + has orders today) ──

  Widget _buildStartShiftWithOrderHero(BuildContext context, OrderModel order) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailScreen(orderId: order.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.startShiftWithOrder,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: Responsive.h(6)),
          Text(
            AppStrings.deliverFirstOrder,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Responsive.h(12)),
          Container(
            padding: EdgeInsets.all(Responsive.w(12)),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Responsive.r(12)),
              border: Border.all(
                color: AppColors.textOnPrimary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: Responsive.r(36),
                  height: Responsive.r(36),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Responsive.r(8)),
                  ),
                  child: Icon(
                    IconsaxPlusBold.box_1,
                    color: AppColors.textOnPrimary,
                    size: Responsive.r(20),
                  ),
                ),
                SizedBox(width: Responsive.w(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName ?? order.orderNumber,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        order.deliveryAddress,
                        style: AppTypography.captionSmall.copyWith(
                          color:
                              AppColors.textOnPrimary.withValues(alpha: 0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.w(8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${order.amount.toStringAsFixed(0)} ${AppStrings.currency}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Icon(
                      IconsaxPlusLinear.arrow_left_2,
                      size: Responsive.r(14),
                      color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── In-Transit Order ──

  Widget _chipDivider() {
    return Container(
      width: 1,
      height: Responsive.h(20),
      color: AppColors.textOnPrimary.withValues(alpha: 0.2),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required bool filled,
  }) {
    return Container(
      height: Responsive.h(48),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary,
        borderRadius: BorderRadius.circular(Responsive.r(14)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(Responsive.r(14)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primary, size: Responsive.r(20)),
                SizedBox(width: Responsive.w(8)),
                Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallAction(IconData icon) {
    return Container(
      width: Responsive.r(48),
      height: Responsive.r(48),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(Responsive.r(14)),
      ),
      child: Icon(icon, color: AppColors.textOnPrimary, size: Responsive.r(22)),
    );
  }

  // ── Shift Toggle ──

  Widget _buildShiftToggle(BuildContext context) {
    return BlocConsumer<ShiftBloc, ShiftState>(
      listenWhen: (prev, curr) {
        if (prev is ShiftLoaded && curr is ShiftLoaded) {
          return prev.isActive != curr.isActive;
        }
        if (curr is ShiftError) return true;
        return false;
      },
      listener: (context, state) {
        if (state is ShiftError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is ShiftLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isActive
                    ? AppStrings.shiftStarted
                    : AppStrings.shiftEnded,
              ),
              backgroundColor:
                  state.isActive ? AppColors.success : AppColors.textCaption,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final isActive = state is ShiftLoaded && state.isActive;
        final isToggling = state is ShiftLoaded && state.isToggling;
        final isLoading = state is ShiftLoading || isToggling;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  if (isActive) {
                    _showEndShiftDialog(context);
                  } else {
                    context
                        .read<ShiftBloc>()
                        .add(const ShiftStartRequested());
                  }
                },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: Responsive.h(14)),
            decoration: BoxDecoration(
              gradient: isActive
                  ? null
                  : const LinearGradient(
                      colors: [
                        AppColors.gradientStart,
                        AppColors.gradientEnd,
                      ],
                    ),
              color: isActive ? AppColors.error.withValues(alpha: 0.1) : null,
              borderRadius: BorderRadius.circular(Responsive.r(12)),
              border: isActive
                  ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: Responsive.r(18),
                    height: Responsive.r(18),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isActive
                          ? AppColors.error
                          : AppColors.textOnPrimary,
                    ),
                  )
                else
                  Icon(
                    isActive
                        ? IconsaxPlusBold.stop_circle
                        : IconsaxPlusBold.play_circle,
                    size: Responsive.r(20),
                    color: isActive
                        ? AppColors.error
                        : AppColors.textOnPrimary,
                  ),
                SizedBox(width: Responsive.w(8)),
                Text(
                  isActive
                      ? AppStrings.shiftEnd
                      : AppStrings.shiftStart,
                  style: AppTypography.titleMedium.copyWith(
                    color: isActive
                        ? AppColors.error
                        : AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isActive) ...[
                  SizedBox(width: Responsive.w(8)),
                  Container(
                    width: Responsive.r(8),
                    height: Responsive.r(8),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEndShiftDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.r(16)),
        ),
        title: Text(
          AppStrings.shiftEnd,
          textDirection: TextDirection.rtl,
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.textHeadlineDark
                : AppColors.textHeadline,
          ),
        ),
        content: Text(
          AppStrings.shiftEndConfirm,
          textDirection: TextDirection.rtl,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ShiftBloc>().add(const ShiftEndRequested());
            },
            child: Text(
              AppStrings.confirm,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Earnings Card ──

  Widget _buildEarningsCard(BuildContext context, bool isDark) {
    return BlocBuilder<DailyStatsBloc, DailyStatsState>(
      buildWhen: (prev, curr) {
        if (prev is DailyStatsLoaded && curr is DailyStatsLoaded) {
          return prev.stats != curr.stats;
        }
        return true;
      },
      builder: (context, state) {
        final stats = state is DailyStatsLoaded ? state.stats : null;

        return GestureDetector(
          onTap: () {
            final dioClient = context.read<DioClient>();
            final dataSource = StatisticsRemoteDataSource(dioClient);
            final repository = StatisticsRepositoryImpl(
              remoteDataSource: dataSource,
            );
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) {
                    final bloc = StatisticsBloc(repository: repository);
                    if (bloc.state is! StatisticsLoaded) {
                      bloc.add(
                          const StatisticsTabChanged(StatisticsTab.weekly));
                    }
                    return bloc;
                  },
                  child: const StatisticsScreen(),
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.w(18)),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(Responsive.r(16)),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: Responsive.r(36),
                        height: Responsive.r(36),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(Responsive.r(10)),
                        ),
                        child: Icon(
                          IconsaxPlusLinear.wallet_money,
                          color: AppColors.success,
                          size: Responsive.r(18),
                        ),
                      ),
                      SizedBox(width: Responsive.w(10)),
                      Text(
                        AppStrings.todayEarnings,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.textHeadlineDark
                              : AppColors.textHeadline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        IconsaxPlusLinear.arrow_left_2,
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                        size: Responsive.r(16),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(16)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              stats != null
                                  ? '${stats.netProfit.toInt()}'
                                  : '--',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: Responsive.h(2)),
                            Text(
                              AppStrings.netProfit,
                              style: AppTypography.captionSmall.copyWith(
                                color: isDark
                                    ? AppColors.textCaptionDark
                                    : AppColors.textCaption,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _earningsDivider(isDark),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              stats != null
                                  ? '${stats.earnings.toInt()}'
                                  : '--',
                              style: AppTypography.headlineMedium.copyWith(
                                color: isDark
                                    ? AppColors.textHeadlineDark
                                    : AppColors.textHeadline,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: Responsive.h(2)),
                            Text(
                              AppStrings.totalEarningsLabel,
                              style: AppTypography.captionSmall.copyWith(
                                color: isDark
                                    ? AppColors.textCaptionDark
                                    : AppColors.textCaption,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _earningsDivider(isDark),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              stats != null
                                  ? '${stats.totalOrders}'
                                  : '--',
                              style: AppTypography.headlineMedium.copyWith(
                                color: isDark
                                    ? AppColors.textHeadlineDark
                                    : AppColors.textHeadline,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: Responsive.h(2)),
                            Text(
                              AppStrings.statOrders,
                              style: AppTypography.captionSmall.copyWith(
                                color: isDark
                                    ? AppColors.textCaptionDark
                                    : AppColors.textCaption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _earningsDivider(bool isDark) {
    return Container(
      width: 1,
      height: Responsive.h(36),
      color: isDark ? AppColors.borderDark : AppColors.border,
    );
  }

  // ── Break Section ──

  Widget _buildBreakSection(BuildContext context, bool isDark) {
    return BlocConsumer<BreakBloc, BreakState>(
      listenWhen: (prev, curr) => curr is BreakStarted || curr is BreakEnded,
      listener: (context, state) {
        if (state is BreakStarted || state is BreakEnded) {
          context.read<BreakBloc>().add(const BreakCheckRequested());
        }
      },
      buildWhen: (prev, curr) => curr is BreakCheckLoaded,
      builder: (context, state) {
        if (state is! BreakCheckLoaded) return const SizedBox.shrink();
        if (state.activeBreak != null) {
          return ActiveBreakCard(activeBreak: state.activeBreak!, isDark: isDark);
        }
        if (state.suggestion != null && state.suggestion!.shouldBreak) {
          return BreakSuggestionCard(suggestion: state.suggestion!, isDark: isDark);
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ── Route Optimize Button ──

  // ── In-Transit Order ──

  Widget _buildInTransitOrder(BuildContext context, OrderModel order) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailScreen(orderId: order.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            AppStrings.statusOnTheWay,
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: Responsive.h(8)),

          // Order info row
          Row(
            children: [
              // Customer + address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName ?? order.orderNumber,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      order.deliveryAddress,
                      style: AppTypography.captionSmall.copyWith(
                        color:
                            AppColors.textOnPrimary.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Amount + arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${order.amount.toStringAsFixed(0)} ${AppStrings.currency}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Icon(
                    IconsaxPlusLinear.arrow_left_2,
                    size: Responsive.r(14),
                    color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          Row(
            children: [
              Expanded(
                child: _InTransitActionButton(
                  icon: IconsaxPlusLinear.map,
                  label: AppStrings.trackOnMap,
                  onTap: () => _openOrderOnMap(order),
                ),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: _InTransitActionButton(
                  icon: IconsaxPlusBold.tick_circle,
                  label: AppStrings.deliverShort,
                  filled: true,
                  onTap: () => showDeliverBottomSheet(
                    context,
                    orderId: order.id,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openOrderOnMap(OrderModel order) async {
    final lat = order.deliveryLatitude;
    final lng = order.deliveryLongitude;
    final String query = (lat != null && lng != null && lat != 0 && lng != 0)
        ? '$lat,$lng'
        : Uri.encodeComponent(order.deliveryAddress);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ROUTE CARD — حسّن مسارك
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRouteCard(BuildContext context, bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(50),
            Responsive.w(20),
            Responsive.h(20),
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(Responsive.r(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textHeadline.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                AppStrings.optimizeYourRoute,
                style: AppTypography.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.h(4)),
              Text(
                AppStrings.optimizeRouteHint,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textCaption,
                ),
              ),
              SizedBox(height: Responsive.h(14)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const NavigationScreen(initialTab: 0),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(16),
                      vertical: Responsive.h(10),
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(Responsive.r(10)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      AppStrings.enterYourRouteBtn,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: Responsive.h(-20),
          left: 0,
          child: Image.asset(
            isDark
                ? 'assets/images/route_optimize_dark.png'
                : 'assets/images/route_optimize.png',
            height: Responsive.h(100),
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STATISTICS CARD — احصائياتي
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStatisticsCard(BuildContext context, bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(50),
            Responsive.w(20),
            Responsive.h(20),
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(Responsive.r(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textHeadline.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                AppStrings.detailedStatistics,
                style: AppTypography.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.h(4)),
              Text(
                AppStrings.viewDetailedStatsHint,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textCaption,
                ),
              ),
              SizedBox(height: Responsive.h(14)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: GestureDetector(
                  onTap: () {
                    final dioClient = context.read<DioClient>();
                    final dataSource = StatisticsRemoteDataSource(dioClient);
                    final repository = StatisticsRepositoryImpl(
                      remoteDataSource: dataSource,
                    );
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => BlocProvider(
                          create: (_) {
                            final bloc =
                                StatisticsBloc(repository: repository);
                            if (bloc.state is! StatisticsLoaded) {
                              bloc.add(const StatisticsTabChanged(
                                  StatisticsTab.weekly));
                            }
                            return bloc;
                          },
                          child: const StatisticsScreen(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(16),
                      vertical: Responsive.h(10),
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(Responsive.r(10)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      AppStrings.detailedStatistics,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: Responsive.h(-20),
          left: 0,
          child: Image.asset(
            isDark
                ? 'assets/images/statistics_card_dark.png'
                : 'assets/images/statistics_card.png',
            height: Responsive.h(100),
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PARKING CARD — أماكن الركن
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildParkingCard(BuildContext context, bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            Responsive.w(20),
            Responsive.h(50),
            Responsive.w(20),
            Responsive.h(20),
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(Responsive.r(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textHeadline.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                AppStrings.myParkingSpots,
                style: AppTypography.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.h(4)),
              Text(
                AppStrings.noParkingSpotsHint,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textCaption,
                ),
              ),
              SizedBox(height: Responsive.h(14)),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const NavigationScreen(initialTab: 1),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(16),
                      vertical: Responsive.h(10),
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(Responsive.r(10)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      AppStrings.nearbyParking,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: Responsive.h(-20),
          left: 0,
          child: Image.asset(
            isDark
                ? 'assets/images/parking_spot_dark.png'
                : 'assets/images/parking_spot.png',
            height: Responsive.h(100),
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
/// Notification icon with dynamic unread count badge.
class _NotificationBadge extends StatefulWidget {
  const _NotificationBadge({
    required this.isDark,
    required this.onTap,
  });
  final bool isDark;
  final Future<void> Function() onTap;

  @override
  State<_NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<_NotificationBadge> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final dio = context.read<DioClient>().dio;
    final repo = NotificationRepository(dio);
    final result = await repo.getUnreadCount();
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() => _unreadCount = data);
      case ApiFailure():
        break;
    }
  }

  Future<void> _handleTap() async {
    await widget.onTap();
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            IconsaxPlusLinear.notification,
            color: widget.isDark
                ? AppColors.textBodyDark
                : AppColors.textBody,
            size: Responsive.r(26),
          ),
          if (_unreadCount > 0)
            Positioned(
              top: -2,
              left: -4,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(5),
                  vertical: Responsive.h(1),
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(Responsive.r(10)),
                ),
                constraints: BoxConstraints(
                  minWidth: Responsive.r(16),
                  minHeight: Responsive.r(16),
                ),
                child: Center(
                  child: Text(
                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: Responsive.sp(9),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  LOCATION CHIP — الموقع الحالي (on primary — for orange sections)
// ══════════════════════════════════════════════════════════════════════════

class _LocationChip extends StatefulWidget {
  const _LocationChip();

  @override
  State<_LocationChip> createState() => _LocationChipState();
}

class _LocationChipState extends State<_LocationChip> {
  String _locationText = AppStrings.locatingPosition;
  bool _hasLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _locationText = AppStrings.locationServiceDisabled);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationText = AppStrings.locationPermissionDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Reverse geocoding to get address
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty && mounted) {
          final place = placemarks.first;
          final parts = <String>[
            if (place.subLocality?.isNotEmpty == true) place.subLocality!,
            if (place.locality?.isNotEmpty == true) place.locality!,
            if (place.administrativeArea?.isNotEmpty == true)
              place.administrativeArea!,
          ];
          setState(() {
            _locationText =
                parts.isNotEmpty ? parts.join('، ') : place.country ?? '';
            _hasLocation = true;
          });
          return;
        }
      } catch (_) {
        // Geocoding failed — fallback to coordinates
      }

      if (mounted) {
        setState(() {
          _locationText =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _hasLocation = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locationText = AppStrings.locationFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _hasLocation
              ? IconsaxPlusBold.location
              : IconsaxPlusLinear.location,
          size: Responsive.r(12),
          color: AppColors.textOnPrimary.withValues(alpha: 0.7),
        ),
        SizedBox(width: Responsive.w(4)),
        Text(
          _locationText,
          style: AppTypography.captionSmall.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  LOCATION CHIP NEUTRAL — الموقع الحالي (neutral colors)
// ══════════════════════════════════════════════════════════════════════════

class _LocationChipNeutral extends StatefulWidget {
  const _LocationChipNeutral({required this.isDark});

  final bool isDark;

  @override
  State<_LocationChipNeutral> createState() => _LocationChipNeutralState();
}

class _LocationChipNeutralState extends State<_LocationChipNeutral> {
  String _locationText = AppStrings.locatingPosition;
  bool _hasLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _locationText = AppStrings.locationServiceDisabled);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationText = AppStrings.locationPermissionDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty && mounted) {
          final place = placemarks.first;
          final parts = <String>[
            if (place.subLocality?.isNotEmpty == true) place.subLocality!,
            if (place.locality?.isNotEmpty == true) place.locality!,
            if (place.administrativeArea?.isNotEmpty == true)
              place.administrativeArea!,
          ];
          setState(() {
            _locationText =
                parts.isNotEmpty ? parts.join('، ') : place.country ?? '';
            _hasLocation = true;
          });
          return;
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _locationText =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _hasLocation = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locationText = AppStrings.locationFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _hasLocation
              ? IconsaxPlusBold.location
              : IconsaxPlusLinear.location,
          size: Responsive.r(14),
          color: AppColors.primary,
        ),
        SizedBox(width: Responsive.w(4)),
        Text(
          _locationText,
          style: AppTypography.captionSmall.copyWith(
            color: widget.isDark
                ? AppColors.textCaptionDark
                : AppColors.textCaption,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    if (isPlaceholder) {
      return SizedBox(height: Responsive.h(86));
    }

    final bg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final iconColor = AppColors.primary;
    final textColor =
        isDark ? AppColors.textHeadlineDark : AppColors.textHeadline;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: Responsive.h(86),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(4),
          vertical: Responsive.h(8),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Responsive.r(14)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textHeadline.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Responsive.r(34),
              height: Responsive.r(34),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Responsive.r(18),
                color: iconColor,
              ),
            ),
            if (label.isNotEmpty) ...[
              SizedBox(height: Responsive.h(6)),
              Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IdleMetricTile extends StatelessWidget {
  const _IdleMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(10),
        vertical: Responsive.h(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Responsive.r(10)),
        border: Border.all(
          color: AppColors.textOnPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: Responsive.r(16),
            color: AppColors.textOnPrimary,
          ),
          SizedBox(width: Responsive.w(6)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InTransitActionButton extends StatelessWidget {
  const _InTransitActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? AppColors.textOnPrimary
        : AppColors.textOnPrimary.withValues(alpha: 0.15);
    final fg = filled ? AppColors.primary : AppColors.textOnPrimary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(12),
          vertical: Responsive.h(10),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Responsive.r(10)),
          border: filled
              ? null
              : Border.all(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: Responsive.r(16), color: fg),
            SizedBox(width: Responsive.w(6)),
            Flexible(
              child: Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
