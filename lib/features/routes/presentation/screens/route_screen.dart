import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_map_picker.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_state.dart';
import '../../../parking/data/datasources/parking_remote_datasource.dart';
import '../../../parking/data/models/parking_model.dart';
import '../../../parking/data/repositories/parking_repository_impl.dart';
import '../../../parking/presentation/bloc/parking_bloc.dart';
import '../../../parking/presentation/bloc/parking_event.dart';
import '../../../parking/presentation/bloc/parking_state.dart';
import '../../data/datasources/route_remote_datasource.dart';
import '../../data/models/route_model.dart';
import '../../data/repositories/route_repository_impl.dart';
import '../bloc/route_bloc.dart';
import '../bloc/route_event.dart';
import '../bloc/route_state.dart';

// ══════════════════════════════════════════════════════════════════════════
//  ROUTE SCREEN — Entry point with BlocProvider
// ══════════════════════════════════════════════════════════════════════════

class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dioClient = context.read<DioClient>();
        final datasource = RouteRemoteDataSource(dioClient);
        final repo = RouteRepositoryImpl(remoteDataSource: datasource);
        return RouteBloc(repository: repo)
          ..add(const RouteActiveLoadRequested());
      },
      child: const _RouteScreenBody(),
    );
  }
}

/// Route tab content — used inside NavigationScreen TabBarView.
class RouteTabContent extends StatelessWidget {
  const RouteTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<RouteBloc, RouteState>(
      listener: _routeListener,
      builder: (context, state) => switch (state) {
        RouteInitial() || RouteLoading() => const SekkaLoading(),
        RouteLoaded(:final activeRoute, :final isActionInProgress) =>
          activeRoute != null && activeRoute.isActive
              ? _ActiveRouteView(
                  route: activeRoute,
                  isLoading: isActionInProgress,
                  isDark: isDark,
                )
              : _EmptyState(isLoading: isActionInProgress, isDark: isDark),
        RouteError(:final message) => _ErrorView(
            message: message,
            isDark: isDark,
          ),
      },
    );
  }
}

void _routeListener(BuildContext context, RouteState state) {
  if (state is RouteLoaded && state.actionMessage != null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              state.actionMessage!,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textOnPrimary),
            ),
          ),
          backgroundColor:
              state.isActionError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      );
    context.read<RouteBloc>().add(const RouteClearMessage());
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _RouteScreenBody extends StatelessWidget {
  const _RouteScreenBody();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        appBar: const SekkaAppBar(title: AppStrings.routeOptimization),
        body: BlocConsumer<RouteBloc, RouteState>(
          listener: _routeListener,
          builder: (context, state) => switch (state) {
            RouteInitial() || RouteLoading() => const SekkaLoading(),
            RouteLoaded(:final activeRoute, :final isActionInProgress) =>
              activeRoute != null && activeRoute.isActive
                  ? _ActiveRouteView(
                      route: activeRoute,
                      isLoading: isActionInProgress,
                      isDark: isDark,
                    )
                  : _EmptyState(isLoading: isActionInProgress, isDark: isDark),
            RouteError(:final message) => _ErrorView(
                message: message,
                isDark: isDark,
              ),
          },
        ),
      ),
    );
  }

}

// ══════════════════════════════════════════════════════════════════════════
//  EMPTY STATE — مفيش مسار نشط
// ══════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isLoading, required this.isDark});

  final bool isLoading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.r(28)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusBold.routing_2,
                size: Responsive.r(52),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.xxl),
            Text(
              AppStrings.noActiveRoute,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              AppStrings.noActiveRouteHint,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.xxl + AppSizes.lg),
            SekkaButton(
              label: AppStrings.enterYourRoute,
              icon: IconsaxPlusLinear.routing_2,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () => _showCreateRouteSheet(context, isDark),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ACTIVE ROUTE VIEW — المسار الحالي
// ══════════════════════════════════════════════════════════════════════════

class _ActiveRouteView extends StatelessWidget {
  const _ActiveRouteView({
    required this.route,
    required this.isLoading,
    required this.isDark,
  });

  final RouteModel route;
  final bool isLoading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats card
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding,
            vertical: AppSizes.md,
          ),
          child: _RouteStatsCard(
            route: route,
            isLoading: isLoading,
            isDark: isDark,
          ),
        ),

        // Orders header + add button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
          child: Row(
            children: [
              Text(
                '${AppStrings.selectOrders} (${route.orders.length})',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () => _showAddOrderSheet(context, route.id, isDark),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
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
                        IconsaxPlusLinear.add,
                        size: AppSizes.iconSm,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        AppStrings.addToRoute,
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
        ),

        // Hint
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding,
            vertical: AppSizes.xs,
          ),
          child: Row(
            children: [
              Icon(
                IconsaxPlusLinear.info_circle,
                size: AppSizes.iconSm,
                color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                AppStrings.dragToReorder,
                style: AppTypography.captionSmall.copyWith(
                  color:
                      isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.sm),

        // Reorderable orders list
        Expanded(
          child: route.orders.isEmpty
              ? const SekkaEmptyState(
                  icon: IconsaxPlusLinear.box,
                  title: AppStrings.routeIsEmpty,
                  description: AppStrings.addOrdersToRoute,
                )
              : ReorderableListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding,
                  ),
                  itemCount: route.orders.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final orderIds =
                        route.orders.map((o) => o.orderId).toList();
                    final item = orderIds.removeAt(oldIndex);
                    orderIds.insert(newIndex, item);
                    context.read<RouteBloc>().add(
                          RouteReorderRequested(
                            routeId: route.id,
                            orderIds: orderIds,
                          ),
                        );
                  },
                  itemBuilder: (context, index) {
                    final order = route.orders[index];
                    return _RouteOrderTile(
                      key: ValueKey(order.orderId),
                      order: order,
                      index: index,
                      total: route.orders.length,
                      isDark: isDark,
                    );
                  },
                ),
        ),

        // Bottom actions
        _BottomActions(
          route: route,
          isLoading: isLoading,
          isDark: isDark,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BOTTOM ACTIONS — إنهاء المسار
// ══════════════════════════════════════════════════════════════════════════

class _BottomActions extends StatefulWidget {
  const _BottomActions({
    required this.route,
    required this.isLoading,
    required this.isDark,
  });

  final RouteModel route;
  final bool isLoading;
  final bool isDark;

  @override
  State<_BottomActions> createState() => _BottomActionsState();
}

class _BottomActionsState extends State<_BottomActions> {
  bool _isOpeningMap = false;

  /// First order that hasn't been delivered yet (status != 4 = delivered).
  /// Returns null if all orders are done or the route is empty.
  RouteOrderModel? get _nextOrder {
    for (final order in widget.route.orders) {
      if (order.status != 4) return order;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextOrder;
    final hasNext = next != null && next.deliveryAddress.isNotEmpty;
    final label = hasNext
        ? '${AppStrings.deliverNext} — ${next.customerName ?? ''}'
        : AppStrings.allOrdersDelivered;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.md,
        AppSizes.pagePadding,
        AppSizes.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // وصّل التالي
          Expanded(
            flex: 2,
            child: SekkaButton(
              label: label,
              icon: IconsaxPlusLinear.routing,
              type: SekkaButtonType.secondary,
              isLoading: _isOpeningMap,
              onPressed: _isOpeningMap || !hasNext
                  ? null
                  : () => _navigateToOrder(next),
            ),
          ),
          SizedBox(width: AppSizes.sm),
          // إنهاء المسار
          Expanded(
            child: SekkaButton(
              label: AppStrings.completeRoute,
              isLoading: widget.isLoading,
              onPressed: widget.isLoading
                  ? null
                  : () => _confirmComplete(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Open Google Maps in turn-by-turn navigation mode for a single
  /// destination. Uses the `google.navigation:` Android intent which
  /// triggers actual navigation (not preview). Falls back to a https
  /// URL if the intent isn't handled.
  Future<void> _navigateToOrder(RouteOrderModel order) async {
    if (order.deliveryAddress.isEmpty) {
      _showError(AppStrings.noCoordinatesAvailable);
      return;
    }

    setState(() => _isOpeningMap = true);

    final query = Uri.encodeComponent(order.deliveryAddress);
    final navIntent = Uri.parse('google.navigation:q=$query&mode=d');
    final fallbackUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$query'
      '&travelmode=driving'
      '&dir_action=navigate',
    );

    var launched = false;
    try {
      launched = await launchUrl(
        navIntent,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }

    if (!launched) {
      try {
        launched = await launchUrl(
          fallbackUrl,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        launched = false;
      }
    }

    if (!mounted) return;
    setState(() => _isOpeningMap = false);

    if (!launched) {
      _showError(AppStrings.couldNotOpenNavigation);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              message,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textOnPrimary),
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      );
  }

  void _confirmComplete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor:
              widget.isDark ? AppColors.surfaceDark : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          title: Text(
            AppStrings.completeRoute,
            style: AppTypography.headlineSmall.copyWith(
              color: widget.isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          content: Text(
            AppStrings.confirmCompleteRoute,
            style: AppTypography.bodyMedium.copyWith(
              color: widget.isDark
                  ? AppColors.textBodyDark
                  : AppColors.textBody,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.cancel,
                style: AppTypography.titleMedium.copyWith(
                  color: widget.isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<RouteBloc>().add(
                      RouteCompleteRequested(routeId: widget.route.id),
                    );
              },
              child: Text(
                AppStrings.confirm,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  STATS CARD — إحصائيات المسار
// ══════════════════════════════════════════════════════════════════════════

class _RouteStatsCard extends StatelessWidget {
  const _RouteStatsCard({
    required this.route,
    required this.isLoading,
    required this.isDark,
  });

  final RouteModel route;
  final bool isLoading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      child: Column(
        children: [
          // Header + re-optimize button
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.routeStats,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  onTap: isLoading || route.orders.isEmpty
                      ? null
                      : () => _reOptimize(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          SizedBox(
                            width: AppSizes.iconSm,
                            height: AppSizes.iconSm,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        else
                          Icon(
                            IconsaxPlusLinear.magic_star,
                            size: AppSizes.iconMd,
                            color: AppColors.textOnPrimary,
                          ),
                        SizedBox(width: AppSizes.xs),
                        Text(
                          AppStrings.reOptimize,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          // Stats row
          Row(
            children: [
              _StatItem(
                icon: IconsaxPlusLinear.timer_1,
                label: AppStrings.estimatedTime,
                value: '${route.estimatedTimeMinutes} د',
                isDark: isDark,
              ),
              _divider(),
              _StatItem(
                icon: IconsaxPlusLinear.routing_2,
                label: AppStrings.totalRouteDistance,
                value:
                    '${route.totalDistanceKm.toStringAsFixed(1)} ${AppStrings.km}',
                isDark: isDark,
              ),
              if (route.efficiencyScore != null) ...[
                _divider(),
                _StatItem(
                  icon: IconsaxPlusLinear.medal_star,
                  label: AppStrings.efficiencyScore,
                  value: '${route.efficiencyScore}%',
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _reOptimize(BuildContext context) async {
    // Get current location for start point
    double? lat;
    double? lng;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      lat = position.latitude;
      lng = position.longitude;
    } catch (_) {
      // GPS unavailable
    }

    if (!context.mounted) return;
    context.read<RouteBloc>().add(
          RouteOptimizeRequested(
            orderIds: route.orders.map((o) => o.orderId).toList(),
            startLatitude: lat,
            startLongitude: lng,
          ),
        );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: Responsive.h(40),
      margin: EdgeInsets.symmetric(horizontal: AppSizes.sm),
      color: isDark ? AppColors.borderDark : AppColors.border,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.primary),
          SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          SizedBox(height: Responsive.h(2)),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ORDER TILE — كارت الطلب في المسار (draggable)
// ══════════════════════════════════════════════════════════════════════════

class _RouteOrderTile extends StatelessWidget {
  const _RouteOrderTile({
    super.key,
    required this.order,
    required this.index,
    required this.total,
    required this.isDark,
  });

  final RouteOrderModel order;
  final int index;
  final int total;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm),
      child: SekkaCard(
        child: Row(
          children: [
            // Sequence number
            Container(
              width: Responsive.w(34),
              height: Responsive.w(34),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.md),

            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.customerName != null)
                    Text(
                      order.customerName!,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                      ),
                    ),
                  if (order.deliveryAddress.isNotEmpty) ...[
                    SizedBox(height: Responsive.h(2)),
                    Row(
                      children: [
                        Icon(
                          IconsaxPlusLinear.location,
                          size: AppSizes.iconSm,
                          color: isDark
                              ? AppColors.textCaptionDark
                              : AppColors.textCaption,
                        ),
                        SizedBox(width: AppSizes.xs),
                        Expanded(
                          child: Text(
                            order.deliveryAddress,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textBodyDark
                                  : AppColors.textBody,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Amount + estimated time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${order.amount.toStringAsFixed(0)} ${AppStrings.currency}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (order.estimatedArrivalMinutes != null) ...[
                  SizedBox(height: Responsive.h(2)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconsaxPlusLinear.clock,
                        size: AppSizes.iconSm,
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        '${order.estimatedArrivalMinutes} د',
                        style: AppTypography.captionSmall.copyWith(
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
            SizedBox(width: AppSizes.sm),

            // Per-stop navigate button
            if (order.deliveryAddress.isNotEmpty)
              Material(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _navigateToStop(order),
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.sm),
                    child: Icon(
                      IconsaxPlusLinear.routing,
                      size: AppSizes.iconSm,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            SizedBox(width: AppSizes.xs),

            // Drag handle
            Icon(
              IconsaxPlusLinear.menu,
              size: AppSizes.iconSm,
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToStop(RouteOrderModel o) async {
    final query = Uri.encodeComponent(o.deliveryAddress);
    final navIntent = Uri.parse('google.navigation:q=$query&mode=d');
    final fallbackUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$query'
      '&travelmode=driving'
      '&dir_action=navigate',
    );
    try {
      final ok = await launchUrl(
        navIntent,
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        await launchUrl(
          fallbackUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {
      try {
        await launchUrl(
          fallbackUrl,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ERROR VIEW
// ══════════════════════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.isDark});

  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconsaxPlusLinear.warning_2,
              size: Responsive.r(48),
              color: AppColors.error,
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.xl),
            SekkaButton(
              label: AppStrings.retry,
              type: SekkaButtonType.secondary,
              onPressed: () => context
                  .read<RouteBloc>()
                  .add(const RouteActiveLoadRequested()),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  CREATE ROUTE SHEET — دخّل مسارك
//  Step 1: اختار طلبات (multi-select)
//  Step 2: نقطة البداية من الـ GPS
//  Step 3: نوع التحسين
//  Step 4: زرار حسّن المسار
// ══════════════════════════════════════════════════════════════════════════

const _optimizationTypes = <(String, String, IconData)>[
  ('fastest', AppStrings.fastestRoute, IconsaxPlusLinear.timer_start),
  ('shortest', AppStrings.shortestRoute, IconsaxPlusLinear.routing_2),
  ('cheapest', AppStrings.lowestCost, IconsaxPlusLinear.money_4),
];

void _showCreateRouteSheet(BuildContext context, bool isDark) {
  final bloc = context.read<RouteBloc>();
  final ordersState = context.read<OrdersBloc>().state;
  final List<OrderModel> activeOrders;

  if (ordersState is OrdersLoaded) {
    activeOrders =
        ordersState.orders.where((o) => o.status.isActive).toList();
  } else {
    activeOrders = [];
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _CreateRouteSheetBody(
        activeOrders: activeOrders,
        isDark: isDark,
      ),
    ),
  );
}

class _CreateRouteSheetBody extends StatefulWidget {
  const _CreateRouteSheetBody({
    required this.activeOrders,
    required this.isDark,
  });

  final List<OrderModel> activeOrders;
  final bool isDark;

  @override
  State<_CreateRouteSheetBody> createState() => _CreateRouteSheetBodyState();
}

class _CreateRouteSheetBodyState extends State<_CreateRouteSheetBody> {
  final _selectedIds = <String>{};
  String _optimizationType = 'fastest';
  MapPickerResult? _startPoint;
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _loadingGps = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (mounted) {
        setState(() {
          _startPoint = MapPickerResult(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        });
      }
    } catch (_) {
      // GPS مش متاح — المستخدم يختار من الماب
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  Future<void> _pickStartPointFromMap() async {
    final result = await SekkaMapPicker.show(
      context,
      title: AppStrings.startPoint,
      initialLatitude: _startPoint?.latitude,
      initialLongitude: _startPoint?.longitude,
    );
    if (result != null && mounted) {
      setState(() => _startPoint = result);
    }
  }

  void _submit() {
    if (_selectedIds.isEmpty || _startPoint == null) return;
    Navigator.pop(context);
    context.read<RouteBloc>().add(
          RouteOptimizeRequested(
            orderIds: _selectedIds.toList(),
            startLatitude: _startPoint!.latitude,
            startLongitude: _startPoint!.longitude,
            optimizationType: _optimizationType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: Responsive.screenHeight * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(20)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          _buildHandle(isDark),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding,
              vertical: AppSizes.md,
            ),
            child: Row(
              children: [
                Icon(
                  IconsaxPlusBold.routing_2,
                  color: AppColors.primary,
                  size: Responsive.r(22),
                ),
                SizedBox(width: Responsive.w(10)),
                Text(
                  AppStrings.enterYourRoute,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                const Spacer(),
                if (_selectedIds.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Text(
                      '${_selectedIds.length}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Divider(color: isDark ? AppColors.borderDark : AppColors.border),

          // Start point
          _buildStartPoint(isDark),

          // Optimization type selector
          _buildOptimizationType(isDark),

          Divider(color: isDark ? AppColors.borderDark : AppColors.border),

          // Section: Orders
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding,
              vertical: AppSizes.sm,
            ),
            child: Row(
              children: [
                Icon(
                  IconsaxPlusLinear.box,
                  size: AppSizes.iconMd,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.sm),
                Text(
                  AppStrings.selectOrders,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
              ],
            ),
          ),

          // Orders list
          if (widget.activeOrders.isEmpty)
            Padding(
              padding: EdgeInsets.all(AppSizes.xxl),
              child: Column(
                children: [
                  Icon(
                    IconsaxPlusLinear.box,
                    size: Responsive.r(40),
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  SizedBox(height: Responsive.h(12)),
                  Text(
                    AppStrings.noActiveOrders,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: AppSizes.sm,
                ),
                itemCount: widget.activeOrders.length,
                separatorBuilder: (_, __) => SizedBox(height: AppSizes.sm),
                itemBuilder: (_, index) {
                  final order = widget.activeOrders[index];
                  final isSelected = _selectedIds.contains(order.id);

                  return _OrderSelectTile(
                    order: order,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(order.id);
                        } else {
                          _selectedIds.add(order.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),

          // Submit button
          if (widget.activeOrders.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(AppSizes.pagePadding),
              child: SekkaButton(
                label: _selectedIds.isEmpty
                    ? AppStrings.optimizeRoute
                    : '${AppStrings.optimizeRoute} (${_selectedIds.length})',
                icon: IconsaxPlusLinear.routing_2,
                onPressed: _selectedIds.isEmpty || _startPoint == null
                    ? null
                    : _submit,
              ),
            ),

          SizedBox(
            height: Responsive.safePadding.bottom + Responsive.h(10),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(bool isDark) {
    return Container(
      margin: EdgeInsets.only(top: Responsive.h(10)),
      width: Responsive.w(40),
      height: Responsive.h(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.borderDark : AppColors.border,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
    );
  }

  Widget _buildStartPoint(bool isDark) {
    final hasPoint = _startPoint != null;
    final color = hasPoint ? AppColors.success : AppColors.primary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.sm,
      ),
      child: GestureDetector(
        onTap: _pickStartPointFromMap,
        child: Container(
          padding: EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              if (_loadingGps)
                SizedBox(
                  width: AppSizes.iconMd,
                  height: AppSizes.iconMd,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                Icon(
                  hasPoint
                      ? IconsaxPlusBold.location
                      : IconsaxPlusLinear.location,
                  size: AppSizes.iconMd,
                  color: color,
                ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.startPoint,
                      style: AppTypography.captionSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _loadingGps
                          ? 'جاري تحديد موقعك...'
                          : hasPoint
                              ? (_startPoint!.address ??
                                  AppStrings.yourCurrentLocation)
                              : AppStrings.pickLocationOnMap,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasPoint && !_loadingGps)
                Icon(
                  Icons.check_circle,
                  size: AppSizes.iconMd,
                  color: AppColors.success,
                )
              else if (!_loadingGps)
                Icon(
                  IconsaxPlusLinear.arrow_left_2,
                  size: AppSizes.iconMd,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizationType(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.optimizationTypeLabel,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Row(
            children: [
              for (var i = 0; i < _optimizationTypes.length; i++) ...[
                if (i > 0) SizedBox(width: AppSizes.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _optimizationType = _optimizationTypes[i].$1,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding:
                          EdgeInsets.symmetric(vertical: AppSizes.md),
                      decoration: BoxDecoration(
                        color: _optimizationType == _optimizationTypes[i].$1
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color:
                              _optimizationType == _optimizationTypes[i].$1
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.border),
                          width: 0.5,
                        ),
                        boxShadow:
                            _optimizationType == _optimizationTypes[i].$1
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _optimizationTypes[i].$2,
                        style: AppTypography.titleMedium.copyWith(
                          color:
                              _optimizationType == _optimizationTypes[i].$1
                                  ? AppColors.textOnPrimary
                                  : (isDark
                                      ? AppColors.textCaptionDark
                                      : AppColors.textCaption),
                          fontWeight:
                              _optimizationType == _optimizationTypes[i].$1
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ORDER SELECT TILE — كارت اختيار طلب (في شيت الإنشاء)
// ══════════════════════════════════════════════════════════════════════════

class _OrderSelectTile extends StatelessWidget {
  const _OrderSelectTile({
    required this.order,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final OrderModel order;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : isDark
                  ? AppColors.backgroundDark
                  : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                    ? AppColors.borderDark
                    : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: Responsive.w(24),
              height: Responsive.w(24),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.borderDark
                          : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: Responsive.r(14),
                      color: AppColors.textOnPrimary,
                    )
                  : null,
            ),
            SizedBox(width: AppSizes.md),

            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName ?? order.orderNumber,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                  ),
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    order.deliveryAddress,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${order.amount.toStringAsFixed(0)} ${AppStrings.currency}',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ADD ORDER SHEET — إضافة طلب لمسار موجود
// ══════════════════════════════════════════════════════════════════════════

void _showAddOrderSheet(
  BuildContext context,
  String routeId,
  bool isDark,
) {
  final bloc = context.read<RouteBloc>();
  final ordersState = context.read<OrdersBloc>().state;
  final List<OrderModel> activeOrders;

  if (ordersState is OrdersLoaded) {
    activeOrders =
        ordersState.orders.where((o) => o.status.isActive).toList();
  } else {
    activeOrders = [];
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: Responsive.screenHeight * 0.65,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Responsive.r(20)),
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: Responsive.h(10)),
                width: Responsive.w(40),
                height: Responsive.h(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.all(AppSizes.xxl),
                child: Row(
                  children: [
                    Icon(
                      IconsaxPlusBold.add_circle,
                      color: AppColors.primary,
                      size: Responsive.r(22),
                    ),
                    SizedBox(width: Responsive.w(10)),
                    Text(
                      AppStrings.addOrderToRoute,
                      style: AppTypography.titleLarge.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                  color: isDark ? AppColors.borderDark : AppColors.border),

              if (activeOrders.isEmpty)
                Padding(
                  padding: EdgeInsets.all(AppSizes.xxl),
                  child: Column(
                    children: [
                      Icon(
                        IconsaxPlusLinear.box,
                        size: Responsive.r(40),
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                      SizedBox(height: Responsive.h(12)),
                      Text(
                        AppStrings.noActiveOrders,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textCaptionDark
                              : AppColors.textCaption,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.pagePadding,
                      vertical: AppSizes.md,
                    ),
                    itemCount: activeOrders.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSizes.sm),
                    itemBuilder: (_, index) {
                      final order = activeOrders[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          context.read<RouteBloc>().add(
                                RouteAddOrderRequested(
                                  routeId: routeId,
                                  orderId: order.id,
                                ),
                              );
                        },
                        child: SekkaCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.customerName ??
                                          order.orderNumber,
                                      style: AppTypography.titleMedium
                                          .copyWith(
                                        color: isDark
                                            ? AppColors.textHeadlineDark
                                            : AppColors.textHeadline,
                                      ),
                                    ),
                                    SizedBox(height: Responsive.h(2)),
                                    Row(
                                      children: [
                                        Icon(
                                          IconsaxPlusLinear.location,
                                          size: AppSizes.iconSm,
                                          color: isDark
                                              ? AppColors.textCaptionDark
                                              : AppColors.textCaption,
                                        ),
                                        SizedBox(width: AppSizes.xs),
                                        Expanded(
                                          child: Text(
                                            order.deliveryAddress,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              color: isDark
                                                  ? AppColors.textBodyDark
                                                  : AppColors.textBody,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${order.amount.toStringAsFixed(0)} ${AppStrings.currency}',
                                style:
                                    AppTypography.titleMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(
                height: Responsive.safePadding.bottom + Responsive.h(10),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════
//  PARKING SHEET — أماكن الركن
// ══════════════════════════════════════════════════════════════════════════

void _showParkingSheet(BuildContext context, bool isDark) {
  final dioClient = context.read<DioClient>();
  final datasource = ParkingRemoteDataSource(dioClient);
  final repo = ParkingRepositoryImpl(remoteDataSource: datasource);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider(
      create: (_) =>
          ParkingBloc(repository: repo)..add(const ParkingLoadRequested()),
      child: _ParkingSheetBody(isDark: isDark),
    ),
  );
}

class _ParkingSheetBody extends StatelessWidget {
  const _ParkingSheetBody({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: Responsive.screenHeight * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(20)),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: Responsive.h(10)),
              width: Responsive.w(40),
              height: Responsive.h(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
            ),

            // Title + add button
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.lg,
                AppSizes.pagePadding,
                AppSizes.md,
              ),
              child: Row(
                children: [
                  Text(
                    AppStrings.myParkingSpots,
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => showCreateParkingSheet(context, isDark),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            IconsaxPlusLinear.add,
                            size: AppSizes.iconSm,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: AppSizes.xs),
                          Text(
                            AppStrings.addParkingSpot,
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
            ),

            // Content
            Expanded(
              child: BlocConsumer<ParkingBloc, ParkingState>(
                listener: (context, state) {
                  if (state is ParkingLoaded && state.actionMessage != null) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              state.actionMessage!,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textOnPrimary),
                            ),
                          ),
                          backgroundColor: state.isActionError
                              ? AppColors.error
                              : AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                        ),
                      );
                    context
                        .read<ParkingBloc>()
                        .add(const ParkingClearMessage());
                  }
                },
                builder: (context, state) => switch (state) {
                  ParkingInitial() || ParkingLoading() => const Center(
                      child: SekkaLoading(),
                    ),
                  ParkingLoaded(:final spots) => spots.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(AppSizes.pagePadding),
                          child: SekkaEmptyState(
                            icon: IconsaxPlusLinear.car,
                            title: AppStrings.noParkingSpots,
                            description: AppStrings.noParkingSpotsHint,
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.pagePadding,
                          ),
                          itemCount: spots.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: AppSizes.sm),
                          itemBuilder: (context, index) => ParkingSpotTile(
                            spot: spots[index],
                            isDark: isDark,
                          ),
                        ),
                  ParkingError(:final message) => Center(
                      child: Text(
                        message,
                        style: AppTypography.bodyMedium.copyWith(
                          color:
                              isDark ? AppColors.textBodyDark : AppColors.textBody,
                        ),
                      ),
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  PARKING SPOT TILE
// ══════════════════════════════════════════════════════════════════════════

class ParkingSpotTile extends StatelessWidget {
  const ParkingSpotTile({super.key, required this.spot, required this.isDark});

  final ParkingModel spot;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      child: Row(
        children: [
          // Location icon
          Container(
            width: Responsive.w(40),
            height: Responsive.w(40),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconsaxPlusLinear.car,
              size: AppSizes.iconMd,
              color: AppColors.info,
            ),
          ),
          SizedBox(width: AppSizes.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.address ?? '${spot.latitude.toStringAsFixed(4)}, ${spot.longitude.toStringAsFixed(4)}',
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
                    // Rating stars
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < spot.qualityRating
                            ? IconsaxPlusBold.star_1
                            : IconsaxPlusLinear.star_1,
                        size: Responsive.r(14),
                        color: i < spot.qualityRating
                            ? AppColors.warning
                            : (isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption),
                      ),
                    ),
                    SizedBox(width: AppSizes.sm),
                    // Paid/Free badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: Responsive.h(2),
                      ),
                      decoration: BoxDecoration(
                        color: spot.isPaid
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : AppColors.success.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusPill),
                      ),
                      child: Text(
                        spot.isPaid
                            ? AppStrings.parkingPaid
                            : AppStrings.parkingFree,
                        style: AppTypography.captionSmall.copyWith(
                          color: spot.isPaid
                              ? AppColors.warning
                              : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.sm),
                    // Usage count
                    Text(
                      '${spot.usageCount}×',
                      style: AppTypography.captionSmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete button
          GestureDetector(
            onTap: () => _confirmDelete(context, spot.id, isDark),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.sm),
              child: Icon(
                IconsaxPlusLinear.trash,
                size: AppSizes.iconSm,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          title: Text(
            AppStrings.parkingDeleted,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          content: Text(
            AppStrings.deleteParkingConfirm,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.cancel,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textBodyDark : AppColors.textBody,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context
                    .read<ParkingBloc>()
                    .add(ParkingDeleteRequested(id: id));
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
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  CREATE PARKING SHEET — حفظ مكان ركن جديد
// ══════════════════════════════════════════════════════════════════════════

void showCreateParkingSheet(BuildContext context, bool isDark) {
  final bloc = context.read<ParkingBloc>();

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _CreateParkingSheetBody(isDark: isDark),
    ),
  );
}

class _CreateParkingSheetBody extends StatefulWidget {
  const _CreateParkingSheetBody({required this.isDark});

  final bool isDark;

  @override
  State<_CreateParkingSheetBody> createState() =>
      _CreateParkingSheetBodyState();
}

class _CreateParkingSheetBodyState extends State<_CreateParkingSheetBody> {
  final _addressController = TextEditingController();
  MapPickerResult? _location;
  int _rating = 3;
  bool _isPaid = false;
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _loadingGps = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (mounted) {
        setState(() {
          _location = MapPickerResult(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        });
      }
    } catch (_) {
      // GPS failed — user can pick manually
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Responsive.r(20)),
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.md,
              AppSizes.pagePadding,
              AppSizes.lg + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: Responsive.w(40),
                    height: Responsive.h(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.lg),

                // Title
                Text(
                  AppStrings.addParkingSpot,
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.lg),

                // Location
                SekkaCard(
                  onTap: () async {
                    final result = await showModalBottomSheet<MapPickerResult>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => SizedBox(
                        height: Responsive.screenHeight * 0.85,
                        child: SekkaMapPicker(
                          initialLatitude: _location?.latitude,
                          initialLongitude: _location?.longitude,
                        ),
                      ),
                    );
                    if (result != null && mounted) {
                      setState(() => _location = result);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        IconsaxPlusLinear.location,
                        size: AppSizes.iconMd,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSizes.md),
                      Expanded(
                        child: _loadingGps
                            ? Text(
                                '...',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textBodyDark
                                      : AppColors.textBody,
                                ),
                              )
                            : Text(
                                _location != null
                                    ? '${_location!.latitude.toStringAsFixed(4)}, ${_location!.longitude.toStringAsFixed(4)}'
                                    : AppStrings.pickLocationOnMap,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: _location != null
                                      ? (isDark
                                          ? AppColors.textHeadlineDark
                                          : AppColors.textHeadline)
                                      : (isDark
                                          ? AppColors.textCaptionDark
                                          : AppColors.textCaption),
                                ),
                              ),
                      ),
                      Icon(
                        IconsaxPlusLinear.arrow_left_2,
                        size: AppSizes.iconSm,
                        color:
                            isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.md),

                // Address
                SekkaInputField(
                  controller: _addressController,
                  label: AppStrings.parkingAddress,
                  hint: AppStrings.parkingAddress,
                ),
                SizedBox(height: AppSizes.md),

                // Rating
                Text(
                  AppStrings.parkingRating,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                Row(
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: EdgeInsets.only(left: AppSizes.xs),
                        child: Icon(
                          i < _rating
                              ? IconsaxPlusBold.star_1
                              : IconsaxPlusLinear.star_1,
                          size: Responsive.r(28),
                          color: i < _rating
                              ? AppColors.warning
                              : (isDark
                                  ? AppColors.textCaptionDark
                                  : AppColors.textCaption),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.md),

                // Is paid toggle
                GestureDetector(
                  onTap: () => setState(() => _isPaid = !_isPaid),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: Responsive.w(22),
                        height: Responsive.w(22),
                        decoration: BoxDecoration(
                          color: _isPaid
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSm),
                          border: Border.all(
                            color: _isPaid
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.border),
                            width: 2,
                          ),
                        ),
                        child: _isPaid
                            ? Icon(
                                Icons.check,
                                size: Responsive.r(14),
                                color: AppColors.textOnPrimary,
                              )
                            : null,
                      ),
                      SizedBox(width: AppSizes.md),
                      Text(
                        AppStrings.parkingIsPaid,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textBodyDark
                              : AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.xl),

                // Save button
                BlocBuilder<ParkingBloc, ParkingState>(
                  builder: (context, state) {
                    final isLoading = state is ParkingLoaded &&
                        state.isActionInProgress;
                    return SekkaButton(
                      label: AppStrings.addParkingSpot,
                      icon: IconsaxPlusLinear.car,
                      isLoading: isLoading,
                      onPressed: _location == null || isLoading
                          ? null
                          : () {
                              context.read<ParkingBloc>().add(
                                    ParkingCreateRequested(
                                      latitude: _location!.latitude,
                                      longitude: _location!.longitude,
                                      address: _addressController.text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : _addressController.text.trim(),
                                      qualityRating: _rating,
                                      isPaid: _isPaid,
                                    ),
                                  );
                              Navigator.pop(context);
                            },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
