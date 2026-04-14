import 'dart:async';
import 'dart:developer' as dev;

import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/enums/order_enums.dart';
import '../../../../shared/network/api_exception.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/offline/offline_queue_service.dart';
import '../../../../shared/offline/queue_operation.dart';
import '../../../../shared/offline/sync_queue_service.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../data/models/order_model.dart';
import '../../../search/data/repositories/search_repository.dart';
import '../../domain/repositories/order_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends HydratedBloc<OrdersEvent, OrdersState> {
  OrdersBloc({
    required OrderRepository repository,
    SearchRepository? searchRepository,
  })  : _repository = repository,
        _searchRepository = searchRepository,
        super(const OrdersInitial()) {
    on<OrdersLoadRequested>(_onLoad);
    on<OrdersLoadMore>(_onLoadMore);
    on<OrdersFilterChanged>(_onFilterChanged);
    on<OrdersSearchChanged>(_onSearchChanged);
    on<OrderCreateRequested>(_onCreate);
    on<RecurringOrderCreateRequested>(_onCreateRecurring);
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
    on<RecurringOrdersLoadRequested>(_onRecurringOrdersLoad);
    on<RecurringOrderPauseRequested>(_onRecurringOrderPause);
    on<RecurringOrderResumeRequested>(_onRecurringOrderResume);
    on<RecurringOrderDeleteRequested>(_onRecurringOrderDelete);
    on<OrdersClearMessage>(_onClearMessage);
    on<OrderTempIdResolved>(_onTempIdResolved);
    on<OcrScanInvoiceRequested>(_onOcrScanInvoice);
    on<OcrScanToOrderRequested>(_onOcrScanToOrder);
    on<OcrScanBatchRequested>(_onOcrScanBatch);
    on<OcrClearResult>(_onOcrClearResult);

    // Listen for sync results that map tempId → realId
    _syncSub = SyncQueueService.instance.syncedItems.listen((items) {
      for (final item in items) {
        if (item.entityType == 'order') {
          add(OrderTempIdResolved(tempId: item.tempId, realId: item.realId));
        }
      }
    });
  }

  final OrderRepository _repository;
  final SearchRepository? _searchRepository;
  StreamSubscription<List<SyncedItem>>? _syncSub;

  @override
  Future<void> close() {
    _syncSub?.cancel();
    return super.close();
  }

  /// IDs بتاع الطلبات اللي اتسلّمت محلياً (عشان الـ list API مش بيحدث الـ status)
  final Set<String> _deliveredOrderIds = {};

  /// صلّح الـ status للطلبات اللي اتسلّمت محلياً بس الـ API لسه بيرجعها بـ status قديم
  List<OrderModel> _fixDeliveredStatuses(List<OrderModel> orders) {
    print('[OrdersBloc] _fixDeliveredStatuses called. deliveredIds=${_deliveredOrderIds.length}: $_deliveredOrderIds');
    if (_deliveredOrderIds.isEmpty) return orders;
    return orders.map((o) {
      if (_deliveredOrderIds.contains(o.id) && o.status != OrderStatus.delivered) {
        print('[OrdersBloc] FIXING order ${o.id} from ${o.status} → delivered');
        return o.copyWith(status: OrderStatus.delivered);
      }
      return o;
    }).toList();
  }

  // ── Clear Message ───────────────────────────────────────────────────

  void _onClearMessage(
    OrdersClearMessage event,
    Emitter<OrdersState> emit,
  ) {
    final current = state;
    if (current is OrdersLoaded) {
      emit(current.copyWith(actionMessage: () => null, isActionError: false));
    }
  }

  // ── Recurring merge helper ──────────────────────────────────────────

  /// Cached recurring orders so they persist across filter/search changes.
  List<OrderModel> _cachedRecurringOrders = [];

  Future<void> _fetchAndCacheRecurring() async {
    try {
      final data = await _repository.getRecurringOrders();
      _cachedRecurringOrders = data
          .map((m) => OrderModel.fromRecurringMap(m))
          .toList();
    } catch (_) {
      // Keep whatever we had cached
    }
  }

  List<OrderModel> _mergeWithRecurring(List<OrderModel> regularOrders) {
    final recurringMap = {
      for (final r in _cachedRecurringOrders) r.id: r,
    };

    // Update existing orders with recurring info
    final updated = regularOrders.map((o) {
      final rec = recurringMap.remove(o.id);
      if (rec != null) {
        return OrderModel(
          id: o.id,
          orderNumber: o.orderNumber,
          customerName: o.customerName,
          customerPhone: o.customerPhone,
          partnerName: o.partnerName,
          partnerColor: o.partnerColor,
          description: o.description,
          amount: o.amount,
          commissionAmount: o.commissionAmount,
          paymentMethod: o.paymentMethod,
          status: o.status,
          priority: o.priority,
          pickupAddress: o.pickupAddress,
          pickupLatitude: o.pickupLatitude,
          pickupLongitude: o.pickupLongitude,
          deliveryAddress: o.deliveryAddress,
          deliveryLatitude: o.deliveryLatitude,
          deliveryLongitude: o.deliveryLongitude,
          distanceKm: o.distanceKm,
          sequenceIndex: o.sequenceIndex,
          worthScore: o.worthScore,
          notes: o.notes,
          itemCount: o.itemCount,
          timeWindowStart: o.timeWindowStart,
          timeWindowEnd: o.timeWindowEnd,
          scheduledDate: o.scheduledDate,
          createdAt: o.createdAt,
          deliveredAt: o.deliveredAt,
          photos: o.photos,
          isRecurring: true,
          recurrencePattern: rec.recurrencePattern,
          isPaused: rec.isPaused,
          nextScheduledDate: rec.nextScheduledDate,
          totalOccurrences: rec.totalOccurrences,
        );
      }
      return o;
    }).toList();

    // Add remaining recurring orders not in regular list
    updated.addAll(recurringMap.values);
    return updated;
  }

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

    // Only show loading spinner if no cached data
    if (!event.refresh && current is! OrdersLoaded) {
      emit(const OrdersLoading());
    }

    try {
      final result = await _repository.getOrders(
        page: 1,
        status: statusFilter,
        searchTerm: searchTerm,
      );

      await _fetchAndCacheRecurring();
      final allOrders = _mergeWithRecurring(
        _fixDeliveredStatuses(result.items),
      );

      emit(OrdersLoaded(
        orders: allOrders,
        statusFilter: statusFilter,
        searchTerm: searchTerm ?? '',
        hasMore: result.hasNextPage,
        currentPage: 1,
      ));
    } on ApiException catch (e) {
      // Keep cached data on failure
      if (current is! OrdersLoaded) {
        emit(OrdersError(e.message));
      }
    } catch (_) {
      if (current is! OrdersLoaded) {
        emit(OrdersError(AppStrings.unknownError));
      }
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
        orders: [...current.orders, ..._fixDeliveredStatuses(result.items)],
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
        orders: _mergeWithRecurring(_fixDeliveredStatuses(result.items)),
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
    final term = event.searchTerm.trim();

    // Empty search → reload all orders
    if (term.isEmpty) {
      add(OrdersLoadRequested(
        statusFilter: current is OrdersLoaded ? current.statusFilter : null,
      ));
      return;
    }

    if (current is! OrdersLoaded) {
      emit(const OrdersLoading());
    } else {
      emit(current.copyWith(searchTerm: term, isLoadingMore: true));
    }

    try {
      if (_searchRepository != null) {
        // Use unified search endpoint
        final result = await _searchRepository.search(query: term);
        switch (result) {
          case ApiSuccess(:final data):
            final orders = data.orders
                .map((o) => OrderModel(
                      id: o.id,
                      orderNumber: o.orderNumber,
                      customerName: o.customerName,
                      customerPhone: o.customerPhone,
                      amount: o.amount,
                      status: OrderStatus.fromValue(o.status),
                      priority: OrderPriority.fromValue(0),
                      paymentMethod: PaymentMethod.fromValue(0),
                      deliveryAddress: o.deliveryAddress ?? '',
                      createdAt: o.createdAt ?? DateTime.now(),
                    ))
                .toList();
            emit(OrdersLoaded(
              orders: orders,
              searchTerm: term,
              hasMore: false,
              currentPage: 1,
            ));
          case ApiFailure(:final error):
            if (current is OrdersLoaded) {
              emit(current.copyWith(searchTerm: term, isLoadingMore: false));
            } else {
              emit(OrdersError(error.arabicMessage));
            }
        }
      } else {
        // Fallback to regular endpoint
        final result = await _repository.getOrders(
          page: 1,
          status: current is OrdersLoaded ? current.statusFilter : null,
          searchTerm: term,
        );
        emit(OrdersLoaded(
          orders: _fixDeliveredStatuses(result.items),
          searchTerm: term,
          hasMore: result.hasNextPage,
          currentPage: 1,
        ));
      }
    } on ApiException {
      if (current is OrdersLoaded) {
        emit(current.copyWith(searchTerm: term, isLoadingMore: false));
      }
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

    emit(loaded.copyWith(isActionInProgress: true, actionMessage: () => null));

    // Offline: enqueue via /sync/push and create an optimistic order
    if (!ConnectivityService.instance.isOnline) {
      final tempId = await SyncQueueService.instance.enqueueCreate(
        entityType: 'order',
        payload: event.data,
      );
      final optimistic = OrderModel(
        id: tempId,
        orderNumber: AppStrings.pendingSync,
        deliveryAddress: event.data['deliveryAddress'] as String? ?? '',
        amount: (event.data['amount'] as num?)?.toDouble() ?? 0,
        paymentMethod: PaymentMethod.fromValue(
          event.data['paymentMethod'] as int? ?? 0,
        ),
        status: OrderStatus.pending,
        priority: OrderPriority.fromValue(
          event.data['priority'] as int? ?? 0,
        ),
        customerName: event.data['customerName'] as String?,
        customerPhone: event.data['customerPhone'] as String?,
        notes: event.data['notes'] as String?,
        pickupAddress: event.data['pickupAddress'] as String?,
        createdAt: DateTime.now(),
      );
      emit(loaded.copyWith(
        orders: [optimistic, ...loaded.orders],
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  // ── TempId resolved (offline order synced) ───────────────────────────

  void _onTempIdResolved(
    OrderTempIdResolved event,
    Emitter<OrdersState> emit,
  ) {
    final current = state;
    if (current is! OrdersLoaded) return;

    final updated = current.orders.map((o) {
      if (o.id != event.tempId) return o;
      return o.copyWith(id: event.realId, orderNumber: '');
    }).toList();

    emit(current.copyWith(
      orders: updated,
      actionMessage: () => AppStrings.orderSyncedSuccess,
    ));
  }

  // ── Create Recurring ─────────────────────────────────────────────────

  Future<void> _onCreateRecurring(
    RecurringOrderCreateRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    final loaded = current is OrdersLoaded
        ? current
        : const OrdersLoaded(orders: [], hasMore: false, currentPage: 1);

    emit(loaded.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      var newOrder = await _repository.createRecurringOrder(event.data);

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
        isActionError: true,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      var order = await _repository.getOrderDetail(event.orderId);

      // Backend may not return customerName/Phone — merge from local list
      final localOrder = current.orders
          .where((o) => o.id == event.orderId)
          .firstOrNull;
      if (localOrder != null) {
        order = OrderModel(
          id: order.id,
          orderNumber: order.orderNumber,
          customerName: order.customerName ?? localOrder.customerName,
          customerPhone: order.customerPhone ?? localOrder.customerPhone,
          partnerName: order.partnerName,
          partnerColor: order.partnerColor,
          description: order.description,
          amount: order.amount,
          commissionAmount: order.commissionAmount,
          paymentMethod: order.paymentMethod,
          status: order.status,
          priority: order.priority,
          pickupAddress: order.pickupAddress,
          pickupLatitude: order.pickupLatitude,
          pickupLongitude: order.pickupLongitude,
          deliveryAddress: order.deliveryAddress,
          deliveryLatitude: order.deliveryLatitude,
          deliveryLongitude: order.deliveryLongitude,
          distanceKm: order.distanceKm,
          sequenceIndex: order.sequenceIndex,
          worthScore: order.worthScore,
          notes: order.notes,
          itemCount: order.itemCount,
          timeWindowStart: order.timeWindowStart,
          timeWindowEnd: order.timeWindowEnd,
          scheduledDate: order.scheduledDate,
          createdAt: order.createdAt,
          deliveredAt: order.deliveredAt,
          photos: order.photos,
          isRecurring: order.isRecurring || localOrder.isRecurring,
          recurrencePattern: localOrder.recurrencePattern ?? order.recurrencePattern,
          isPaused: localOrder.isPaused,
          nextScheduledDate: localOrder.nextScheduledDate ?? order.nextScheduledDate,
          totalOccurrences: localOrder.totalOccurrences ?? order.totalOccurrences,
        );
      }

      // لو الـ API رجع deliveredAt بس الـ status مش delivered — نصلحه محلياً
      if (order.deliveredAt != null && order.status != OrderStatus.delivered) {
        _deliveredOrderIds.add(order.id);
        order = order.copyWith(status: OrderStatus.delivered);
      }

      // حدّث الكارت في الليست كمان عشان يتزامن مع التفاصيل
      final updatedList = current.orders.map((o) {
        return o.id == event.orderId ? order : o;
      }).toList();

      emit(current.copyWith(
        orders: updatedList,
        selectedOrder: () => order,
        isActionInProgress: false,
      ));
    } catch (_) {
      // Offline fallback: use cached order from the list
      final cached = current.orders
          .where((o) => o.id == event.orderId)
          .firstOrNull;
      emit(current.copyWith(
        selectedOrder: () => cached ?? current.selectedOrder,
        isActionInProgress: false,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    if (!ConnectivityService.instance.isOnline) {
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.update,
        orderId: event.orderId,
        payload: event.data,
      );
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    if (!ConnectivityService.instance.isOnline) {
      final payload = {
        'status': event.newStatus,
        if (event.notes != null) 'notes': event.notes,
      };
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.statusChange,
        orderId: event.orderId,
        payload: payload,
      );
      final optimistic = current.orders.map((o) {
        if (o.id != event.orderId) return o;
        return o.copyWith(status: OrderStatus.fromValue(event.newStatus));
      }).toList();
      emit(current.copyWith(
        orders: optimistic,
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    // Offline: queue the action and optimistically update the UI
    if (!ConnectivityService.instance.isOnline) {
      final payload = {
        if (event.actualAmount != null) 'actualCollectedAmount': event.actualAmount,
        if (event.latitude != null) 'latitude': event.latitude,
        if (event.longitude != null) 'longitude': event.longitude,
        if (event.notes != null) 'notes': event.notes,
        if (event.rating != null) 'ratingValue': event.rating,
      };
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.deliver,
        orderId: event.orderId,
        payload: payload,
      );
      _deliveredOrderIds.add(event.orderId);
      final optimistic = current.orders.map((o) {
        if (o.id != event.orderId) return o;
        return o.copyWith(status: OrderStatus.delivered);
      }).toList();
      emit(current.copyWith(
        orders: optimistic,
        selectedOrder: () => current.selectedOrder?.id == event.orderId
            ? current.selectedOrder?.copyWith(status: OrderStatus.delivered)
            : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

    try {
      await _repository.deliverOrder(event.orderId, {
        if (event.actualAmount != null) 'actualCollectedAmount': event.actualAmount,
        if (event.latitude != null) 'latitude': event.latitude,
        if (event.longitude != null) 'longitude': event.longitude,
        if (event.notes != null) 'notes': event.notes,
        if (event.rating != null) 'ratingValue': event.rating,
      });

      var detail = await _repository.getOrderDetail(event.orderId);

      // لو الـ API رجع deliveredAt بس الـ status مش delivered — نصلحه محلياً
      _deliveredOrderIds.add(event.orderId);
      if (detail.status != OrderStatus.delivered) {
        detail = detail.copyWith(status: OrderStatus.delivered);
      }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    // Offline: queue and optimistically update
    if (!ConnectivityService.instance.isOnline) {
      final payload = {
        'reason': event.reason,
        if (event.reasonText != null) 'reasonText': event.reasonText,
      };
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.fail,
        orderId: event.orderId,
        payload: payload,
      );
      final optimistic = current.orders.map((o) {
        if (o.id != event.orderId) return o;
        return o.copyWith(status: OrderStatus.failed);
      }).toList();
      emit(current.copyWith(
        orders: optimistic,
        selectedOrder: () => current.selectedOrder?.id == event.orderId
            ? current.selectedOrder?.copyWith(status: OrderStatus.failed)
            : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    // Offline: queue and optimistically update
    if (!ConnectivityService.instance.isOnline) {
      final payload = {
        'cancellationReason': event.reason,
        if (event.reasonText != null) 'reasonText': event.reasonText,
        if (event.lossAmount != null) 'lossAmount': event.lossAmount,
      };
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.cancel,
        orderId: event.orderId,
        payload: payload,
      );
      final optimistic = current.orders.map((o) {
        if (o.id != event.orderId) return o;
        return o.copyWith(status: OrderStatus.cancelled);
      }).toList();
      emit(current.copyWith(
        orders: optimistic,
        selectedOrder: () => current.selectedOrder?.id == event.orderId
            ? current.selectedOrder?.copyWith(status: OrderStatus.cancelled)
            : current.selectedOrder,
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    if (!ConnectivityService.instance.isOnline) {
      final payload = {
        'newDeliveryAddress': event.newAddress,
        if (event.reason != null) 'reason': event.reason,
      };
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.swapAddress,
        orderId: event.orderId,
        payload: payload,
      );
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    if (!ConnectivityService.instance.isOnline) {
      final payload = {
        'targetDriverId': event.targetDriverId,
        if (event.reason != null) 'reason': event.reason,
      };
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.transfer,
        orderId: event.orderId,
        payload: payload,
      );
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

    try {
      await _repository.transferOrder(event.orderId, {
        'toDriverId': event.targetDriverId,
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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    if (!ConnectivityService.instance.isOnline) {
      final payload = {
        'deliveredItemCount': event.deliveredItemCount,
        'totalItemCount': event.totalItemCount,
        'collectedAmount': event.collectedAmount,
        'remainingAmount': event.remainingAmount,
        if (event.reason != null) 'reason': event.reason,
      };
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.partial,
        orderId: event.orderId,
        payload: payload,
      );
      final optimistic = current.orders.map((o) {
        if (o.id != event.orderId) return o;
        return o.copyWith(status: OrderStatus.partiallyDelivered);
      }).toList();
      emit(current.copyWith(
        orders: optimistic,
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    if (!ConnectivityService.instance.isOnline) {
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.waitingStart,
        orderId: event.orderId,
        payload: const {},
      );
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    if (!ConnectivityService.instance.isOnline) {
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.waitingStop,
        orderId: event.orderId,
        payload: const {},
      );
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.savedOffline,
      ));
      return;
    }

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(loaded.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

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
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
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

    emit(loaded.copyWith(isActionInProgress: true, actionMessage: () => null));

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

  // ── Recurring Orders ────────────────────────────────────────────────

  Future<void> _onRecurringOrdersLoad(
    RecurringOrdersLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    final loaded = current is OrdersLoaded
        ? current
        : const OrdersLoaded(orders: [], hasMore: false, currentPage: 1);

    emit(loaded.copyWith(isRecurringLoading: true));

    try {
      await _fetchAndCacheRecurring();
      final nonRecurringOrders =
          loaded.orders.where((o) => !o.isRecurring).toList();
      final mergedOrders = _mergeWithRecurring(nonRecurringOrders);

      emit(loaded.copyWith(
        isRecurringLoading: false,
        orders: mergedOrders,
      ));
    } on ApiException catch (e) {
      emit(loaded.copyWith(
        isRecurringLoading: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(loaded.copyWith(
        isRecurringLoading: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  Future<void> _onRecurringOrderPause(
    RecurringOrderPauseRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      await _repository.pauseRecurringOrder(event.orderId);

      // Update isPaused in cache and orders list
      _cachedRecurringOrders = _cachedRecurringOrders.map((o) {
        if (o.id == event.orderId) return o.copyWith(isPaused: true);
        return o;
      }).toList();
      final updatedOrders = current.orders.map((o) {
        if (o.id == event.orderId) return o.copyWith(isPaused: true);
        return o;
      }).toList();

      final updatedSelected = current.selectedOrder?.id == event.orderId
          ? current.selectedOrder?.copyWith(isPaused: true)
          : current.selectedOrder;

      emit(current.copyWith(
        isActionInProgress: false,
        orders: updatedOrders,
        selectedOrder: () => updatedSelected,
        actionMessage: () => AppStrings.recurringPaused,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  Future<void> _onRecurringOrderResume(
    RecurringOrderResumeRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      await _repository.resumeRecurringOrder(event.orderId);

      _cachedRecurringOrders = _cachedRecurringOrders.map((o) {
        if (o.id == event.orderId) return o.copyWith(isPaused: false);
        return o;
      }).toList();
      final updatedOrders = current.orders.map((o) {
        if (o.id == event.orderId) return o.copyWith(isPaused: false);
        return o;
      }).toList();

      final updatedSelected = current.selectedOrder?.id == event.orderId
          ? current.selectedOrder?.copyWith(isPaused: false)
          : current.selectedOrder;

      emit(current.copyWith(
        isActionInProgress: false,
        orders: updatedOrders,
        selectedOrder: () => updatedSelected,
        actionMessage: () => AppStrings.recurringResumed,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  Future<void> _onRecurringOrderDelete(
    RecurringOrderDeleteRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isActionInProgress: true, actionMessage: () => null));

    try {
      await _repository.deleteRecurringOrder(event.orderId);

      _cachedRecurringOrders = _cachedRecurringOrders
          .where((o) => o.id != event.orderId)
          .toList();
      final updatedOrders = current.orders
          .where((o) => o.id != event.orderId)
          .toList();

      emit(current.copyWith(
        isActionInProgress: false,
        orders: updatedOrders,
        actionMessage: () => AppStrings.recurringDeleted,
        isActionError: false,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (_) {
      emit(current.copyWith(
        isActionInProgress: false,
        actionMessage: () => AppStrings.unknownError,
        isActionError: true,
      ));
    }
  }

  // ── Hydration ──────────────────────────────────────────────────────

  @override
  OrdersState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        final orders = (json['orders'] as List<dynamic>)
            .map((o) => OrderModel.fromJson(
                  Map<String, dynamic>.from(o as Map),
                ))
            .toList();

        // Restore delivered IDs from cache
        final savedDeliveredIds =
            (json['deliveredOrderIds'] as List<dynamic>?)
                ?.cast<String>() ?? [];
        _deliveredOrderIds.addAll(savedDeliveredIds);
        print('[OrdersBloc] fromJson: restored ${savedDeliveredIds.length} deliveredIds: $savedDeliveredIds');

        return OrdersLoaded(
          orders: _fixDeliveredStatuses(orders),
          hasMore: json['hasMore'] as bool? ?? false,
          currentPage: json['currentPage'] as int? ?? 1,
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(OrdersState state) {
    if (state is OrdersLoaded) {
      return {
        'type': 'loaded',
        'orders': state.orders.map((o) => o.toJson()).toList(),
        'hasMore': state.hasMore,
        'currentPage': state.currentPage,
        'deliveredOrderIds': _deliveredOrderIds.toList(),
      };
    }
    return null;
  }

  // ── OCR Handlers ──

  Future<void> _onOcrScanInvoice(
    OcrScanInvoiceRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isOcrScanning: true));

    try {
      final result = await _repository.scanInvoice(event.imageFile);
      emit(current.copyWith(
        isOcrScanning: false,
        ocrResult: () => result,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isOcrScanning: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (e) {
      emit(current.copyWith(
        isOcrScanning: false,
        actionMessage: () => e.toString(),
        isActionError: true,
      ));
    }
  }

  Future<void> _onOcrScanToOrder(
    OcrScanToOrderRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isOcrScanning: true));

    try {
      final order = await _repository.scanToOrder(event.imageFile);
      emit(current.copyWith(
        isOcrScanning: false,
        ocrCreatedOrder: () => order,
        orders: [order, ...current.orders],
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isOcrScanning: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (e) {
      emit(current.copyWith(
        isOcrScanning: false,
        actionMessage: () => e.toString(),
        isActionError: true,
      ));
    }
  }

  Future<void> _onOcrScanBatch(
    OcrScanBatchRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(isOcrScanning: true));

    try {
      final batchResult = await _repository.scanBatch(event.imageFiles);
      emit(current.copyWith(
        isOcrScanning: false,
        ocrBatchResult: () => batchResult,
      ));
    } on ApiException catch (e) {
      emit(current.copyWith(
        isOcrScanning: false,
        actionMessage: () => e.message,
        isActionError: true,
      ));
    } catch (e) {
      emit(current.copyWith(
        isOcrScanning: false,
        actionMessage: () => e.toString(),
        isActionError: true,
      ));
    }
  }

  void _onOcrClearResult(
    OcrClearResult event,
    Emitter<OrdersState> emit,
  ) {
    final current = state;
    if (current is! OrdersLoaded) return;

    emit(current.copyWith(
      ocrResult: () => null,
      ocrBatchResult: () => null,
      ocrCreatedOrder: () => null,
    ));
  }
}
