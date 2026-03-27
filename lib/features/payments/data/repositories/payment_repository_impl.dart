import 'dart:io';

import '../../../../shared/network/paginated_response.dart';
import '../../domain/entities/payment_request_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({
    required PaymentRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final PaymentRemoteDataSource _remote;

  @override
  Future<PaginatedResponse<PaymentRequestEntity>> getPaymentRequests({
    int pageNumber = 1,
    int pageSize = 20,
    int? status,
  }) =>
      _remote.getPaymentRequests(
        pageNumber: pageNumber,
        pageSize: pageSize,
        status: status,
      );

  @override
  Future<PaymentRequestEntity> getPaymentRequestDetail(String id) =>
      _remote.getPaymentRequestDetail(id);

  @override
  Future<PaymentRequestEntity> createPaymentRequest({
    required String planId,
    required int paymentMethod,
    String? senderPhone,
    String? senderName,
    String? notes,
  }) =>
      _remote.createPaymentRequest(
        planId: planId,
        paymentMethod: paymentMethod,
        senderPhone: senderPhone,
        senderName: senderName,
        notes: notes,
      );

  @override
  Future<void> uploadProof(String requestId, File file) =>
      _remote.uploadProof(requestId, file);

  @override
  Future<void> cancelPaymentRequest(String id) =>
      _remote.cancelPaymentRequest(id);
}
