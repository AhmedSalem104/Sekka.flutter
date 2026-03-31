import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_search_bar.dart';
import '../../data/models/order_model.dart';
import 'create_order_screen.dart';
import 'order_detail_screen.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_card.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _selectedStatusFilter;

  static final _statusFilters = <(String, int?)>[
    (AppStrings.statusNew, 0),
    (AppStrings.statusOnTheWay, 3),
    (AppStrings.statusDelivered, 5),
    (AppStrings.statusPartiallyDelivered, 8),
    (AppStrings.statusFailed, 6),
    (AppStrings.statusCancelled, 7),
  ];

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const OrdersLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = Responsive.h(200);

    if (maxScroll - currentScroll <= threshold) {
      final state = context.read<OrdersBloc>().state;
      if (state is OrdersLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<OrdersBloc>().add(const OrdersLoadMore());
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<OrdersBloc>().add(
            OrdersSearchChanged(searchTerm: value.trim()),
          );
    });
  }

  void _onFilterSelected(int? statusValue) {
    setState(() => _selectedStatusFilter = statusValue);
    context.read<OrdersBloc>().add(
          OrdersFilterChanged(status: statusValue),
        );
  }

  void _navigateToCreateOrder() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const CreateOrderScreen()),
    );
  }

  void _navigateToOrderDetail(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (_) => OrderDetailScreen(orderId: orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      floatingActionButton: Padding(
        padding:
            EdgeInsets.only(bottom: AppSizes.bottomNavHeight + AppSizes.md),
        child: FloatingActionButton.extended(
          onPressed: _navigateToCreateOrder,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.fabRadius),
          ),
          label: Text(
            AppStrings.addOrder,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          textDirection: TextDirection.rtl,
          children: [
            _buildHeader(isDark),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
              ),
              child: SekkaSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hint: 'بحث برقم الطلب أو اسم العميل...',
              ),
            ),
            SizedBox(height: AppSizes.md),

            _buildFilterChips(isDark),
            SizedBox(height: AppSizes.sm),

            Expanded(
              child: BlocConsumer<OrdersBloc, OrdersState>(
                listener: (context, state) {
                  if (state is OrdersLoaded && state.actionMessage != null) {
                    final msg = state.actionMessage!;
                    final isError = state.isActionError;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(msg,
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textOnPrimary)),
                          ),
                          backgroundColor:
                              isError ? AppColors.error : AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                        ),
                      );
                    context
                        .read<OrdersBloc>()
                        .add(const OrdersClearMessage());
                  }
                },
                builder: (context, state) => switch (state) {
                  OrdersInitial() || OrdersLoading() => const SekkaLoading(),
                  OrdersLoaded(:final orders) when orders.isEmpty =>
                    SekkaEmptyState(
                      icon: IconsaxPlusLinear.clipboard_text,
                      title: 'مفيش طلبات',
                      description: _selectedStatusFilter != null
                          ? 'مفيش طلبات بالحالة دي'
                          : null,
                    ),
                  OrdersLoaded(:final orders, :final isLoadingMore) =>
                    _buildOrdersList(orders, isLoadingMore, isDark),
                  OrdersError(:final message) =>
                    _buildErrorView(message, isDark),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: EdgeInsets.only(
        right: AppSizes.pagePadding,
        left: AppSizes.pagePadding,
        top: AppSizes.lg,
        bottom: AppSizes.md,
      ),
      child: Center(
        child: Text(
          AppStrings.orders,
          style: AppTypography.headlineLarge.copyWith(
            color: isDark
                ? AppColors.textHeadlineDark
                : AppColors.textHeadline,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: Responsive.h(44),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
          itemCount: _statusFilters.length,
          separatorBuilder: (_, __) => SizedBox(width: Responsive.w(8)),
          itemBuilder: (context, index) {
            final (label, statusValue) = _statusFilters[index];
            final isSelected = _selectedStatusFilter == statusValue;

            return ChoiceChip(
              label: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _onFilterSelected(statusValue),
              selectedColor: AppColors.primary,
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surface,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? AppColors.borderDark
                        : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.chipRadius),
              ),
              showCheckmark: false,
              padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    List<OrderModel> orders,
    bool isLoadingMore,
    bool isDark,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<OrdersBloc>().add(
              OrdersLoadRequested(
                statusFilter: _selectedStatusFilter,
                searchTerm: _searchController.text.trim().isNotEmpty
                    ? _searchController.text.trim()
                    : null,
                refresh: true,
              ),
            );
        await context.read<OrdersBloc>().stream.firstWhere(
              (state) => state is OrdersLoaded || state is OrdersError,
            );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(
          right: AppSizes.pagePadding,
          left: AppSizes.pagePadding,
          top: AppSizes.sm,
          bottom: AppSizes.bottomNavHeight + AppSizes.xl,
        ),
        itemCount: orders.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final order = orders[index];
          return OrderCard(
            order: order,
            onTap: () => _navigateToOrderDetail(order.id),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String message, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.xxxl),
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
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: AppSizes.xl),
            TextButton.icon(
              onPressed: () {
                context.read<OrdersBloc>().add(
                      OrdersLoadRequested(
                        statusFilter: _selectedStatusFilter,
                        searchTerm: _searchController.text.trim().isNotEmpty
                            ? _searchController.text.trim()
                            : null,
                      ),
                    );
              },
              icon: Icon(
                IconsaxPlusLinear.refresh,
                size: AppSizes.iconMd,
                color: AppColors.primary,
              ),
              label: Text(
                AppStrings.retry,
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
