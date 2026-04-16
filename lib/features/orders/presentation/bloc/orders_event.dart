import 'dart:io';

import 'package:equatable/equatable.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

final class OrdersLoadRequested extends OrdersEvent {
  const OrdersLoadRequested({
    this.statusFilter,
    this.searchTerm,
    this.dateFrom,
    this.dateTo,
    this.refresh = false,
  });

  final int? statusFilter;
  final String? searchTerm;
  final String? dateFrom;
  final String? dateTo;
  final bool refresh;

  @override
  List<Object?> get props =>
      [statusFilter, searchTerm, dateFrom, dateTo, refresh];
}

final class OrdersLoadMore extends OrdersEvent {
  const OrdersLoadMore();
}

final class OrdersFilterChanged extends OrdersEvent {
  const OrdersFilterChanged({
    this.status,
    this.dateFrom,
    this.dateTo,
    this.clearDate = false,
  });

  final int? status;
  final String? dateFrom;
  final String? dateTo;

  /// Explicitly clear the currently-selected date filter.
  final bool clearDate;

  @override
  List<Object?> get props => [status, dateFrom, dateTo, clearDate];
}

final class OrdersSearchChanged extends OrdersEvent {
  const OrdersSearchChanged({required this.searchTerm});

  final String searchTerm;

  @override
  List<Object?> get props => [searchTerm];
}

final class OrderCreateRequested extends OrdersEvent {
  const OrderCreateRequested({required this.data});

  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

final class RecurringOrderCreateRequested extends OrdersEvent {
  const RecurringOrderCreateRequested({required this.data});

  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

final class OrderDetailLoadRequested extends OrdersEvent {
  const OrderDetailLoadRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class OrderUpdateRequested extends OrdersEvent {
  const OrderUpdateRequested({
    required this.orderId,
    required this.data,
  });

  final String orderId;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [orderId, data];
}

final class OrderDeleteRequested extends OrdersEvent {
  const OrderDeleteRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class OrderStatusChangeRequested extends OrdersEvent {
  const OrderStatusChangeRequested({
    required this.orderId,
    required this.newStatus,
    this.notes,
  });

  final String orderId;
  final int newStatus;
  final String? notes;

  @override
  List<Object?> get props => [orderId, newStatus, notes];
}

final class OrderDeliverRequested extends OrdersEvent {
  const OrderDeliverRequested({
    required this.orderId,
    this.actualAmount,
    this.latitude,
    this.longitude,
    this.notes,
    this.rating,
  });

  final String orderId;
  final double? actualAmount;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final int? rating;

  @override
  List<Object?> get props => [orderId, actualAmount, latitude, longitude, notes, rating];
}

final class OrderFailRequested extends OrdersEvent {
  const OrderFailRequested({
    required this.orderId,
    required this.reason,
    this.reasonText,
  });

  final String orderId;
  final int reason;
  final String? reasonText;

  @override
  List<Object?> get props => [orderId, reason, reasonText];
}

final class OrderCancelRequested extends OrdersEvent {
  const OrderCancelRequested({
    required this.orderId,
    required this.reason,
    this.reasonText,
    this.lossAmount,
  });

  final String orderId;
  final int reason;
  final String? reasonText;
  final double? lossAmount;

  @override
  List<Object?> get props => [orderId, reason, reasonText, lossAmount];
}

final class OrderPhotoUploadRequested extends OrdersEvent {
  const OrderPhotoUploadRequested({
    required this.orderId,
    required this.imageFile,
    required this.photoType,
  });

  final String orderId;
  final File imageFile;
  final int photoType;

  @override
  List<Object?> get props => [orderId, imageFile, photoType];
}

final class OrderSwapAddressRequested extends OrdersEvent {
  const OrderSwapAddressRequested({
    required this.orderId,
    required this.newAddress,
    this.reason,
  });

  final String orderId;
  final String newAddress;
  final String? reason;

  @override
  List<Object?> get props => [orderId, newAddress, reason];
}

final class OrderBulkImportRequested extends OrdersEvent {
  const OrderBulkImportRequested({
    required this.text,
    this.defaultPaymentMethod,
    this.partnerId,
  });

  final String text;
  final int? defaultPaymentMethod;
  final String? partnerId;

  @override
  List<Object?> get props => [text, defaultPaymentMethod, partnerId];
}

final class OrderTransferRequested extends OrdersEvent {
  const OrderTransferRequested({
    required this.orderId,
    required this.targetDriverId,
    this.reason,
  });

  final String orderId;
  final String targetDriverId;
  final String? reason;

  @override
  List<Object?> get props => [orderId, targetDriverId, reason];
}

final class OrderPartialDeliveryRequested extends OrdersEvent {
  const OrderPartialDeliveryRequested({
    required this.orderId,
    required this.deliveredItemCount,
    required this.totalItemCount,
    required this.collectedAmount,
    required this.remainingAmount,
    this.reason,
  });

  final String orderId;
  final int deliveredItemCount;
  final int totalItemCount;
  final double collectedAmount;
  final double remainingAmount;
  final String? reason;

  @override
  List<Object?> get props => [
        orderId,
        deliveredItemCount,
        totalItemCount,
        collectedAmount,
        remainingAmount,
        reason,
      ];
}

final class OrderWaitingStartRequested extends OrdersEvent {
  const OrderWaitingStartRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class OrderWaitingStopRequested extends OrdersEvent {
  const OrderWaitingStopRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class OrderDisclaimerPostRequested extends OrdersEvent {
  const OrderDisclaimerPostRequested({
    required this.orderId,
    required this.data,
  });

  final String orderId;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [orderId, data];
}

final class OrderDisclaimerLoadRequested extends OrdersEvent {
  const OrderDisclaimerLoadRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class OrderDisputeRequested extends OrdersEvent {
  const OrderDisputeRequested({
    required this.orderId,
    required this.data,
  });

  final String orderId;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [orderId, data];
}

final class OrderDisputesLoadRequested extends OrdersEvent {
  const OrderDisputesLoadRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class OrderRefundRequested extends OrdersEvent {
  const OrderRefundRequested({
    required this.orderId,
    required this.data,
  });

  final String orderId;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [orderId, data];
}

final class OrderRefundsLoadRequested extends OrdersEvent {
  const OrderRefundsLoadRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class OrderTimeSlotsLoadRequested extends OrdersEvent {
  const OrderTimeSlotsLoadRequested();
}

final class OrderBookSlotRequested extends OrdersEvent {
  const OrderBookSlotRequested({
    required this.orderId,
    required this.data,
  });

  final String orderId;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [orderId, data];
}

final class OrderCalculatePriceRequested extends OrdersEvent {
  const OrderCalculatePriceRequested({required this.data});

  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

final class OrdersClearMessage extends OrdersEvent {
  const OrdersClearMessage();
}

final class RecurringOrdersLoadRequested extends OrdersEvent {
  const RecurringOrdersLoadRequested();
}

final class RecurringOrderPauseRequested extends OrdersEvent {
  const RecurringOrderPauseRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class RecurringOrderResumeRequested extends OrdersEvent {
  const RecurringOrderResumeRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class RecurringOrderDeleteRequested extends OrdersEvent {
  const RecurringOrderDeleteRequested({required this.orderId});

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

final class OrderCheckDuplicateRequested extends OrdersEvent {
  const OrderCheckDuplicateRequested({required this.data});

  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

/// Fired by [SyncQueueService] after a successful push resolves a temp order.
final class OrderTempIdResolved extends OrdersEvent {
  const OrderTempIdResolved({required this.tempId, required this.realId});

  final String tempId;
  final String realId;

  @override
  List<Object?> get props => [tempId, realId];
}

// ── OCR Events ──

final class OcrScanInvoiceRequested extends OrdersEvent {
  const OcrScanInvoiceRequested({required this.imageFile});

  final File imageFile;

  @override
  List<Object?> get props => [imageFile];
}

final class OcrScanToOrderRequested extends OrdersEvent {
  const OcrScanToOrderRequested({required this.imageFile});

  final File imageFile;

  @override
  List<Object?> get props => [imageFile];
}

final class OcrScanBatchRequested extends OrdersEvent {
  const OcrScanBatchRequested({required this.imageFiles});

  final List<File> imageFiles;

  @override
  List<Object?> get props => [imageFiles];
}

final class OcrClearResult extends OrdersEvent {
  const OcrClearResult();
}
