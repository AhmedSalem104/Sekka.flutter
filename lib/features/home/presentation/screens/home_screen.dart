import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
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
import '../../../orders/presentation/bloc/orders_state.dart';
import '../../../orders/presentation/screens/order_detail_screen.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
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
import '../../../sync/presentation/widgets/sync_status_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onAvatarTap});

  final VoidCallback? onAvatarTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh every 30 seconds
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshAll(),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _refreshAll() {
    if (!mounted) return;
    context.read<ShiftBloc>().add(const ShiftCheckRequested());
    context.read<ProfileBloc>().add(const ProfileRefreshRequested());
    context.read<BreakBloc>().add(const BreakCheckRequested());
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
                _buildWelcomeSection(context, isDark),
                SizedBox(height: Responsive.h(20)),
                _buildEarningsCard(context, isDark),
                SizedBox(height: Responsive.h(24)),
                _buildBreakSection(context, isDark),
                SizedBox(height: Responsive.h(24)),
                _buildRouteCard(context, isDark),
                SizedBox(height: Responsive.h(24)),
                _buildParkingCard(context, isDark),
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

    return Row(
      children: [
        GestureDetector(
          onTap: widget.onAvatarTap,
          child: SekkaAvatar(imageUrl: imageUrl, size: 46),
        ),
        const Spacer(),
        const SyncStatusChip(),
        SizedBox(width: Responsive.w(8)),
        _NotificationBadge(
          isDark: isDark,
          onTap: () async => _openNotifications(context),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  WELCOME SECTION — الترحيب (باللون الأساسي)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildWelcomeSection(BuildContext context, bool isDark) {
    final greeting = DateTime.now().arabicGreeting;
    final authState = context.watch<AuthBloc>().state;
    final driverName =
        authState is AuthAuthenticated ? authState.driver.name : '';
    final profileState = context.watch<ProfileBloc>().state;

    int totalOrders = 0;
    int totalDelivered = 0;
    String successRate = '0%';
    if (profileState is ProfileLoaded) {
      totalOrders = profileState.profile.totalOrders;
      totalDelivered = profileState.profile.totalDelivered;
      final rate = totalOrders > 0
          ? ((totalDelivered / totalOrders) * 100).round()
          : 0;
      successRate = '$rate%';
    }

    // Find in-transit order
    final ordersState = context.watch<OrdersBloc>().state;
    OrderModel? inTransitOrder;
    if (ordersState is OrdersLoaded) {
      final transitOrders = ordersState.orders
          .where((o) => o.status == OrderStatus.inTransit)
          .toList();
      if (transitOrders.isNotEmpty) {
        inTransitOrder = transitOrders.first;
      }
    }

    final today = DateTime.now().arabicDate;

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
            // Greeting + name
            Text(
              '$greeting، $driverName',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: Responsive.h(4)),

            // Date + Location
            Row(
              children: [
                Text(
                  today,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(width: Responsive.w(12)),
                const _LocationChip(),
              ],
            ),
            SizedBox(height: Responsive.h(20)),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WelcomeStatItem(
                  value: '$totalOrders',
                  label: AppStrings.statOrders,
                ),
                _WelcomeStatItem(
                  value: '$totalDelivered',
                  label: AppStrings.statDelivered,
                ),
                _WelcomeStatItem(
                  value: successRate,
                  label: AppStrings.statSuccess,
                ),
              ],
            ),

            SizedBox(height: Responsive.h(16)),

            // Shift toggle button
            _buildShiftToggle(context),

            // Divider + in-transit order (if exists)
            if (inTransitOrder != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
                child: Divider(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                  height: 1,
                ),
              ),
              _buildInTransitOrder(context, inTransitOrder),
            ],
          ],
        ),
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
        // Listen for shift toggle success
        if (prev is ShiftLoaded && curr is ShiftLoaded) {
          return prev.isActive != curr.isActive;
        }
        // Listen for errors
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
        final isActive =
            state is ShiftLoaded && state.isActive;
        final isToggling =
            state is ShiftLoaded && state.isToggling;
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
            padding: EdgeInsets.symmetric(
              vertical: Responsive.h(12),
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.textOnPrimary
                  : AppColors.textOnPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Responsive.r(12)),
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
                          ? AppColors.primary
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
                        ? AppColors.primary
                        : AppColors.textOnPrimary,
                  ),
                SizedBox(width: Responsive.w(8)),
                Text(
                  isActive
                      ? AppStrings.shiftEnd
                      : AppStrings.shiftStart,
                  style: AppTypography.titleMedium.copyWith(
                    color: isActive
                        ? AppColors.primary
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
        ],
      ),
    );
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
            'assets/images/route_optimize.png',
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
            'assets/images/parking_spot.png',
            height: Responsive.h(100),
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  WELCOME STAT ITEM — إحصائية في سيكشن الترحيب
// ══════════════════════════════════════════════════════════════════════════

class _WelcomeStatItem extends StatelessWidget {
  const _WelcomeStatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            color: AppColors.textOnPrimary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

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
//  LOCATION CHIP — الموقع الحالي
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
