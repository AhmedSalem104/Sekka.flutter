import 'package:equatable/equatable.dart';

import '../../data/models/order_model.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

final class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

final class OrdersLoaded extends OrdersState {
  const OrdersLoaded({
    required this.orders,
    this.statusFilter,
    this.searchTerm = '',
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.isActionInProgress = false,
    this.selectedOrder,
    this.actionMessage,
    this.isActionError = false,
    this.timeSlots = const [],
    this.disclaimerData,
    this.disputes = const [],
    this.refunds = const [],
    this.priceCalculation,
    this.duplicateCheck,
    this.recurringOrders,
    this.isRecurringLoading = false,
  });

  final List<OrderModel> orders;
  final int? statusFilter;
  final String searchTerm;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final bool isActionInProgress;
  final OrderModel? selectedOrder;
  final String? actionMessage;
  final bool isActionError;
  final List<dynamic> timeSlots;
  final Map<String, dynamic>? disclaimerData;
  final List<dynamic> disputes;
  final List<dynamic> refunds;
  final Map<String, dynamic>? priceCalculation;
  final Map<String, dynamic>? duplicateCheck;
  final List<Map<String, dynamic>>? recurringOrders;
  final bool isRecurringLoading;

  OrdersLoaded copyWith({
    List<OrderModel>? orders,
    int? Function()? statusFilter,
    String? searchTerm,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    bool? isActionInProgress,
    OrderModel? Function()? selectedOrder,
    String? Function()? actionMessage,
    bool? isActionError,
    List<dynamic>? timeSlots,
    Map<String, dynamic>? Function()? disclaimerData,
    List<dynamic>? disputes,
    List<dynamic>? refunds,
    Map<String, dynamic>? Function()? priceCalculation,
    Map<String, dynamic>? Function()? duplicateCheck,
    List<Map<String, dynamic>>? Function()? recurringOrders,
    bool? isRecurringLoading,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      statusFilter:
          statusFilter != null ? statusFilter() : this.statusFilter,
      searchTerm: searchTerm ?? this.searchTerm,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      selectedOrder:
          selectedOrder != null ? selectedOrder() : this.selectedOrder,
      actionMessage:
          actionMessage != null ? actionMessage() : this.actionMessage,
      isActionError: isActionError ?? this.isActionError,
      timeSlots: timeSlots ?? this.timeSlots,
      disclaimerData:
          disclaimerData != null ? disclaimerData() : this.disclaimerData,
      disputes: disputes ?? this.disputes,
      refunds: refunds ?? this.refunds,
      priceCalculation:
          priceCalculation != null ? priceCalculation() : this.priceCalculation,
      duplicateCheck:
          duplicateCheck != null ? duplicateCheck() : this.duplicateCheck,
      recurringOrders:
          recurringOrders != null ? recurringOrders() : this.recurringOrders,
      isRecurringLoading: isRecurringLoading ?? this.isRecurringLoading,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        statusFilter,
        searchTerm,
        hasMore,
        currentPage,
        isLoadingMore,
        isActionInProgress,
        selectedOrder,
        actionMessage,
        isActionError,
        timeSlots,
        disclaimerData,
        disputes,
        refunds,
        priceCalculation,
        duplicateCheck,
        recurringOrders,
        isRecurringLoading,
      ];
}

final class OrdersError extends OrdersState {
  const OrdersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
