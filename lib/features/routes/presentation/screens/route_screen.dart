import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_map_picker.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_state.dart';
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
          listener: _listener,
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

  void _listener(BuildContext context, RouteState state) {
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
          child: _RouteStatsCard(route: route, isDark: isDark),
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
          routeId: route.id,
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

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.routeId,
    required this.isLoading,
    required this.isDark,
  });

  final String routeId;
  final bool isLoading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.md,
        AppSizes.pagePadding,
        AppSizes.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SekkaButton(
        label: AppStrings.completeRoute,
        icon: IconsaxPlusLinear.tick_circle,
        isLoading: isLoading,
        onPressed: isLoading
            ? null
            : () => _confirmComplete(context),
      ),
    );
  }

  void _confirmComplete(BuildContext context) {
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
            AppStrings.completeRoute,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          content: Text(
            AppStrings.confirmCompleteRoute,
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
                context.read<RouteBloc>().add(
                      RouteCompleteRequested(routeId: routeId),
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
  const _RouteStatsCard({required this.route, required this.isDark});

  final RouteModel route;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      child: Row(
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

  Future<void> _pickStartPoint() async {
    final result = await SekkaMapPicker.show(
      context,
      title: AppStrings.startPoint,
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
        onTap: _pickStartPoint,
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
              Icon(
                hasPoint ? IconsaxPlusBold.location : IconsaxPlusLinear.location,
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
                      hasPoint
                          ? (_startPoint!.address ?? AppStrings.yourCurrentLocation)
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
              if (hasPoint)
                Icon(
                  Icons.check_circle,
                  size: AppSizes.iconMd,
                  color: AppColors.success,
                )
              else
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
            children: _optimizationTypes.map((type) {
              final (value, label, icon) = type;
              final isActive = _optimizationType == value;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _optimizationType = value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: AppSizes.xs),
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.md,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : isDark
                              ? AppColors.backgroundDark
                              : AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          size: AppSizes.iconMd,
                          color: isActive
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.textCaptionDark
                                  : AppColors.textCaption,
                        ),
                        SizedBox(height: AppSizes.xs),
                        Text(
                          label,
                          style: AppTypography.captionSmall.copyWith(
                            color: isActive
                                ? AppColors.primary
                                : isDark
                                    ? AppColors.textBodyDark
                                    : AppColors.textBody,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
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
