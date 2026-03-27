class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.chatType,
    this.subject,
    required this.isClosed,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
  });

  final String id;
  final int chatType;
  final String? subject;
  final bool isClosed;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      chatType: json['chatType'] as int? ?? 3,
      subject: json['subject'] as String?,
      isClosed: json['isClosed'] as bool? ?? false,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    this.attachmentUrl,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String senderType;
  final String content;
  final String? attachmentUrl;
  final int status;
  final DateTime createdAt;

  bool get isDriver => senderType == 'Driver';
  bool get isAdmin => senderType == 'Admin';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderType: json['senderType'] as String,
      content: json['content'] as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
