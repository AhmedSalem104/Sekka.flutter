import 'package:dio/dio.dart';
import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/api_result.dart';
import '../models/notification_model.dart';

class NotificationRepository {
    NotificationRepository(this._dio);
  final Dio _dio;

  /// GET /notifications?page=&pageSize=
  Future<ApiResult<PagedData<NotificationModel>>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.notifications,
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
      () => _dio.put(ApiConstants.notificationRead(id), data: {}),
      parser: (data) => data == true,
    );
  }

  /// PUT /notifications/read-all
  Future<ApiResult<bool>> markAllAsRead() async {
    return ApiHelper.execute(
      () => _dio.put(ApiConstants.notificationsReadAll, data: {}),
      parser: (data) => data == true,
    );
  }

  /// GET /notifications/unread-count
  Future<ApiResult<int>> getUnreadCount() async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.notificationsUnreadCount),
      parser: (data) => (data as num?)?.toInt() ?? 0,
    );
  }
}
