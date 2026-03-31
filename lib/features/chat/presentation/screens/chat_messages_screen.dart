import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository.dart';

class ChatMessagesScreen extends StatefulWidget {
  const ChatMessagesScreen({
    super.key,
    required this.repository,
    required this.conversation,
  });

  final ChatRepository repository;
  final ConversationModel conversation;

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  late bool _isClosed;

  @override
  void initState() {
    super.initState();
    _isClosed = widget.conversation.isClosed;
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Endpoint 3: GET /conversations/{id}/messages ──

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final result = await widget.repository.getMessages(widget.conversation.id);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _messages = data.items.reversed.toList();
          _isLoading = false;
        });
        _scrollToBottom();
        // Endpoint 6: mark unread messages as read
        _markUnreadMessagesAsRead();
      case ApiFailure(:final error):
        setState(() => _isLoading = false);
        _showError(error.arabicMessage);
    }
  }

  // ── Endpoint 4: POST /conversations/{id}/messages ──

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final result = await widget.repository.sendMessage(
      widget.conversation.id,
      content: text,
    );

    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _messages.add(data);
          _isSending = false;
        });
        _scrollToBottom();
      case ApiFailure(:final error):
        setState(() => _isSending = false);
        _messageController.text = text;
        _showError(error.arabicMessage);
    }
  }

  // ── Endpoint 5: PUT /conversations/{id}/close ──

  Future<void> _closeConversation() async {
    final isDlgDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDlgDark ? AppColors.surfaceDark : AppColors.surface,
        title: Text(
          AppStrings.chatCloseConversation,
          style: AppTypography.titleLarge.copyWith(
            color: isDlgDark
                ? AppColors.textHeadlineDark
                : AppColors.textHeadline,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          AppStrings.chatCloseConfirm,
          style: AppTypography.bodyMedium.copyWith(
            color: isDlgDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppStrings.cancel,
              style: AppTypography.button.copyWith(
                color: isDlgDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.confirm,
              style: AppTypography.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await widget.repository.closeConversation(
      widget.conversation.id,
    );

    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        setState(() => _isClosed = true);
      case ApiFailure(:final error):
        _showError(error.arabicMessage);
    }
  }

  // ── Endpoint 6: PUT /messages/{id}/read ──

  Future<void> _markUnreadMessagesAsRead() async {
    // Mark non-driver (admin) messages as read
    final unread = _messages.where((m) => !m.isDriver && m.status == 0);
    for (final msg in unread) {
      widget.repository.markMessageRead(msg.id);
    }
  }

  // ── Helpers ──

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        title: Text(
          widget.conversation.subject ?? AppStrings.chatConversation,
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            IconsaxPlusLinear.arrow_right_3,
            color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        actions: [
          // Close conversation action (Endpoint 5)
          if (!_isClosed)
            IconButton(
              onPressed: _closeConversation,
              tooltip: AppStrings.chatCloseConversation,
              icon: Icon(
                IconsaxPlusLinear.close_circle,
                color: AppColors.error,
                size: Responsive.r(22),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Closed banner
          if (_isClosed)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: Responsive.h(10),
                horizontal: Responsive.w(16),
              ),
              color: AppColors.textCaption.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    IconsaxPlusBold.lock_1,
                    color: AppColors.textCaption,
                    size: Responsive.r(16),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  Text(
                    AppStrings.chatClosed,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textCaption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: _isLoading
                ? const SekkaLoading()
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.chatStartConversation,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMessages,
                        color: AppColors.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(16),
                            vertical: Responsive.h(12),
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (_, index) =>
                              _buildMessage(_messages[index], isDark),
                        ),
                      ),
          ),

          // Input (hidden when closed)
          if (!_isClosed) _buildInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessageModel msg, bool isDark) {
    final isMe = msg.isDriver;

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: Responsive.screenWidth * 0.75),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(14),
            vertical: Responsive.h(10),
          ),
          decoration: BoxDecoration(
            color: isMe
                ? AppColors.primary
                : (isDark ? AppColors.surfaceDark : AppColors.surface),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Responsive.r(16)),
              topRight: Radius.circular(Responsive.r(16)),
              bottomLeft: isMe
                  ? Radius.circular(Responsive.r(16))
                  : Radius.circular(Responsive.r(4)),
              bottomRight: isMe
                  ? Radius.circular(Responsive.r(4))
                  : Radius.circular(Responsive.r(16)),
            ),
            border: isMe
                ? null
                : Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe && msg.senderName.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: Responsive.h(4)),
                  child: Text(
                    msg.senderName,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                msg.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: isMe
                      ? AppColors.textOnPrimary
                      : (isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline),
                ),
              ),
              SizedBox(height: Responsive.h(4)),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                  style: AppTypography.captionSmall.copyWith(
                    color: isMe
                        ? AppColors.textOnPrimary.withValues(alpha: 0.7)
                        : (isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: Responsive.w(16),
        right: Responsive.w(16),
        bottom: Responsive.safePadding.bottom + Responsive.h(10),
        top: Responsive.h(10),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.background,
                borderRadius: BorderRadius.circular(Responsive.r(24)),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: TextField(
                controller: _messageController,
                textDirection: TextDirection.rtl,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.chatMessageHint,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(16),
                    vertical: Responsive.h(10),
                  ),
                ),
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          SizedBox(width: Responsive.w(10)),

          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: Responsive.r(44),
              height: Responsive.r(44),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? Padding(
                      padding: EdgeInsets.all(Responsive.r(12)),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : Icon(
                      IconsaxPlusBold.send_1,
                      color: AppColors.textOnPrimary,
                      size: Responsive.r(20),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
