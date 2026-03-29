import 'package:dio/dio.dart';
import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/api_result.dart';
import '../models/create_rating_model.dart';
import '../models/customer_detail_model.dart';
import '../models/customer_engagement_model.dart';
import '../models/customer_interests_model.dart';
import '../models/customer_model.dart';
import '../models/customer_order_model.dart';

class CustomerRepository {
    CustomerRepository(this._dio);
  final Dio _dio;

  /// GET /api/v1/customers
  Future<ApiResult<PagedData<CustomerModel>>> getCustomers({
    String? searchTerm,
    bool? isBlocked,
    double? minRating,
    String? sortBy,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.customers,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          if (searchTerm != null) 'searchTerm': searchTerm,
          if (isBlocked != null) 'isBlocked': isBlocked,
          if (minRating != null) 'minRating': minRating,
          if (sortBy != null) 'sortBy': sortBy,
        },
      ),
      parser: (data) => PagedData.fromJson(
        data as Map<String, dynamic>,
        CustomerModel.fromJson,
      ),
    );
  }

  /// GET /api/v1/customers/{id}
  Future<ApiResult<CustomerDetailModel>> getCustomer(String id) async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.customerDetail(id)),
      parser: (data) =>
          CustomerDetailModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /api/v1/customers/by-phone/{phone}
  Future<ApiResult<CustomerModel>> findByPhone(String phone) async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.customerByPhone(phone)),
      parser: (data) =>
          CustomerModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PUT /api/v1/customers/{id}
  Future<ApiResult<CustomerModel>> updateCustomer(
    String id, {
    String? name,
    String? notes,
    int? preferredPaymentMethod,
  }) async {
    return ApiHelper.execute(
      () => _dio.put(
        ApiConstants.customerDetail(id),
        data: {
          if (name != null) 'name': name,
          if (notes != null) 'notes': notes,
          if (preferredPaymentMethod != null)
            'preferredPaymentMethod': preferredPaymentMethod,
        },
      ),
      parser: (data) =>
          CustomerModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// POST /api/v1/customers/{id}/rate
  Future<ApiResult<bool>> rateCustomer(
    String id, {
    required CreateRatingModel rating,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(
        ApiConstants.customerRate(id),
        data: rating.toJson(),
      ),
      parser: (data) => data == true,
    );
  }

  /// POST /api/v1/customers/{id}/block
  Future<ApiResult<bool>> blockCustomer(
    String id, {
    required String reason,
    bool reportToCommunity = false,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(
        ApiConstants.customerBlock(id),
        data: {
          'reason': reason,
          'reportToCommunity': reportToCommunity,
        },
      ),
      parser: (data) => data == true,
    );
  }

  /// POST /api/v1/customers/{id}/unblock
  Future<ApiResult<bool>> unblockCustomer(String id) async {
    return ApiHelper.execute(
      () => _dio.post(ApiConstants.customerUnblock(id), data: {}),
      parser: (data) => data == true,
    );
  }

  /// GET /api/v1/customers/{id}/orders
  Future<ApiResult<PagedData<CustomerOrderModel>>> getCustomerOrders(
    String id, {
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.customerOrders(id),
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      ),
      parser: (data) => PagedData.fromJson(
        data as Map<String, dynamic>,
        CustomerOrderModel.fromJson,
      ),
    );
  }

  /// GET /api/v1/customers/{id}/interests
  Future<ApiResult<CustomerInterestsModel>> getInterests(String id) async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.customerInterests(id)),
      parser: (data) =>
          CustomerInterestsModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /api/v1/customers/{id}/engagement
  Future<ApiResult<CustomerEngagementModel>> getEngagement(String id) async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.customerEngagement(id)),
      parser: (data) =>
          CustomerEngagementModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
