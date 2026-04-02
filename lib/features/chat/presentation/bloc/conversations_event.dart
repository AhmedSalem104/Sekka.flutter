import 'package:equatable/equatable.dart';

sealed class ConversationsEvent extends Equatable {
  const ConversationsEvent();
  @override
  List<Object?> get props => [];
}

final class ConversationsLoadRequested extends ConversationsEvent {
  const ConversationsLoadRequested();
}

final class ConversationsRefreshRequested extends ConversationsEvent {
  const ConversationsRefreshRequested();
}

final class ConversationCreateRequested extends ConversationsEvent {
  const ConversationCreateRequested({
    required this.chatType,
    required this.initialMessage,
  });
  final int chatType;
  final String initialMessage;
  @override
  List<Object?> get props => [chatType, initialMessage];
}

final class ConversationSendMessage extends ConversationsEvent {
  const ConversationSendMessage({
    required this.conversationId,
    required this.content,
  });
  final String conversationId;
  final String content;
  @override
  List<Object?> get props => [conversationId, content];
}

final class ConversationsClearMessage extends ConversationsEvent {
  const ConversationsClearMessage();
}
