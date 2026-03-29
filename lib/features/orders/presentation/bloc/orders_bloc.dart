import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/network/api_exception.dart';
import '../../domain/repositories/order_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({required OrderRepository repository})
      : _repository = repository,
        super(const OrdersInitial()) {
    on<OrdersLoadRequested>(_onLoad);
    on<OrdersLoadMore>(_onLoadMore);
    on<OrdersFilterChanged>(_onFilterChanged);
    on<OrdersSearchChanged>(_onSearchChanged);
    on<OrderCreateRequested>(_onCreate);
    on<OrderDetailLoadRequested>(_onDetailLoad);
    on<OrderUpdateRequested>(_onUpdate);
    on<OrderDeleteRequested>(_onDelete);
    on<OrderStatusChangeRequested>(_onStatusChange);
    on<OrderDeliverRequested>(_onDeliver);
    on<OrderFailRequested>(_onFail);
    on<OrderCancelRequested>(_onCancel);
    on<OrderPhotoUploadRequested>(_onPhotoUpload);
    on<OrderSwapAddressRequested>(_onSwapAddress);
    on<OrderBulkImportRequested>(_onBulkImport);
    on<OrderTransferRequested>(_onTransfer);
    on<OrderPartialDeliveryRequested>(_onPartialDelivery);
    on<OrderWaitingStartRequested>(_onWaitingStart);
    on<OrderWaitingStopRequested>(_onWaitingStop);
    on<OrderDisclaimerPostRequested>(_onDisclaimerPost);
    on<OrderDisclaimerLoadRequested>(_onDisclaimerLoad);
    on<OrderDisputeRequested>(_onDisputePost);
    on<OrderDisputesLoadRequested>(_onDisputesLoad);
    on<OrderRefundRequested>(_onRefundPost);
    on<OrderRefundsLoadRequested>(_onRefundsLoad);
    on<OrderTimeSlotsLoadRequested>(_onTimeSlotsLoad);
    on<OrderBookSlotRequested>(_onBookSlot);
    on<OrderCalculatePriceRequested>(_onCalculatePrice);
    on<OrderCheckDuplicateRequested>(_onCheckDuplicate);
  }

  final OrderRepository _repository;

  // ── Load / Refresh ──────────────────────────────────────────────────

  Future<void> _onLoad(
    OrdersLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    final statusFilter =
        event.statusFilter ?? (current is OrdersLoaded ? current.statusFilter : null);
    final searchTerm =
        event.searchTerm ?? (current is OrdersLoaded ? current.searchTerm : null);

    if (!event.refresh) {
      emit(const OrdersLoading());
    }

    try {
      final result = await _repository.getOrders(
        page: 1,
        status: statusFilter,
        searchTerm: searchTerm,
      );

      emit(OrdersLoaded(
        orders: result.items,
        statusFilter: statusFilter,
        searchTerm: searchTerm ?? '',
        hasMore: result.hasNextPage,
        currentPage: 1,
      ));
    } on ApiException catch (e) {
      emit(OrdersError(e.message));
    } catch (_) {
      emit(const OrdersError(AppStrings.unknownError));
    }
  }

  // ── Pagination ──────────────────────────────────────────────────────

  Future<void> _onLoadMore(
    OrdersLoadMore event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;
      final result = await _repository.getOrders(
        page: nextPage,
        status: current.statusFilter,
        searchTerm: current.searchTerm.isEmpty ? null : current.searchTerm,
      );

      emit(current.copyWith(
        orders: [...current.orders, ...result.items],
        hasMore: result.hasNextPage,
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } on ApiException {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  // ── Filter ──────────────────────────────────────────────────────────

  Future<void> _onFilterChanged(
    OrdersFilterChanged event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) {
      add(OrdersLoadRequested(statusFilter: event.status));
      return;
    }

    emit(current.copyWith(
      statusFilter: () => event.status,
      isLoadingMore: true,
    ));

    try {
      final result = await _repository.getOrders(
        page: 1,
        status: event.status,
        searchTerm: current.searchTerm.isEmpty ? null : current.searchTerm,
      );

      emit(current.copyWith(
        orders: result.items,
        statusFilter: () => event.status,
        hasMore: result.hasNextPage,
        currentPage: 1,
        isLoadingMore: false,
      ));
    } on ApiException {
      emit(current.copyWith(
        statusFilter: () => event.status,
        isLoadingMore: false,
      ));
    }
  }

  // ── Search ──────────────────────────────────────────────────────────

  Future<void> _onSearchChanged(
    OrdersSearchChanged event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) {
      add(OrdersLoadRequested(searchTerm: event.searchTerm));
      return;
    }

    emit(current.copyWith(
      searchTerm: event.searchTerm,
      isLoadingMore: true,
    ));

    try {
      final result = await _repository.getOrders(
        page: 1,
        status: current.statusFilter,
        searchTerm: event.searchTerm.isEmpty ? null : event.searchTerm,
      );

      emit(current.copyWith(
        orders: result.items,
        searchTerm: event.searchTerm,
        hasMore: result.hasNextPage,
        currentPage: 1,
        isLoadingMore: false,
      ));
    } on ApiException {
      emit(current.copyWith(
        searchTerm: event.searchTerm,
        isLoadingMore: false,
      ));
    }
  }

  // ── Create ──────────────────────────────────────────────────────────

  Future<void> _onCreate(
    OrderCreateRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;

    // Ensure we have a loaded state; if not, create a minimal one
    final loaded = current is OrdersLoaded
        ? current
        : const OrdersLoaded(orders: [], hasMore: false, currentPage: 1);

    emit(loaded.copyWith(isActionInProgress: true));

    try {
      var newOrder = await _repository.createOrder(event.data);

      // Backend may not return customerName/Phone in response — merge from request
      newOrder = newOrder.copyWith(
        customerName: newOrder.customerName ?? event.data['customerName'] as String?,
        customerPhone: newOrder.customerPhone ?? event.data['customerPhone'] as String?,
        pickupAddress: newOrder.pickupAddress ?? event.data['pickupAddress'] as String?,
        notes: newOrder.notes ?? event.data['notes'] as String?,
      );

      emit(loaded.copyWith(
        orders: [newOrder, ...loaded.orders],
        isActionInProgress: false,
        actionMessage: () => AppStrings.orderCreatedSuccess,
      ));
    } on ApiException catch (e) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Detail ──────────────────────────────────────────────────────────

  Future<void> _onDetailLoad(
    OrderDetailLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      var order = await _repository.getOrderDetail(event.orderId);

      // Backend may not return customerName/Phone — merge from local list
      final localOrder = current.orders
          .where((o) => o.id == event.orderId)
          .firstOrNull;
      if (localOrder != null) {
        order = order.copyWith(
          customerName: order.customerName ?? localOrder.customerName,
          customerPhone: order.customerPhone ?? localOrder.customerPhone,
        );
      }

      emit(current.copyWith(
        selectedOrder: () => order,
        isActionInProgress: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Update ──────────────────────────────────────────────────────────

  Future<void> _onUpdate(
    OrderUpdateRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      final updated = await _repository.updateOrder(event.orderId, event.data);

      final updatedList = current.orders.map((o) {
        return o.id == event.orderId ? updated : o;
      }).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () =>
            current.selectedOrder?.id == event.orderId ? updated : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.orderUpdatedSuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────

  Future<void> _onDelete(
    OrderDeleteRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.deleteOrder(event.orderId);

      final updatedList =
          current.orders.where((o) => o.id != event.orderId).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () =>
            current.selectedOrder?.id == event.orderId ? null : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.orderDeletedSuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Status Change ───────────────────────────────────────────────────

  Future<void> _onStatusChange(
    OrderStatusChangeRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.updateOrderStatus(event.orderId, {
        'status': event.newStatus,
        if (event.notes != null) 'notes': event.notes,
      });

      final detail = await _repository.getOrderDetail(event.orderId);

      final updatedList = current.orders.map((o) {
        return o.id == event.orderId ? detail : o;
      }).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () =>
            current.selectedOrder?.id == event.orderId ? detail : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.orderStatusUpdatedSuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Deliver ─────────────────────────────────────────────────────────

  Future<void> _onDeliver(
    OrderDeliverRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.deliverOrder(event.orderId, {
        if (event.actualAmount != null) 'actualCollectedAmount': event.actualAmount,
        if (event.notes != null) 'notes': event.notes,
        if (event.rating != null) 'ratingValue': event.rating,
      });

      final detail = await _repository.getOrderDetail(event.orderId);

      final updatedList = current.orders.map((o) {
        return o.id == event.orderId ? detail : o;
      }).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () =>
            current.selectedOrder?.id == event.orderId ? detail : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.orderDeliveredSuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Fail ────────────────────────────────────────────────────────────

  Future<void> _onFail(
    OrderFailRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.failOrder(event.orderId, {
        'reason': event.reason,
        if (event.reasonText != null) 'reasonText': event.reasonText,
      });

      final detail = await _repository.getOrderDetail(event.orderId);

      final updatedList = current.orders.map((o) {
        return o.id == event.orderId ? detail : o;
      }).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () =>
            current.selectedOrder?.id == event.orderId ? detail : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.orderFailedSuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Cancel ──────────────────────────────────────────────────────────

  Future<void> _onCancel(
    OrderCancelRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.cancelOrder(event.orderId, {
        'cancellationReason': event.reason,
        if (event.reasonText != null) 'reasonText': event.reasonText,
        if (event.lossAmount != null) 'lossAmount': event.lossAmount,
      });

      final detail = await _repository.getOrderDetail(event.orderId);

      final updatedList = current.orders.map((o) {
        return o.id == event.orderId ? detail : o;
      }).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () =>
            current.selectedOrder?.id == event.orderId ? detail : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.orderCancelledSuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Photo Upload ────────────────────────────────────────────────────

  Future<void> _onPhotoUpload(
    OrderPhotoUploadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.uploadPhoto(
        event.orderId,
        event.imageFile,
        event.photoType,
      );

      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.photoUploadedSuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Swap Address ────────────────────────────────────────────────────

  Future<void> _onSwapAddress(
    OrderSwapAddressRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.swapAddress(event.orderId, {
        'newDeliveryAddress': event.newAddress,
        if (event.reason != null) 'reason': event.reason,
      });

      final detail = await _repository.getOrderDetail(event.orderId);

      final updatedList = current.orders.map((o) {
        return o.id == event.orderId ? detail : o;
      }).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () =>
            current.selectedOrder?.id == event.orderId ? detail : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.addressSwappedSuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Bulk Import ─────────────────────────────────────────────────────

  Future<void> _onBulkImport(
    OrderBulkImportRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      final result = await _repository.bulkImport({
        'rawText': event.text,
        if (event.defaultPaymentMethod != null)
          'defaultPaymentMethod': event.defaultPaymentMethod,
      });

      final importedCount = result['importedCount'] as int? ?? 0;

      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => '${AppStrings.bulkImportSuccess} ($importedCount)',
      ));

      // Reload the list to include newly imported orders.
      add(OrdersLoadRequested(
        statusFilter: current.statusFilter,
        searchTerm: current.searchTerm.isEmpty ? null : current.searchTerm,
        refresh: true,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Transfer ─────────────────────────────────────────────────────────

  Future<void> _onTransfer(
    OrderTransferRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.transferOrder(event.orderId, {
        'targetDriverId': event.targetDriverId,
        if (event.reason != null) 'reason': event.reason,
      });

      final detail = await _repository.getOrderDetail(event.orderId);

      final updatedList = current.orders.map((o) {
        return o.id == event.orderId ? detail : o;
      }).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () =>
            current.selectedOrder?.id == event.orderId ? detail : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.transferSuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Partial Delivery ─────────────────────────────────────────────────

  Future<void> _onPartialDelivery(
    OrderPartialDeliveryRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.partialDelivery(event.orderId, {
        'deliveredItemCount': event.deliveredItemCount,
        'totalItemCount': event.totalItemCount,
        'collectedAmount': event.collectedAmount,
        'remainingAmount': event.remainingAmount,
        if (event.reason != null) 'reason': event.reason,
      });

      final detail = await _repository.getOrderDetail(event.orderId);

      final updatedList = current.orders.map((o) {
        return o.id == event.orderId ? detail : o;
      }).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () =>
            current.selectedOrder?.id == event.orderId ? detail : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.partialDeliverySuccess,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Waiting Timer Start ──────────────────────────────────────────────

  Future<void> _onWaitingStart(
    OrderWaitingStartRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.startWaitingTimer(event.orderId);

      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.waitingStarted,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Waiting Timer Stop ───────────────────────────────────────────────

  Future<void> _onWaitingStop(
    OrderWaitingStopRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.stopWaitingTimer(event.orderId);

      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.waitingStopped,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Disclaimer Post ──────────────────────────────────────────────────

  Future<void> _onDisclaimerPost(
    OrderDisclaimerPostRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.postDisclaimer(event.orderId, event.data);

      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.disclaimerAdded,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Disclaimer Load ──────────────────────────────────────────────────

  Future<void> _onDisclaimerLoad(
    OrderDisclaimerLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      final data = await _repository.getDisclaimer(event.orderId);

      emit(current.copyWith(
        isActionInProgress: false,
        disclaimerData: () => data,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Dispute Post ─────────────────────────────────────────────────────

  Future<void> _onDisputePost(
    OrderDisputeRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.postDispute(event.orderId, event.data);

      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.disputeCreated,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Disputes Load ────────────────────────────────────────────────────

  Future<void> _onDisputesLoad(
    OrderDisputesLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      final data = await _repository.getDisputes(event.orderId);

      emit(current.copyWith(
        isActionInProgress: false,
        disputes: data,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Refund Post ──────────────────────────────────────────────────────

  Future<void> _onRefundPost(
    OrderRefundRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.postRefund(event.orderId, event.data);

      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.refundRequested,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Refunds Load ─────────────────────────────────────────────────────

  Future<void> _onRefundsLoad(
    OrderRefundsLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      final data = await _repository.getRefunds(event.orderId);

      emit(current.copyWith(
        isActionInProgress: false,
        refunds: data,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Time Slots Load ──────────────────────────────────────────────────

  Future<void> _onTimeSlotsLoad(
    OrderTimeSlotsLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    final loaded = current is OrdersLoaded
        ? current
        : const OrdersLoaded(orders: [], hasMore: false, currentPage: 1);

    emit(loaded.copyWith(isActionInProgress: true));

    try {
      final data = await _repository.getTimeSlots();

      emit(loaded.copyWith(
        isActionInProgress: false,
        timeSlots: data,
      ));
    } on ApiException catch (e) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Book Slot ────────────────────────────────────────────────────────

  Future<void> _onBookSlot(
    OrderBookSlotRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _repository.bookSlot(event.orderId, event.data);

      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.slotBooked,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Calculate Price ──────────────────────────────────────────────────

  Future<void> _onCalculatePrice(
    OrderCalculatePriceRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    final loaded = current is OrdersLoaded
        ? current
        : const OrdersLoaded(orders: [], hasMore: false, currentPage: 1);

    try {
      final data = await _repository.calculatePrice(event.data);

      emit(loaded.copyWith(
        priceCalculation: () => data,
      ));
    } on ApiException catch (e) {
      emit(loaded.copyWith(
        actionMessage: () => e.message,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        actionMessage: () => AppStrings.unknownError,
      ));
    }
  }

  // ── Check Duplicate ──────────────────────────────────────────────────

  Future<void> _onCheckDuplicate(
    OrderCheckDuplicateRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    final loaded = current is OrdersLoaded
        ? current
        : const OrdersLoaded(orders: [], hasMore: false, currentPage: 1);

    emit(loaded.copyWith(isActionInProgress: true));

    try {
      final data = await _repository.checkDuplicate(event.data);

      emit(loaded.copyWith(
        isActionInProgress: false,
        duplicateCheck: () => data,
      ));
    } on ApiException {
      // If check-duplicate fails, just proceed (don't block creation)
      emit(loaded.copyWith(
        isActionInProgress: false,
        duplicateCheck: () => {'isDuplicate': false},
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        duplicateCheck: () => {'isDuplicate': false},
      ));
    }
  }
}
