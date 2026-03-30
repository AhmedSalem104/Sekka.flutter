import 'dart:io';

import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';
import '../../../../shared/network/api_response.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final OrderRemoteDataSource _remote;

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> data) =>
      _remote.createOrder(data);

  @override
  Future<OrderModel> createRecurringOrder(Map<String, dynamic> data) =>
      _remote.createRecurringOrder(data);

  @override
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
  }) =>
      _remote.getOrders(
        page: page,
        pageSize: pageSize,
        status: status,
        partnerId: partnerId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        searchTerm: searchTerm,
        paymentMethod: paymentMethod,
        priority: priority,
      );

  @override
  Future<OrderModel> getOrderDetail(String id) =>
      _remote.getOrderDetail(id);

  @override
  Future<OrderModel> updateOrder(String id, Map<String, dynamic> data) =>
      _remote.updateOrder(id, data);

  @override
  Future<void> deleteOrder(String id) => _remote.deleteOrder(id);

  @override
  Future<Map<String, dynamic>> updateOrderStatus(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.updateOrderStatus(id, data);

  @override
  Future<Map<String, dynamic>> deliverOrder(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.deliverOrder(id, data);

  @override
  Future<Map<String, dynamic>> failOrder(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.failOrder(id, data);

  @override
  Future<Map<String, dynamic>> cancelOrder(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.cancelOrder(id, data);

  @override
  Future<Map<String, dynamic>> transferOrder(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.transferOrder(id, data);

  @override
  Future<Map<String, dynamic>> partialDelivery(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.partialDelivery(id, data);

  @override
  Future<Map<String, dynamic>> bulkImport(Map<String, dynamic> data) =>
      _remote.bulkImport(data);

  @override
  Future<Map<String, dynamic>> uploadPhoto(
    String id,
    File imageFile,
    int photoType, {
    String? description,
  }) =>
      _remote.uploadPhoto(id, imageFile, photoType, description: description);

  @override
  Future<Map<String, dynamic>> swapAddress(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.swapAddress(id, data);

  @override
  Future<Map<String, dynamic>> startWaitingTimer(
    String id, {
    double? latitude,
    double? longitude,
  }) =>
      _remote.startWaitingTimer(id, latitude: latitude, longitude: longitude);

  @override
  Future<Map<String, dynamic>> stopWaitingTimer(String id) =>
      _remote.stopWaitingTimer(id);

  @override
  Future<Map<String, dynamic>> calculatePrice(Map<String, dynamic> data) =>
      _remote.calculatePrice(data);

  @override
  Future<Map<String, dynamic>> checkDuplicate(Map<String, dynamic> data) =>
      _remote.checkDuplicate(data);

  @override
  Future<Map<String, dynamic>> calculateWorth(String id) =>
      _remote.calculateWorth(id);

  @override
  Future<Map<String, dynamic>> postDisclaimer(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.postDisclaimer(id, data);

  @override
  Future<Map<String, dynamic>> getDisclaimer(String id) =>
      _remote.getDisclaimer(id);

  @override
  Future<Map<String, dynamic>> postDispute(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.postDispute(id, data);

  @override
  Future<List<dynamic>> getDisputes(String id) => _remote.getDisputes(id);

  @override
  Future<Map<String, dynamic>> postRefund(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.postRefund(id, data);

  @override
  Future<List<dynamic>> getRefunds(String id) => _remote.getRefunds(id);

  @override
  Future<List<dynamic>> getTimeSlots() => _remote.getTimeSlots();

  @override
  Future<Map<String, dynamic>> bookSlot(
    String id,
    Map<String, dynamic> data,
  ) =>
      _remote.bookSlot(id, data);
}
