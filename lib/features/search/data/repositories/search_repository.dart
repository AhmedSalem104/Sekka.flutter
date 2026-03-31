import 'package:dio/dio.dart';

import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_result.dart';
import '../models/search_result_model.dart';

class SearchRepository {
  SearchRepository(this._dio);
  final Dio _dio;

  /// GET /api/v1/search?q={query}&limit={limit}
  Future<ApiResult<SearchResultModel>> search({
    required String query,
    int limit = 10,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.search,
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      ),
      parser: (data) =>
          SearchResultModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
