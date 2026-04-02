import 'package:equatable/equatable.dart';

import '../../data/models/conversation_model.dart';

sealed class ConversationsState extends Equatable {
  const ConversationsState();
  @override
  List<Object?> get props => [];
}

final class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

final class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

final class ConversationsLoaded extends ConversationsState {
  const ConversationsLoaded({
    required this.conversations,
    required this.totalCount,
    this.hasMore = true,
    this.currentPage = 1,
    this.createdConversation,
    this.actionMessage,
    this.isActionError = false,
    this.isSending = false,
  });

  final List<ConversationModel> conversations;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
  final ConversationModel? createdConversation;
  final String? actionMessage;
  final bool isActionError;
  final bool isSending;

  ConversationsLoaded copyWith({
    List<ConversationModel>? conversations,
    int? totalCount,
    bool? hasMore,
    int? currentPage,
    ConversationModel? Function()? createdConversation,
    String? Function()? actionMessage,
    bool? isActionError,
    bool? isSending,
  }) {
    return ConversationsLoaded(
      conversations: conversations ?? this.conversations,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      createdConversation: createdConversation != null
          ? createdConversation()
          : this.createdConversation,
      actionMessage:
          actionMessage != null ? actionMessage() : this.actionMessage,
      isActionError: isActionError ?? this.isActionError,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        totalCount,
        hasMore,
        currentPage,
        createdConversation,
        actionMessage,
        isActionError,
        isSending,
      ];
}

final class ConversationsError extends ConversationsState {
  const ConversationsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
