import 'dart:io';

import '../../data/models/order_model.dart';
import '../../../../shared/network/api_response.dart';

abstract class OrderRepository {
  Future<OrderModel> createOrder(Map<String, dynamic> data);
  Future<OrderModel> createRecurringOrder(Map<String, dynamic> data);

  Future<PagedData<OrderModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    int? status,
    String? partnerId,
    String? dateFrom,
    String? dateTo,
    String? searchTerm,
    int? paymentMethod,
    int? priority,
  });

  Future<OrderModel> getOrderDetail(String id);

  Future<OrderModel> updateOrder(String id, Map<String, dynamic> data);

  Future<void> deleteOrder(String id);

  Future<Map<String, dynamic>> updateOrderStatus(
    String id,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> deliverOrder(
    String id,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> failOrder(
    String id,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> cancelOrder(
    String id,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> transferOrder(
    String id,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> partialDelivery(
    String id,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> bulkImport(Map<String, dynamic> data);

  Future<Map<String, dynamic>> uploadPhoto(
    String id,
    File imageFile,
    int photoType, {
    String? description,
  });

  Future<Map<String, dynamic>> swapAddress(
    String id,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> startWaitingTimer(
    String id, {
    double? latitude,
    double? longitude,
  });

  Future<Map<String, dynamic>> stopWaitingTimer(String id);

  Future<Map<String, dynamic>> calculatePrice(Map<String, dynamic> data);

  Future<Map<String, dynamic>> checkDuplicate(Map<String, dynamic> data);

  Future<Map<String, dynamic>> calculateWorth(String id);

  Future<Map<String, dynamic>> postDisclaimer(
    String id,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> getDisclaimer(String id);

  Future<Map<String, dynamic>> postDispute(
    String id,
    Map<String, dynamic> data,
  );

  Future<List<dynamic>> getDisputes(String id);

  Future<Map<String, dynamic>> postRefund(
    String id,
    Map<String, dynamic> data,
  );

  Future<List<dynamic>> getRefunds(String id);

  Future<List<dynamic>> getTimeSlots();

  Future<Map<String, dynamic>> bookSlot(
    String id,
    Map<String, dynamic> data,
  );
}
