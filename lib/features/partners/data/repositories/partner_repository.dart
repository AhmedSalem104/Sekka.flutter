import 'package:dio/dio.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/api_result.dart';
import '../models/create_partner_model.dart';
import '../models/partner_model.dart';
import '../models/partner_order_model.dart';
import '../models/pickup_point_model.dart';
import '../models/verification_status_model.dart';

class PartnerRepository {
    PartnerRepository(this._dio);
  final Dio _dio;

  /// GET /api/v1/partners
  Future<ApiResult<List<PartnerModel>>> getPartners({
    String? searchTerm,
    int? partnerType,
    bool? isActive,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        '/partners',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (searchTerm != null) 'searchTerm': searchTerm,
          if (partnerType != null) 'partnerType': partnerType,
          if (isActive != null) 'isActive': isActive,
        },
      ),
      parser: (data) => (data as List<dynamic>)
          .map((e) => PartnerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// POST /api/v1/partners
  Future<ApiResult<PartnerModel>> createPartner({
    required CreatePartnerModel data,
  }) async {
    return ApiHelper.execute(
      () => _dio.post('/partners', data: data.toJson()),
      parser: (data) => PartnerModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PUT /api/v1/partners/{id}
  Future<ApiResult<PartnerModel>> updatePartner(
    String id, {
    String? name,
    String? phone,
    String? address,
    int? commissionType,
    double? commissionValue,
    String? color,
  }) async {
    return ApiHelper.execute(
      () => _dio.put(
        '/partners/$id',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
          if (commissionType != null) 'commissionType': commissionType,
          if (commissionValue != null) 'commissionValue': commissionValue,
          if (color != null) 'color': color,
        },
      ),
      parser: (data) => PartnerModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// DELETE /api/v1/partners/{id}
  Future<ApiResult<bool>> deletePartner(String id) async {
    return ApiHelper.execute(
      () => _dio.delete('/partners/$id'),
      parser: (data) => data as bool,
    );
  }

  /// GET /api/v1/partners/{id}/orders
  Future<ApiResult<PagedData<PartnerOrderModel>>> getPartnerOrders(
    String id, {
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        '/partners/$id/orders',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      ),
      parser: (data) => PagedData.fromJson(
        data as Map<String, dynamic>,
        PartnerOrderModel.fromJson,
      ),
    );
  }

  /// GET /api/v1/partners/{id}/pickup-points
  Future<ApiResult<List<PickupPointModel>>> getPickupPoints(
    String id,
  ) async {
    return ApiHelper.execute(
      () => _dio.get('/partners/$id/pickup-points'),
      parser: (data) => (data as List<dynamic>)
          .map((e) => PickupPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// POST /api/v1/partners/{id}/submit-verification
  Future<ApiResult<Map<String, dynamic>>> submitVerification(
    String id, {
    required String filePath,
    String? documentType,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(
        '/partners/$id/submit-verification',
        data: FormData.fromMap({
          'file': MultipartFile.fromFileSync(filePath),
          if (documentType != null) 'documentType': documentType,
        }),
      ),
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// GET /api/v1/partners/{id}/verification-status
  Future<ApiResult<VerificationStatusModel>> getVerificationStatus(
    String id,
  ) async {
    return ApiHelper.execute(
      () => _dio.get('/partners/$id/verification-status'),
      parser: (data) => VerificationStatusModel.fromJson(
        data as Map<String, dynamic>,
      ),
    );
  }
}
