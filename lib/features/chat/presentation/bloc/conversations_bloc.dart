import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../../shared/network/api_result.dart';
import '../../../../shared/offline/offline_queue_service.dart';
import '../../../../shared/offline/queue_operation.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'conversations_event.dart';
import 'conversations_state.dart';

class ConversationsBloc
    extends HydratedBloc<ConversationsEvent, ConversationsState> {
  ConversationsBloc({required ChatRepository repository})
      : _repository = repository,
        super(const ConversationsInitial()) {
    on<ConversationsLoadRequested>(_onLoadRequested);
    on<ConversationsRefreshRequested>(_onRefreshRequested);
    on<ConversationCreateRequested>(_onCreateRequested);
    on<ConversationSendMessage>(_onSendMessage);
    on<ConversationsClearMessage>(_onClearMessage);
  }

  final ChatRepository _repository;

  Future<void> _onLoadRequested(
    ConversationsLoadRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    // Only show loading if no cached data
    if (state is! ConversationsLoaded) {
      emit(const ConversationsLoading());
    }

    final result = await _repository.getConversations();

    switch (result) {
      case ApiSuccess(:final data):
        emit(ConversationsLoaded(
          conversations: data.items,
          totalCount: data.totalCount,
          hasMore: data.hasNextPage,
          currentPage: data.page,
        ));
      case ApiFailure(:final error):
        // Keep cached data on failure
        if (state is! ConversationsLoaded) {
          emit(ConversationsError(error.arabicMessage));
        }
    }
  }

  Future<void> _onRefreshRequested(
    ConversationsRefreshRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    final result = await _repository.getConversations();

    switch (result) {
      case ApiSuccess(:final data):
        emit(ConversationsLoaded(
          conversations: data.items,
          totalCount: data.totalCount,
          hasMore: data.hasNextPage,
          currentPage: data.page,
        ));
      case ApiFailure():
        break; // Keep cached state on refresh failure
    }
  }

  Future<void> _onCreateRequested(
    ConversationCreateRequested event,
    Emitter<ConversationsState> emit,
  ) async {
    final result = await _repository.createConversation(
      chatType: event.chatType,
      initialMessage: event.initialMessage,
    );

    switch (result) {
      case ApiSuccess(:final data):
        final current = state;
        if (current is ConversationsLoaded) {
          emit(current.copyWith(
            conversations: [data, ...current.conversations],
            totalCount: current.totalCount + 1,
            createdConversation: () => data,
          ));
        } else {
          emit(ConversationsLoaded(
            conversations: [data],
            totalCount: 1,
            createdConversation: data,
          ));
        }
      case ApiFailure(:final error):
        final current = state;
        if (current is ConversationsLoaded) {
          emit(current.copyWith(
            actionMessage: () => error.arabicMessage,
            isActionError: true,
          ));
        }
    }
  }

  Future<void> _onSendMessage(
    ConversationSendMessage event,
    Emitter<ConversationsState> emit,
  ) async {
    if (ConnectivityService.instance.isOnline) {
      await _repository.sendMessage(
        event.conversationId,
        content: event.content,
      );
    } else {
      // Queue for later
      await OfflineQueueService.instance.enqueueNew(
        type: QueueOperationType.chatSend,
        orderId: event.conversationId,
        payload: {
          'conversationId': event.conversationId,
          'content': event.content,
        },
      );
    }
  }

  void _onClearMessage(
    ConversationsClearMessage event,
    Emitter<ConversationsState> emit,
  ) {
    final current = state;
    if (current is ConversationsLoaded) {
      emit(current.copyWith(
        actionMessage: () => null,
        isActionError: false,
        createdConversation: () => null,
      ));
    }
  }

  // ── Hydration ──

  @override
  ConversationsState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'loaded') {
        final conversations = (json['conversations'] as List<dynamic>)
            .map((c) => ConversationModel.fromJson(
                  Map<String, dynamic>.from(c as Map),
                ))
            .toList();
        return ConversationsLoaded(
          conversations: conversations,
          totalCount: json['totalCount'] as int? ?? conversations.length,
          hasMore: json['hasMore'] as bool? ?? false,
          currentPage: json['currentPage'] as int? ?? 1,
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(ConversationsState state) {
    if (state is ConversationsLoaded) {
      return {
        'type': 'loaded',
        'conversations':
            state.conversations.map((c) => c.toJson()).toList(),
        'totalCount': state.totalCount,
        'hasMore': state.hasMore,
        'currentPage': state.currentPage,
      };
    }
    return null;
  }
}
