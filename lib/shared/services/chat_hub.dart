import 'dart:convert';
import 'dart:developer' as dev;
import '../storage/token_storage.dart';
import 'signalr_service.dart';

/// Real-time chat hub for driver-to-support messaging.
///
/// Client→Server: JoinConversation, LeaveConversation, SendMessage, StartTyping, StopTyping
/// Server→Client: ReceiveMessage, UserTyping, UserStoppedTyping, ConversationClosed
class ChatHub {
  ChatHub({required TokenStorage tokenStorage})
      : _service = SignalRService(
          hubName: 'chat',
          tokenStorage: tokenStorage,
        );

  final SignalRService _service;

  void Function(Map<String, dynamic> message)? onReceiveMessage;
  void Function(String userId)? onUserTyping;
  void Function(String userId)? onUserStoppedTyping;
  void Function(String conversationId)? onConversationClosed;

  Future<void> connect() async {
    await _service.connect();

    _service.on('ReceiveMessage', (args) {
      if (args != null && args.isNotEmpty) {
        try {
          final data = args[0] is String
              ? jsonDecode(args[0] as String) as Map<String, dynamic>
              : args[0] as Map<String, dynamic>;
          onReceiveMessage?.call(data);
        } catch (e) {
          dev.log('Error parsing ReceiveMessage: $e', name: 'ChatHub');
        }
      }
    });

    _service.on('UserTyping', (args) {
      if (args != null && args.isNotEmpty) {
        onUserTyping?.call(args[0] as String);
      }
    });

    _service.on('UserStoppedTyping', (args) {
      if (args != null && args.isNotEmpty) {
        onUserStoppedTyping?.call(args[0] as String);
      }
    });

    _service.on('ConversationClosed', (args) {
      if (args != null && args.isNotEmpty) {
        onConversationClosed?.call(args[0] as String);
      }
    });
  }

  Future<void> joinConversation(String conversationId) async {
    await _service.invoke('JoinConversation', args: [conversationId]);
  }

  Future<void> leaveConversation(String conversationId) async {
    await _service.invoke('LeaveConversation', args: [conversationId]);
  }

  Future<void> sendMessage(String conversationId, String content) async {
    await _service.invoke('SendMessage', args: [conversationId, content]);
  }

  Future<void> startTyping(String conversationId) async {
    await _service.invoke('StartTyping', args: [conversationId]);
  }

  Future<void> stopTyping(String conversationId) async {
    await _service.invoke('StopTyping', args: [conversationId]);
  }

  Future<void> disconnect() async {
    await _service.disconnect();
  }
}
