import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_state.dart';
import '../../../orders/presentation/screens/order_detail_screen.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../routes/presentation/screens/route_screen.dart';
import '../../../breaks/presentation/bloc/break_bloc.dart';
import '../../../breaks/presentation/widgets/active_break_card.dart';
import '../../../breaks/presentation/widgets/break_suggestion_card.dart';
import '../../../sync/presentation/widgets/sync_status_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onAvatarTap});

  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.h(16)),
              _buildAppBar(context, isDark),
              SizedBox(height: Responsive.h(20)),
              _buildWelcomeSection(context, isDark),
              SizedBox(height: Responsive.h(24)),
              _buildDailyStats(isDark),
              SizedBox(height: Responsive.h(20)),
              _buildBreakSection(context, isDark),
              SizedBox(height: Responsive.h(20)),
              _buildRouteOptimizeButton(context, isDark),
              SizedBox(height: Responsive.h(28)),
              _buildUpcomingOrders(isDark),
              SizedBox(height: Responsive.h(24)),
              _buildRouteCard(context, isDark),
              SizedBox(height: Responsive.h(24)),
              _buildParkingCard(context, isDark),
              SizedBox(height: Responsive.h(120)),
            ],
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
        builder: (_) => NotificationsScreen(
          repository: NotificationRepository(dio),
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
          onTap: onAvatarTap,
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

            // Date
            Text(
              today,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnPrimary.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: Responsive.h(20)),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WelcomeStatItem(
                  value: '$totalOrders',
                  label: 'طلبات',
                ),
                _WelcomeStatItem(
                  value: '$totalDelivered',
                  label: 'تسليم',
                ),
                _WelcomeStatItem(
                  value: successRate,
                  label: 'نجاح',
                ),
              ],
            ),

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

  // ── Break Section ──

  Widget _buildBreakSection(BuildContext context, bool isDark) {
    return BlocConsumer<BreakBloc, BreakState>(
      listener: (context, state) {
        if (state is BreakStarted || state is BreakEnded) {
          context.read<BreakBloc>().add(const BreakCheckRequested());
        }
      },
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
                'حسّن مسارك',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.h(4)),
              Text(
                'رتّب طلباتك ووفّر وقت ومسافة',
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
                        builder: (_) => const RouteScreen()),
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
                      'دخّل مسارك',
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
        // Image inside card, peeking out from top
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
                        builder: (_) => const RouteScreen()),
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
        // Image inside card, peeking out from top
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
