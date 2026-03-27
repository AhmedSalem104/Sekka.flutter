import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/api_result.dart';
import '../models/message_template_model.dart';

class MessageTemplateRepository {
  final _dio = ApiClient.instance.dio;

  /// GET /message-templates
  Future<ApiResult<List<MessageTemplateModel>>> getTemplates() async {
    return ApiHelper.execute(
      () => _dio.get('/api/v1/message-templates'),
      parser: (data) => (data as List<dynamic>)
          .map((e) => MessageTemplateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// POST /message-templates
  Future<ApiResult<MessageTemplateModel>> create({
    required String messageText,
    required int category,
  }) async {
    return ApiHelper.execute(
      () => _dio.post('/api/v1/message-templates', data: {
        'messageText': messageText,
        'category': category,
      }),
      parser: (data) =>
          MessageTemplateModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PUT /message-templates/{id}
  Future<ApiResult<MessageTemplateModel>> update(
    String id, {
    String? messageText,
    int? category,
    int? sortOrder,
  }) async {
    return ApiHelper.execute(
      () => _dio.put('/api/v1/message-templates/$id', data: {
        if (messageText != null) 'messageText': messageText,
        if (category != null) 'category': category,
        if (sortOrder != null) 'sortOrder': sortOrder,
      }),
      parser: (data) =>
          MessageTemplateModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// DELETE /message-templates/{id}
  Future<ApiResult<bool>> delete(String id) async {
    return ApiHelper.execute(
      () => _dio.delete('/api/v1/message-templates/$id'),
      parser: (data) => data as bool,
    );
  }

  /// POST /message-templates/{id}/use
  Future<ApiResult<bool>> recordUsage(String id) async {
    return ApiHelper.execute(
      () => _dio.post('/api/v1/message-templates/$id/use'),
      parser: (data) => data as bool,
    );
  }
}
