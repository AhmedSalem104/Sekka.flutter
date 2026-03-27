import 'dart:io';

import '../../../../shared/network/paginated_response.dart';
import '../entities/payment_request_entity.dart';

abstract class PaymentRepository {
  Future<PaginatedResponse<PaymentRequestEntity>> getPaymentRequests({
    int pageNumber = 1,
    int pageSize = 20,
    int? status,
  });

  Future<PaymentRequestEntity> getPaymentRequestDetail(String id);

  Future<PaymentRequestEntity> createPaymentRequest({
    required String planId,
    required int paymentMethod,
    String? senderPhone,
    String? senderName,
    String? notes,
  });

  Future<void> uploadProof(String requestId, File file);

  Future<void> cancelPaymentRequest(String id);
}
