import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/api_result.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final _dio = ApiClient.instance.dio;

  /// GET /notifications?page=&pageSize=
  Future<ApiResult<PagedData<NotificationModel>>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        '/api/v1/notifications',
        queryParameters: {'page': page, 'pageSize': pageSize},
      ),
      parser: (data) => PagedData.fromJson(
        data as Map<String, dynamic>,
        NotificationModel.fromJson,
      ),
    );
  }

  /// PUT /notifications/{id}/read
  Future<ApiResult<bool>> markAsRead(String id) async {
    return ApiHelper.execute(
      () => _dio.put('/api/v1/notifications/$id/read'),
      parser: (data) => data as bool,
    );
  }

  /// PUT /notifications/read-all
  Future<ApiResult<bool>> markAllAsRead() async {
    return ApiHelper.execute(
      () => _dio.put('/api/v1/notifications/read-all'),
      parser: (data) => data as bool,
    );
  }

  /// GET /notifications/unread-count
  Future<ApiResult<int>> getUnreadCount() async {
    return ApiHelper.execute(
      () => _dio.get('/api/v1/notifications/unread-count'),
      parser: (data) => data as int,
    );
  }
}
