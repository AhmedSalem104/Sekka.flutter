import 'package:dio/dio.dart';
import '../../../../shared/network/api_constants.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/api_result.dart';
import '../models/conversation_model.dart';

class ChatRepository {
    ChatRepository(this._dio);
  final Dio _dio;

  /// GET /chat/conversations?page=&pageSize=
  Future<ApiResult<PagedData<ConversationModel>>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.chatConversations,
        queryParameters: {'page': page, 'pageSize': pageSize},
      ),
      parser: (data) => PagedData.fromJson(
        data as Map<String, dynamic>,
        ConversationModel.fromJson,
      ),
    );
  }

  /// POST /chat/conversations
  Future<ApiResult<ConversationModel>> createConversation({
    required int chatType,
    String? subject,
    required String initialMessage,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(ApiConstants.chatConversations, data: {
        'chatType': chatType,
        if (subject != null) 'subject': subject,
        'initialMessage': initialMessage,
      }),
      parser: (data) =>
          ConversationModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// GET /chat/conversations/{id}/messages?page=&pageSize=
  Future<ApiResult<PagedData<ChatMessageModel>>> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return ApiHelper.execute(
      () => _dio.get(
        ApiConstants.chatMessages(conversationId),
        queryParameters: {'page': page, 'pageSize': pageSize},
      ),
      parser: (data) => PagedData.fromJson(
        data as Map<String, dynamic>,
        ChatMessageModel.fromJson,
      ),
    );
  }

  /// POST /chat/conversations/{id}/messages
  Future<ApiResult<ChatMessageModel>> sendMessage(
    String conversationId, {
    required String content,
    String? attachmentUrl,
  }) async {
    return ApiHelper.execute(
      () => _dio.post(
        ApiConstants.chatMessages(conversationId),
        data: {
          'content': content,
          if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
        },
      ),
      parser: (data) =>
          ChatMessageModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// PUT /chat/conversations/{id}/close
  Future<ApiResult<bool>> closeConversation(String conversationId) async {
    return ApiHelper.execute(
      () => _dio.put(ApiConstants.chatClose(conversationId), data: {}),
      parser: (data) => data == true,
    );
  }

  /// PUT /chat/messages/{id}/read
  Future<ApiResult<bool>> markMessageRead(String messageId) async {
    return ApiHelper.execute(
      () => _dio.put(ApiConstants.chatMessageRead(messageId), data: {}),
      parser: (data) => data == true,
    );
  }

  /// GET /chat/unread-count
  Future<ApiResult<int>> getUnreadCount() async {
    return ApiHelper.execute(
      () => _dio.get(ApiConstants.chatUnreadCount),
      parser: (data) => (data as num?)?.toInt() ?? 0,
    );
  }
}
