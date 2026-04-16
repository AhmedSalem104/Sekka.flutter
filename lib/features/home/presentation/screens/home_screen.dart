import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_avatar.dart';
import '../../../../shared/enums/order_enums.dart';
import '../../../breaks/presentation/bloc/break_bloc.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_event.dart';
import '../../../orders/presentation/bloc/orders_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../routes/presentation/bloc/route_bloc.dart';
import '../../../routes/presentation/bloc/route_event.dart';
import '../../../routes/presentation/bloc/route_state.dart';
import '../../../routes/presentation/screens/navigation_screen.dart';
import '../../../shifts/presentation/bloc/shift_bloc.dart';
import '../../../shifts/presentation/bloc/shift_event.dart';
import '../../../shifts/presentation/bloc/shift_state.dart';

/// Driver home — minimal monochrome layout focused on the next action.
///
/// Visual rules (single source of truth, no exceptions):
///   • Surfaces are white/dark-surface; no decorative color fills.
///   • Primary orange is reserved for THE primary CTA per screen state.
///   • Status colors (success/error) only appear when semantically required.
///   • Hierarchy is built with typography + spacing, not boxes/colors.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onAvatarTap});

  final VoidCallback? onAvatarTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fireAll();
    });
  }

  void _fireAll() {
    context.read<ShiftBloc>().add(const ShiftCheckRequested());
    context.read<ProfileBloc>().add(const ProfileRefreshRequested());
    context.read<BreakBloc>().add(const BreakCheckRequested());
    context
        .read<OrdersBloc>()
        .add(const OrdersLoadRequested(refresh: true));
    context.read<RouteBloc>().add(const RouteActiveLoadRequested());
  }

  Future<void> _refresh() async {
    _fireAll();
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.lg,
              AppSizes.pagePadding,
              Responsive.h(120), // clears bottom nav (60 + safe area + spacing)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Greeting(onTap: widget.onAvatarTap),
                SizedBox(height: AppSizes.xl),
                const _Hero(),
                SizedBox(height: AppSizes.xl),
                const _QuickActions(),
                SizedBox(height: AppSizes.xl),
                const _ConditionalSections(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Greeting (top of screen) ──
// ════════════════════════════════════════════════════════════════════════

class _Greeting extends StatelessWidget {
  const _Greeting({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (a, b) => a.runtimeType != b.runtimeType,
          builder: (context, state) {
            final imageUrl =
                state is ProfileLoaded ? state.profile.profileImageUrl : null;
            return SekkaAvatar(
              imageUrl: imageUrl,
              size: 44,
              onTap: onTap,
            );
          },
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.xs),
              child: BlocBuilder<ProfileBloc, ProfileState>(
                buildWhen: (a, b) => a.runtimeType != b.runtimeType,
                builder: (context, state) {
                  final name =
                      state is ProfileLoaded ? state.profile.name : '';
                  return RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${AppStrings.welcomeBack} ',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textCaption,
                          ),
                        ),
                        TextSpan(
                          text:
                              name.isEmpty ? '...' : name.split(' ').first,
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark
                                ? AppColors.textHeadlineDark
                                : AppColors.textHeadline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        _IconChip(
          icon: IconsaxPlusLinear.notification,
          onTap: () => context.push(RouteNames.notifications),
        ),
      ],
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.chipRadius),
      child: Container(
        width: Responsive.r(40),
        height: Responsive.r(40),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          size: AppSizes.iconMd,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Hero (3 states) ──
// ════════════════════════════════════════════════════════════════════════

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShiftBloc, ShiftState>(
      builder: (context, shiftState) {
        if (shiftState is! ShiftLoaded || !shiftState.isActive) {
          return const _HeroNoShift();
        }
        return BlocBuilder<RouteBloc, RouteState>(
          builder: (context, routeState) {
            return BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, ordersState) {
                final next = _firstActiveOrder(ordersState, routeState);
                if (next == null) {
                  return _HeroIdle(shift: shiftState);
                }
                return _HeroOrder(order: next, shift: shiftState);
              },
            );
          },
        );
      },
    );
  }

  /// Pick the next order the driver should focus on.
  ///
  /// Priority (highest → lowest):
  ///   1. Active route's first stop (driver's chosen sequence wins)
  ///   2. Oldest in-transit / picked-up / arrived order
  ///   3. Oldest pending / accepted order
  ///
  /// Returns the full `OrderModel` from `OrdersBloc` (so it has lat/lng)
  /// even when the source was the route — because `/routes/active` DTO
  /// doesn't include coordinates (documented backend gap).
  static OrderModel? _firstActiveOrder(
    OrdersState ordersState,
    RouteState routeState,
  ) {
    if (ordersState is! OrdersLoaded) return null;

    // 1) Active route first stop
    final routeOrderId = _activeRouteFirstId(routeState);
    if (routeOrderId != null) {
      final match = ordersState.orders
          .where((o) => o.id == routeOrderId && _isActive(o.status))
          .firstOrNull;
      if (match != null) return match;
    }

    // 2) Oldest in-transit
    final inTransit = ordersState.orders
        .where((o) =>
            o.status == OrderStatus.inTransit ||
            o.status == OrderStatus.arrivedAtDestination ||
            o.status == OrderStatus.pickedUp)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (inTransit.isNotEmpty) return inTransit.first;

    // 3) Oldest pending
    final pending = ordersState.orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.accepted)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return pending.isEmpty ? null : pending.first;
  }

  static String? _activeRouteFirstId(RouteState s) {
    if (s is! RouteLoaded) return null;
    final route = s.activeRoute;
    if (route == null || !route.isActive || route.orders.isEmpty) return null;
    return route.orders.first.orderId;
  }

  static bool _isActive(OrderStatus status) =>
      status == OrderStatus.pending ||
      status == OrderStatus.accepted ||
      status == OrderStatus.inTransit ||
      status == OrderStatus.arrivedAtDestination ||
      status == OrderStatus.pickedUp;
}

// ── State A: No shift ──
class _HeroNoShift extends StatelessWidget {
  const _HeroNoShift();

  @override
  Widget build(BuildContext context) {
    return _HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusBold.flag,
                color: AppColors.textOnPrimary,
                size: AppSizes.iconXl,
              ),
            ),
          ),
          SizedBox(height: AppSizes.md),
          Text(
            AppStrings.homeReadyToStart,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.lg),
          BlocBuilder<ShiftBloc, ShiftState>(
            buildWhen: (a, b) =>
                a is! ShiftLoaded ||
                b is! ShiftLoaded ||
                a.isToggling != b.isToggling,
            builder: (context, state) {
              final isLoading =
                  state is ShiftLoaded && state.isToggling;
              return _HeroPrimaryButton(
                label: AppStrings.shiftStart,
                icon: IconsaxPlusBold.play,
                isLoading: isLoading,
                onTap: () => context
                    .read<ShiftBloc>()
                    .add(const ShiftStartRequested()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── State B: Shift on, no orders ──
class _HeroIdle extends StatelessWidget {
  const _HeroIdle({required this.shift});
  final ShiftLoaded shift;

  @override
  Widget build(BuildContext context) {
    final s = shift.currentShift;
    final orders = s?.ordersCompleted ?? 0;
    final earnings = s?.earningsTotal ?? 0;

    return _HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShiftStatusRow(shift: shift),
          SizedBox(height: AppSizes.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _HeroMetric(
                  icon: IconsaxPlusBold.dollar_circle,
                  label: AppStrings.homeShiftEarnings,
                  value: earnings.toStringAsFixed(0),
                  unit: AppStrings.currency,
                ),
              ),
              Container(
                width: 1,
                height: Responsive.h(48),
                color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _HeroMetric(
                  icon: IconsaxPlusBold.box,
                  label: AppStrings.homeShiftOrders,
                  value: '$orders',
                  unit: AppStrings.homeOrdersUnit,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),
          _HeroCashRow(),
          SizedBox(height: AppSizes.lg),
          _HeroPrimaryButton(
            label: AppStrings.homeAddOrderCta,
            icon: IconsaxPlusBold.add_circle,
            onTap: () => context.push(RouteNames.addOrder),
          ),
        ],
      ),
    );
  }
}

// ── State C: Has an active order ──
class _HeroOrder extends StatelessWidget {
  const _HeroOrder({required this.order, required this.shift});
  final OrderModel order;
  final ShiftLoaded shift;

  bool get _isInTransit =>
      order.status == OrderStatus.inTransit ||
      order.status == OrderStatus.arrivedAtDestination ||
      order.status == OrderStatus.pickedUp;

  @override
  Widget build(BuildContext context) {
    final whiteSoft = AppColors.textOnPrimary.withValues(alpha: 0.85);
    return _HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShiftStatusRow(shift: shift),
          SizedBox(height: AppSizes.lg),
          // Status label with icon
          Row(
            children: [
              Icon(
                _isInTransit
                    ? IconsaxPlusBold.truck_fast
                    : IconsaxPlusBold.box_1,
                color: whiteSoft,
                size: AppSizes.iconSm,
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                _isInTransit
                    ? AppStrings.homeDeliveringNow
                    : AppStrings.homeNextOrder,
                style: AppTypography.bodyMedium.copyWith(
                  color: whiteSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.xs),
          // Customer name
          Text(
            order.customerName?.isNotEmpty == true
                ? order.customerName!
                : AppStrings.homeOrderNoCustomer,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: Responsive.h(2)),
                child: Icon(
                  IconsaxPlusBold.location,
                  size: Responsive.r(14),
                  color: whiteSoft,
                ),
              ),
              SizedBox(width: Responsive.w(6)),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: AppTypography.captionSmall.copyWith(
                    color: whiteSoft,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          // Amount with icon
          Row(
            children: [
              Icon(
                IconsaxPlusBold.money_recive,
                size: AppSizes.iconSm,
                color: AppColors.textOnPrimary,
              ),
              SizedBox(width: Responsive.w(6)),
              Text(
                '${order.amount.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.lg),
          // Actions — side by side when in-transit, single big otherwise
          if (_isInTransit)
            Row(
              children: [
                Expanded(
                  child: _HeroPrimaryButton(
                    label: AppStrings.homeFollowOnMap,
                    onTap: () => _openMap(context),
                    compact: true,
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _HeroSecondaryButton(
                    label: AppStrings.homeOpenForDelivery,
                    onTap: () => _openDetail(context),
                  ),
                ),
              ],
            )
          else
            _HeroPrimaryButton(
              label: AppStrings.startDelivery,
              icon: IconsaxPlusBold.play,
              onTap: () => _openDetail(context),
            ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    context.push(RouteNames.orderDetails, extra: order.id);
  }

  Future<void> _openMap(BuildContext context) async {
    final lat = order.deliveryLatitude;
    final lng = order.deliveryLongitude;
    final query = (lat != null && lng != null && lat != 0 && lng != 0)
        ? '$lat,$lng'
        : Uri.encodeComponent(order.deliveryAddress);
    final navIntent = Uri.parse('google.navigation:q=$query&mode=d');
    final fallback = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$query'
      '&travelmode=driving&dir_action=navigate',
    );
    try {
      final ok =
          await launchUrl(navIntent, mode: LaunchMode.externalApplication);
      if (!ok) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Hero subcomponents ──

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(Responsive.r(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ShiftStatusRow extends StatelessWidget {
  const _ShiftStatusRow({required this.shift});
  final ShiftLoaded shift;

  @override
  Widget build(BuildContext context) {
    final start = shift.currentShift?.startTime;
    final duration = start == null ? null : DateTime.now().difference(start);
    final whiteSoft = AppColors.textOnPrimary.withValues(alpha: 0.85);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: Responsive.h(4),
          ),
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppSizes.chipRadius),
          ),
          child: Row(
            children: [
              Container(
                width: Responsive.r(8),
                height: Responsive.r(8),
                decoration: const BoxDecoration(
                  color: AppColors.textOnPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                AppStrings.shiftActive,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (duration != null) ...[
                SizedBox(width: AppSizes.xs),
                Text(
                  '• ${_formatDuration(duration)}',
                  style: AppTypography.bodySmall.copyWith(color: whiteSoft),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        Material(
          color: AppColors.textOnPrimary.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppSizes.chipRadius),
          child: InkWell(
            onTap: () => _confirmEnd(context),
            borderRadius: BorderRadius.circular(AppSizes.chipRadius),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: Responsive.h(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconsaxPlusBold.logout,
                    color: AppColors.textOnPrimary,
                    size: Responsive.r(12),
                  ),
                  SizedBox(width: Responsive.w(4)),
                  Text(
                    AppStrings.shiftEnd,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '$h ${AppStrings.homeHour} ${m > 0 ? '$m د' : ''}';
    return '$m ${AppStrings.homeMinutes}';
  }

  Future<void> _confirmEnd(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          title: Text(AppStrings.shiftEnd),
          content: Text(AppStrings.shiftEndConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                AppStrings.shiftEnd,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
    if (yes == true && context.mounted) {
      context.read<ShiftBloc>().add(const ShiftEndRequested());
    }
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final whiteSoft = AppColors.textOnPrimary.withValues(alpha: 0.85);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: whiteSoft, size: AppSizes.iconSm),
        SizedBox(height: Responsive.h(4)),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: whiteSoft),
        ),
        SizedBox(height: AppSizes.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: Responsive.w(4)),
            Text(
              unit,
              style: AppTypography.bodySmall.copyWith(color: whiteSoft),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCashRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final whiteSoft = AppColors.textOnPrimary.withValues(alpha: 0.85);
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final cash =
            state is ProfileLoaded ? state.profile.cashOnHand : 0.0;
        return Container(
          padding: EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Row(
            children: [
              Icon(
                IconsaxPlusBold.wallet_3,
                color: AppColors.textOnPrimary,
                size: AppSizes.iconMd,
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.homeCashLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppStrings.homeCashHint,
                      style: AppTypography.captionSmall.copyWith(
                        color: whiteSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${cash.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroPrimaryButton extends StatelessWidget {
  const _HeroPrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isLoading;

  /// Smaller height + tighter padding for side-by-side layouts.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final h = compact ? Responsive.h(44) : AppSizes.buttonHeight;
    return Material(
      color: AppColors.textOnPrimary,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: Responsive.r(18),
                  height: Responsive.r(18),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: AppColors.primary,
                        size: compact ? Responsive.r(16) : AppSizes.iconMd,
                      ),
                      SizedBox(width: Responsive.w(6)),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: (compact
                                ? AppTypography.bodySmall
                                : AppTypography.button)
                            .copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeroSecondaryButton extends StatelessWidget {
  const _HeroSecondaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          height: Responsive.h(44),
          padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.textOnPrimary.withValues(alpha: 0.6),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Quick Actions (monochrome chips) ──
// ════════════════════════════════════════════════════════════════════════

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: IconsaxPlusLinear.add_circle,
            label: AppStrings.homeQuickAddOrder,
            onTap: () => context.push(RouteNames.addOrder),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: _QuickAction(
            icon: IconsaxPlusLinear.money_send,
            label: AppStrings.homeQuickSettle,
            onTap: () => context.push(RouteNames.createSettlement),
          ),
        ),
        SizedBox(width: AppSizes.sm),
        const Expanded(child: _BreakAction()),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: _QuickAction(
            icon: IconsaxPlusLinear.chart_2,
            label: AppStrings.homeQuickToday,
            onTap: () => context.push(RouteNames.detailedStats),
          ),
        ),
      ],
    );
  }
}

class _BreakAction extends StatelessWidget {
  const _BreakAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreakBloc, BreakState>(
      builder: (context, state) {
        final isOnBreak =
            state is BreakCheckLoaded && state.activeBreak != null;
        return _QuickAction(
          icon: isOnBreak ? IconsaxPlusLinear.play : IconsaxPlusLinear.coffee,
          label: AppStrings.homeQuickBreak,
          onTap: () {
            if (isOnBreak) {
              context
                  .read<BreakBloc>()
                  .add(const BreakEndRequested(energyAfter: 3));
            } else {
              context.read<BreakBloc>().add(
                    const BreakStartRequested(
                      energyBefore: 3,
                      locationDescription: '',
                    ),
                  );
            }
          },
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? AppColors.textBodyDark : AppColors.textBody;
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        splashColor: AppColors.primary.withValues(alpha: 0.15),
        highlightColor: AppColors.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.md,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Conditional: Pending list / Route hint / Cash warning ──
// ════════════════════════════════════════════════════════════════════════

class _ConditionalSections extends StatelessWidget {
  const _ConditionalSections();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, routeState) {
        return BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, ordersState) {
            final pending = _allPendingExceptHero(ordersState, routeState);
            final totalActive = _countActive(ordersState);
            final hasActiveRoute = _hasActiveRoute(routeState);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pending.isNotEmpty) _PendingList(orders: pending),
                // Route hint: show from 2+ active orders (or always when a
                // route is already active — so the driver can open/adjust it).
                if (totalActive >= 2 || hasActiveRoute) ...[
                  if (pending.isNotEmpty) SizedBox(height: AppSizes.md),
                  _RouteHint(isActive: hasActiveRoute),
                ],
                const _CashOrEmpty(),
              ],
            );
          },
        );
      },
    );
  }

  /// All pending/in-transit orders EXCEPT the one in the hero.
  ///
  /// Order:
  ///   • If a route is active → follow the route sequence (skip the first
  ///     stop since that's the hero).
  ///   • Else → by created date ascending, excluding the hero by id.
  static List<OrderModel> _allPendingExceptHero(
    OrdersState ordersState,
    RouteState routeState,
  ) {
    if (ordersState is! OrdersLoaded) return const [];
    final hero = _Hero._firstActiveOrder(ordersState, routeState);

    // Route-aware ordering
    if (routeState is RouteLoaded &&
        routeState.activeRoute?.isActive == true &&
        routeState.activeRoute!.orders.isNotEmpty) {
      final routeIds = routeState.activeRoute!.orders
          .skip(1) // first stop is in the hero
          .map((r) => r.orderId)
          .toList();
      final byId = {for (final o in ordersState.orders) o.id: o};
      final ordered = <OrderModel>[];
      for (final id in routeIds) {
        final o = byId[id];
        if (o != null && _Hero._isActive(o.status)) ordered.add(o);
      }
      return ordered;
    }

    // Fallback: all active except hero, oldest first
    return ordersState.orders
        .where((o) => _Hero._isActive(o.status) && o.id != hero?.id)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  static int _countActive(OrdersState state) {
    if (state is! OrdersLoaded) return 0;
    return state.orders.where((o) => _Hero._isActive(o.status)).length;
  }

  static bool _hasActiveRoute(RouteState state) =>
      state is RouteLoaded && (state.activeRoute?.isActive ?? false);
}

class _PendingList extends StatelessWidget {
  const _PendingList({required this.orders});
  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preview = orders.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
          child: Row(
            children: [
              Text(
                AppStrings.homePendingOrders,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                '(${orders.length})',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textCaption,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => DefaultTabController.maybeOf(context)
                    ?.animateTo(1), // Orders tab — fallback handled by shell
                borderRadius: BorderRadius.circular(AppSizes.chipRadius),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.xs,
                    vertical: Responsive.h(2),
                  ),
                  child: Row(
                    children: [
                      Text(
                        AppStrings.homeViewAll,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: Responsive.w(2)),
                      Icon(
                        IconsaxPlusLinear.arrow_left_2,
                        size: Responsive.r(14),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.sm),
        for (final o in preview) ...[
          _PendingRow(order: o, isDark: isDark),
          SizedBox(height: AppSizes.xs),
        ],
      ],
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({required this.order, required this.isDark});
  final OrderModel order;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: () => context.push(RouteNames.orderDetails, extra: order.id),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusBold.box,
                  size: Responsive.r(16),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName?.isNotEmpty == true
                          ? order.customerName!
                          : order.deliveryAddress,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      order.deliveryAddress,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textCaption,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Text(
                '${order.amount.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteHint extends StatelessWidget {
  const _RouteHint({this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const NavigationScreen(initialTab: 0),
          ),
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              SizedBox(
                width: Responsive.r(56),
                height: Responsive.r(56),
                child: Image.asset(
                  isDark
                      ? 'assets/images/route_optimize_dark.png'
                      : 'assets/images/route_optimize.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive
                          ? AppStrings.homeRouteActiveTitle
                          : AppStrings.homeRouteHintTitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      isActive
                          ? AppStrings.homeRouteActiveSubtitle
                          : AppStrings.homeRouteHintSubtitle,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                IconsaxPlusLinear.arrow_left_2,
                size: AppSizes.iconSm,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashOrEmpty extends StatelessWidget {
  const _CashOrEmpty();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) return const SizedBox.shrink();
        final cash = state.profile.cashOnHand;
        if (cash < 2000) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: AppSizes.md),
          child: _CashWarning(amount: cash),
        );
      },
    );
  }
}

class _CashWarning extends StatelessWidget {
  const _CashWarning({required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: () => context.push(RouteNames.createSettlement),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        splashColor: AppColors.primary.withValues(alpha: 0.18),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusBold.wallet_money,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.homeCashTooMuch,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      '${amount.toStringAsFixed(0)} ${AppStrings.currency}',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                IconsaxPlusLinear.arrow_left_2,
                size: AppSizes.iconSm,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
