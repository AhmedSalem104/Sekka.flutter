import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_search_bar.dart';
import '../../../../core/widgets/sekka_segmented_tabs.dart';
import '../../../../shared/enums/order_enums.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../customers/data/repositories/customer_repository.dart';
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
  int? _selectedStatusFilter;
  String _searchTerm = '';
  List<CustomerModel> _customers = const [];

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
    final bloc = context.read<OrdersBloc>();
    if (bloc.state is OrdersLoaded) {
      bloc.add(const OrdersLoadRequested(refresh: true));
    } else {
      bloc.add(const OrdersLoadRequested());
    }
    _scrollController.addListener(_onScroll);
    _loadCustomersForSearch();
  }

  Future<void> _loadCustomersForSearch() async {
    final repo = CustomerRepository(context.read<DioClient>().dio);
    final result = await repo.getCustomers(pageSize: 200);
    if (!mounted) return;
    if (result case ApiSuccess(:final data)) {
      setState(() => _customers = data.items);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(List<OrderModel> all) {
    if (_searchTerm.isEmpty) return all;
    final rawQ = _searchTerm.toEnglishNumbers.toLowerCase();
    final digitsQ = rawQ.replaceAll(RegExp(r'\D'), '');

    // Cross-reference: find customer names matching the query (by name or phone)
    // so we can filter orders that have matching customerName.
    final matchedNames = <String>{};
    for (final c in _customers) {
      final cName = (c.name ?? '').toLowerCase();
      final cPhoneDigits =
          c.phone.toEnglishNumbers.replaceAll(RegExp(r'\D'), '');
      final byPhone = digitsQ.isNotEmpty && cPhoneDigits.contains(digitsQ);
      final byName = cName.isNotEmpty && cName.contains(rawQ);
      if ((byPhone || byName) && cName.isNotEmpty) {
        matchedNames.add(cName);
      }
    }

    return all.where((o) {
      final name = (o.customerName ?? '').toLowerCase();
      if (name.contains(rawQ)) return true;
      final orderPhoneDigits = (o.customerPhone ?? '')
          .toEnglishNumbers
          .replaceAll(RegExp(r'\D'), '');
      if (digitsQ.isNotEmpty && orderPhoneDigits.contains(digitsQ)) return true;
      for (final m in matchedNames) {
        if (name.contains(m)) return true;
      }
      return false;
    }).toList();
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
    setState(() => _searchTerm = value.trim());
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
          heroTag: 'orders_fab',
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
      appBar: SekkaAppBar(
        title: AppStrings.orders,
        showBack: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          textDirection: TextDirection.rtl,
          children: [
            SizedBox(height: AppSizes.md),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: SekkaSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      hint: AppStrings.searchCustomerHint,
                    ),
                  ),
                  SizedBox(width: AppSizes.sm),
                  _buildFilterButton(isDark),
                ],
              ),
            ),
            _buildActiveFiltersRow(isDark),
            SizedBox(height: AppSizes.md),

            _buildFilterChips(isDark),
            SizedBox(height: AppSizes.sm),

            Expanded(
              child: BlocConsumer<OrdersBloc, OrdersState>(
                listenWhen: (prev, curr) =>
                    curr is OrdersLoaded && curr.actionMessage != null,
                listener: (context, state) {
                  if (state is OrdersLoaded && state.actionMessage != null) {
                    final msg = state.actionMessage!;
                    final isError = state.isActionError;
                    // Silently swallow offline-sync chatter — the user should
                    // not feel offline mode; the top connectivity banner is
                    // the only signal they see about the network state.
                    final isSilent = msg == AppStrings.savedOffline ||
                        msg == AppStrings.orderSyncedSuccess;
                    if (!isSilent) {
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
                    }
                    context
                        .read<OrdersBloc>()
                        .add(const OrdersClearMessage());
                  }
                },
                buildWhen: (prev, curr) {
                  if (prev is OrdersLoaded && curr is OrdersLoaded) {
                    return prev.orders != curr.orders ||
                        prev.isLoadingMore != curr.isLoadingMore ||
                        prev.isActionInProgress != curr.isActionInProgress ||
                        prev.statusFilter != curr.statusFilter ||
                        prev.hasMore != curr.hasMore;
                  }
                  return true;
                },
                builder: (context, state) => switch (state) {
                  OrdersInitial() || OrdersLoading() => const SekkaLoading(),
                  OrdersLoaded(:final orders) when orders.isEmpty =>
                    SekkaEmptyState(
                      icon: IconsaxPlusLinear.clipboard_text,
                      title: AppStrings.noOrdersTitle,
                      description: _selectedStatusFilter != null
                          ? AppStrings.noOrdersWithFilter
                          : null,
                    ),
                  OrdersLoaded(:final orders, :final isLoadingMore) => () {
                      final filtered = _filterOrders(orders);
                      if (filtered.isEmpty && _searchTerm.isNotEmpty) {
                        return SekkaEmptyState(
                          icon: IconsaxPlusLinear.search_normal_1,
                          title: AppStrings.noSearchResults,
                          description: AppStrings.tryDifferentSearchOrder,
                        );
                      }
                      return _buildOrdersList(filtered, isLoadingMore, isDark);
                    }(),
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


  // ── Date filter helpers ───────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _displayDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) return iso;
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    final today = DateTime.now();
    final isToday = d.year == today.year &&
        d.month == today.month &&
        d.day == today.day;
    final yest = today.subtract(const Duration(days: 1));
    final isYesterday =
        d.year == yest.year && d.month == yest.month && d.day == yest.day;
    if (isToday) return AppStrings.today;
    if (isYesterday) return AppStrings.yesterday;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  Widget _buildFilterButton(bool isDark) {
    final state = context.watch<OrdersBloc>().state;
    final isActive = state is OrdersLoaded &&
        (state.dateFrom != null ||
            state.dateTo != null ||
            state.paymentMethod != null);
    return InkWell(
      onTap: _openFilterSheet,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        width: Responsive.w(48),
        height: Responsive.w(48),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Icon(
          IconsaxPlusLinear.filter,
          size: Responsive.r(22),
          color: isActive
              ? AppColors.textOnPrimary
              : (isDark ? AppColors.textBodyDark : AppColors.textBody),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersRow(bool isDark) {
    final state = context.watch<OrdersBloc>().state;
    if (state is! OrdersLoaded) return const SizedBox.shrink();

    final chips = <Widget>[];

    if (state.dateFrom != null) {
      final from = state.dateFrom!;
      final to = state.dateTo;
      final label = (to != null && to != from)
          ? '${_displayDate(from)} ← ${_displayDate(to)}'
          : _displayDate(from);
      chips.add(_filterChip(
        icon: IconsaxPlusLinear.calendar_1,
        label: label,
        onClear: () => context
            .read<OrdersBloc>()
            .add(const OrdersFilterChanged(clearDate: true)),
      ));
    }

    if (state.paymentMethod != null) {
      final method = PaymentMethod.fromValue(state.paymentMethod!);
      chips.add(_filterChip(
        icon: IconsaxPlusLinear.card,
        label: method.arabic,
        onClear: () => context
            .read<OrdersBloc>()
            .add(const OrdersFilterChanged(clearPaymentMethod: true)),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.sm,
        AppSizes.pagePadding,
        0,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          spacing: AppSizes.xs,
          runSpacing: AppSizes.xs,
          children: chips,
        ),
      ),
    );
  }

  Widget _filterChip({
    required IconData icon,
    required String label,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: Responsive.h(6),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: Responsive.r(14), color: AppColors.primary),
          SizedBox(width: Responsive.w(6)),
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: Responsive.w(6)),
          InkWell(
            onTap: onClear,
            child: Icon(
              IconsaxPlusLinear.close_circle,
              size: Responsive.r(16),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final state = context.read<OrdersBloc>().state;
    final currentFrom = state is OrdersLoaded ? state.dateFrom : null;
    final currentTo = state is OrdersLoaded ? state.dateTo : null;
    final currentPaymentMethod =
        state is OrdersLoaded ? state.paymentMethod : null;

    // Date mode: single day if from == to, otherwise range.
    bool isRangeMode =
        currentFrom != null && currentTo != null && currentFrom != currentTo;
    DateTime? singleDate =
        currentFrom != null ? DateTime.tryParse(currentFrom) : null;
    DateTime? rangeFrom =
        currentFrom != null ? DateTime.tryParse(currentFrom) : null;
    DateTime? rangeTo = currentTo != null ? DateTime.tryParse(currentTo) : null;
    int? paymentMethod = currentPaymentMethod;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (innerCtx, setSheetState) {
            final isDark = Theme.of(innerCtx).brightness == Brightness.dark;

            Future<DateTime?> pickDate(DateTime? initial) {
              return showDatePicker(
                context: innerCtx,
                initialDate: initial ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
            }

            final hasAny = rangeFrom != null ||
                rangeTo != null ||
                singleDate != null ||
                paymentMethod != null;
            final canApply = isRangeMode
                ? (rangeFrom != null && rangeTo != null) || paymentMethod != null
                : singleDate != null || paymentMethod != null;

            return SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    AppSizes.sm,
                    AppSizes.pagePadding,
                    AppSizes.lg,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: Responsive.w(40),
                            height: Responsive.h(4),
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusPill),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSizes.lg),
                        Text(
                          AppStrings.filterByDate,
                          style: AppTypography.headlineSmall,
                        ),
                        SizedBox(height: AppSizes.md),

                        // Date mode toggle: single day / range
                        SekkaSegmentedTabs(
                          labels: [
                            AppStrings.singleDay,
                            AppStrings.pickPeriod,
                          ],
                          selectedIndex: isRangeMode ? 1 : 0,
                          onChanged: (i) {
                            setSheetState(() => isRangeMode = i == 1);
                          },
                        ),
                        SizedBox(height: AppSizes.md),

                        if (!isRangeMode)
                          _datePickerField(
                            label: AppStrings.pickDay,
                            value: singleDate,
                            isDark: isDark,
                            onTap: () async {
                              final picked = await pickDate(singleDate);
                              if (picked != null) {
                                setSheetState(() => singleDate = picked);
                              }
                            },
                          )
                        else
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: _datePickerField(
                                  label: AppStrings.dateFromLabel,
                                  value: rangeFrom,
                                  isDark: isDark,
                                  onTap: () async {
                                    final picked = await pickDate(rangeFrom);
                                    if (picked != null) {
                                      setSheetState(() => rangeFrom = picked);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: _datePickerField(
                                  label: AppStrings.dateToLabel,
                                  value: rangeTo,
                                  isDark: isDark,
                                  onTap: () async {
                                    final picked = await pickDate(rangeTo);
                                    if (picked != null) {
                                      setSheetState(() => rangeTo = picked);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                        SizedBox(height: AppSizes.xl),

                        // Payment method section
                        Text(
                          AppStrings.filterByPaymentMethod,
                          style: AppTypography.headlineSmall,
                        ),
                        SizedBox(height: AppSizes.md),
                        Wrap(
                          spacing: AppSizes.xs,
                          runSpacing: AppSizes.xs,
                          children: [
                            _paymentChip(
                              label: AppStrings.allPaymentMethods,
                              selected: paymentMethod == null,
                              isDark: isDark,
                              onTap: () =>
                                  setSheetState(() => paymentMethod = null),
                            ),
                            ...PaymentMethod.values.map(
                              (m) => _paymentChip(
                                label: m.arabic,
                                selected: paymentMethod == m.value,
                                isDark: isDark,
                                onTap: () => setSheetState(
                                    () => paymentMethod = m.value),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppSizes.xl),

                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            if (hasAny) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.read<OrdersBloc>().add(
                                          const OrdersFilterChanged(
                                            clearDate: true,
                                            clearPaymentMethod: true,
                                          ),
                                        );
                                    Navigator.pop(sheetCtx);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: BorderSide(
                                      color: AppColors.error
                                          .withValues(alpha: 0.4),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: Responsive.h(14),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppSizes.radiusMd),
                                    ),
                                  ),
                                  child: Text(
                                    AppStrings.clearFilter,
                                    style:
                                        AppTypography.titleMedium.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSizes.sm),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                onPressed: !canApply
                                    ? null
                                    : () {
                                        String? dateFromIso;
                                        String? dateToIso;
                                        if (isRangeMode) {
                                          if (rangeFrom != null) {
                                            dateFromIso = _fmtDate(rangeFrom!);
                                          }
                                          if (rangeTo != null) {
                                            dateToIso = _fmtDate(rangeTo!);
                                          }
                                        } else if (singleDate != null) {
                                          dateFromIso = _fmtDate(singleDate!);
                                          dateToIso = dateFromIso;
                                        }
                                        context.read<OrdersBloc>().add(
                                              OrdersFilterChanged(
                                                dateFrom: dateFromIso,
                                                dateTo: dateToIso,
                                                paymentMethod: paymentMethod,
                                                clearDate: dateFromIso == null,
                                                clearPaymentMethod:
                                                    paymentMethod == null,
                                              ),
                                            );
                                        Navigator.pop(sheetCtx);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textOnPrimary,
                                  disabledBackgroundColor: AppColors.border,
                                  padding: EdgeInsets.symmetric(
                                    vertical: Responsive.h(14),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMd),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.apply,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _datePickerField({
    required String label,
    required DateTime? value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: Responsive.h(14),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              IconsaxPlusLinear.calendar_1,
              size: Responsive.r(20),
              color: AppColors.primary,
            ),
            SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                value != null ? _displayDate(_fmtDate(value)) : label,
                style: AppTypography.bodyMedium.copyWith(
                  color: value != null
                      ? (isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline)
                      : (isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption),
                  fontWeight:
                      value != null ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              IconsaxPlusLinear.arrow_down_1,
              size: Responsive.r(18),
              color: isDark
                  ? AppColors.textCaptionDark
                  : AppColors.textCaption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: Responsive.h(8),
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.backgroundDark : AppColors.background),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: selected
                ? AppColors.textOnPrimary
                : (isDark ? AppColors.textBodyDark : AppColors.textBody),
            fontWeight: FontWeight.w600,
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

            return GestureDetector(
              onTap: () => _onFilterSelected(statusValue),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                    width: 0.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : (isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
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

