import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../notifications/data/repositories/notification_repository.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../sos/data/repositories/sos_repository.dart';
import '../../../sos/presentation/screens/sos_screen.dart';
import '../bloc/daily_stats_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onAvatarTap});

  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greeting = DateTime.now().arabicGreeting;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.h(20)),
              _buildHeader(context, greeting, isDark),
              SizedBox(height: Responsive.h(28)),
              _buildCurrentOrderCard(isDark),
              SizedBox(height: Responsive.h(24)),
              _buildDailyStats(isDark),
              SizedBox(height: Responsive.h(28)),
              _buildUpcomingOrders(isDark),
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

  void _openSos(BuildContext context) {
    final dio = context.read<DioClient>().dio;
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SosScreen(
          repository: SosRepository(dio),
        ),
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader(BuildContext context, String greeting, bool isDark) {
    final authState = context.watch<AuthBloc>().state;
    final driverName = authState is AuthAuthenticated
        ? authState.driver.name
        : '';
    return Row(
      children: [
        // Avatar
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: Responsive.r(50),
            height: Responsive.r(50),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconsaxPlusBold.profile_circle,
              color: AppColors.textOnPrimary,
              size: Responsive.r(26),
            ),
          ),
        ),
        SizedBox(width: Responsive.w(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textCaption,
                ),
              ),
              SizedBox(height: Responsive.h(2)),
              Text(
                driverName,
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
            ],
          ),
        ),
        // SOS
        GestureDetector(
          onTap: () => _openSos(context),
          child: Icon(
            IconsaxPlusLinear.danger,
            color: AppColors.error,
            size: Responsive.r(26),
          ),
        ),
        SizedBox(width: Responsive.w(18)),
        // Notifications
        _NotificationBadge(
          isDark: isDark,
          onTap: () async => _openNotifications(context),
        ),
      ],
    );
  }



  // ── Current Order Card ──

  Widget _buildCurrentOrderCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
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
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(10),
                    vertical: Responsive.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconsaxPlusBold.truck_fast,
                        color: AppColors.textOnPrimary,
                        size: Responsive.r(16),
                      ),
                      SizedBox(width: Responsive.w(6)),
                      Text(
                        'الطلب الحالي',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '#1042',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.h(20)),

            // Client info
            Row(
              children: [
                Container(
                  width: Responsive.r(48),
                  height: Responsive.r(48),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconsaxPlusBold.profile_circle,
                    color: AppColors.textOnPrimary,
                    size: Responsive.r(24),
                  ),
                ),
                SizedBox(width: Responsive.w(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أحمد محمد',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.h(4)),
                      Row(
                        children: [
                          Icon(
                            IconsaxPlusBold.location,
                            size: Responsive.r(14),
                            color: AppColors.textOnPrimary
                                .withValues(alpha: 0.7),
                          ),
                          SizedBox(width: Responsive.w(4)),
                          Flexible(
                            child: Text(
                              '15 شارع النصر، المعادي',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textOnPrimary
                                    .withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.h(20)),

            // Info chips
            Container(
              padding: EdgeInsets.symmetric(
                vertical: Responsive.h(12),
                horizontal: Responsive.w(4),
              ),
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Responsive.r(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOrderChip(IconsaxPlusBold.routing_2, '2.1 كم'),
                  _chipDivider(),
                  _buildOrderChip(IconsaxPlusLinear.clock, '12 دقيقة'),
                  _chipDivider(),
                  _buildOrderChip(IconsaxPlusBold.money_recive, '150 ج'),
                ],
              ),
            ),

            SizedBox(height: Responsive.h(20)),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    icon: IconsaxPlusBold.send_2,
                    label: 'ابدأ الرحلة',
                    filled: true,
                  ),
                ),
                SizedBox(width: Responsive.w(12)),
                _buildSmallAction(IconsaxPlusBold.call),
                SizedBox(width: Responsive.w(8)),
                _buildSmallAction(IconsaxPlusBold.message),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: Responsive.r(16), color: AppColors.textOnPrimary),
        SizedBox(width: Responsive.w(6)),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

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

  // ── Daily Stats ──

  Widget _buildDailyStats(bool isDark) {
    return BlocBuilder<DailyStatsBloc, DailyStatsState>(
      builder: (context, state) {
        final String orders;
        final String earnings;
        final String distance;

        if (state is DailyStatsLoaded) {
          orders = state.stats.totalOrders.toString();
          earnings = state.stats.earnings.toInt().toString();
          distance = state.stats.distanceKm.toStringAsFixed(0);
        } else {
          orders = '--';
          earnings = '--';
          distance = '--';
        }

        return Column(
          children: [
            GestureDetector(
              onTap: () => context.push(RouteNames.detailedStats),
              child: Row(
                children: [
                  _buildStatCard(
                    value: orders,
                    label: AppStrings.orders,
                    isDark: isDark,
                  ),
                  SizedBox(width: Responsive.w(12)),
                  _buildStatCard(
                    value: earnings,
                    label: AppStrings.currency,
                    isDark: isDark,
                  ),
                  SizedBox(width: Responsive.w(12)),
                  _buildStatCard(
                    value: distance,
                    label: AppStrings.km,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            if (state is DailyStatsLoading)
              Padding(
                padding: EdgeInsets.only(top: Responsive.h(8)),
                child: const LinearProgressIndicator(
                  color: AppColors.primary,
                  minHeight: 2,
                ),
              ),
            if (state is DailyStatsError)
              Padding(
                padding: EdgeInsets.only(top: Responsive.h(8)),
                child: GestureDetector(
                  onTap: () => context
                      .read<DailyStatsBloc>()
                      .add(const DailyStatsLoadRequested()),
                  child: Text(
                    AppStrings.retry,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
          vertical: Responsive.h(18),
          horizontal: Responsive.w(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: Responsive.h(4)),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Upcoming Orders ──

  Widget _buildUpcomingOrders(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'الطلبات القادمة',
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Text(
                'عرض الكل',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.h(14)),
        _buildUpcomingOrderItem(
          name: 'سارة علي',
          address: 'الدقي',
          distance: '0.5 كم',
          amount: '200 ج',
          partner: 'مطعم البرنس',
          isDark: isDark,
        ),
        SizedBox(height: Responsive.h(10)),
        _buildUpcomingOrderItem(
          name: 'محمد كريم',
          address: 'المهندسين',
          distance: '3 كم',
          amount: '80 ج',
          partner: 'أرامكس',
          isDark: isDark,
        ),
        SizedBox(height: Responsive.h(10)),
        _buildUpcomingOrderItem(
          name: 'فاطمة أحمد',
          address: '6 أكتوبر',
          distance: '8 كم',
          amount: '350 ج',
          partner: 'حر',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildUpcomingOrderItem({
    required String name,
    required String address,
    required String distance,
    required String amount,
    required String partner,
    required bool isDark,
  }) {
    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Row(
        children: [
          // Avatar with initials
          Container(
            width: Responsive.r(46),
            height: Responsive.r(46),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Responsive.r(14)),
            ),
            child: Center(
              child: Text(
                name.characters.first,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.w(14)),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.h(4)),
                Row(
                  children: [
                    Icon(
                      IconsaxPlusLinear.location,
                      size: Responsive.r(14),
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                    SizedBox(width: Responsive.w(4)),
                    Text(
                      '$address • $distance',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Container(
                      width: Responsive.r(4),
                      height: Responsive.r(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Flexible(
                      child: Text(
                        partner,
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
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.h(4)),
              const StatusBadge(
                status: OrderStatus.newOrder,
                compact: true,
              ),
            ],
          ),
        ],
      ),
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
    // Refresh count when returning from notifications screen
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
            color: widget.isDark ? AppColors.textBodyDark : AppColors.textBody,
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
