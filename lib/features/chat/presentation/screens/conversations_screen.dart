import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/api_response.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_messages_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key, required this.repository});
  final ChatRepository repository;

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  PagedData<ConversationModel>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await widget.repository.getConversations();
      if (!mounted) return;
      switch (result) {
        case ApiSuccess(:final data):
          setState(() { _data = data; _isLoading = false; });
        case ApiFailure(:final error):
          setState(() { _error = error.arabicMessage; _isLoading = false; });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'مفيش نت — جرّب تاني لما النت يرجع'; _isLoading = false; });
    }
  }

  Future<void> _createConversation() async {
    final args = await _showNewConversationDialog();
    if (args == null || !mounted) return;

    final (chatType, message) = args;

    final result = await widget.repository.createConversation(
      chatType: chatType,
      initialMessage: message,
    );
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        _openChat(data);
      case ApiFailure(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.arabicMessage)),
        );
    }
  }

  Future<(int, String)?> _showNewConversationDialog() async {
    int selectedType = 0;
    final messageController = TextEditingController();

    final types = [
      (0, AppStrings.chatTypeSupport),
      (1, AppStrings.chatTypeComplaint),
      (2, AppStrings.chatTypeSuggestion),
      (3, AppStrings.chatTypeGeneral),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<(int, String)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          title: Text(
            AppStrings.chatNewConversation,
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type chips
              Wrap(
                spacing: Responsive.w(8),
                runSpacing: Responsive.h(8),
                children: types.map((t) {
                  final (value, label) = t;
                  final isSelected = selectedType == value;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedType = value),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(14),
                        vertical: Responsive.h(8),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(Responsive.r(10)),
                      ),
                      child: Text(
                        label,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: Responsive.h(16)),
              // Message
              TextField(
                controller: messageController,
                textDirection: TextDirection.rtl,
                maxLines: 3,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.r(12)),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.border,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(Responsive.w(12)),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppStrings.cancel,
                style: AppTypography.button.copyWith(
                  color: AppColors.textCaption,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final msg = messageController.text.trim();
                if (msg.isEmpty) return;
                Navigator.pop(ctx, (selectedType, msg));
              },
              child: Text(
                AppStrings.confirm,
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(ConversationModel conversation) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChatMessagesScreen(
          repository: widget.repository,
          conversation: conversation,
        ),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.chatTitle),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chat_fab',
        onPressed: _createConversation,
        backgroundColor: AppColors.primary,
        child: Icon(
          IconsaxPlusBold.add,
          color: AppColors.textOnPrimary,
          size: Responsive.r(24),
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) return const SekkaShimmerList(itemCount: 5);

    if (_error != null) {
      return SekkaEmptyState(
        icon: IconsaxPlusLinear.warning_2,
        title: _error!,
        actionLabel: AppStrings.retry,
        onAction: _load,
      );
    }

    if (_data == null || _data!.items.isEmpty) {
      return SekkaEmptyState(
        icon: IconsaxPlusLinear.message,
        title: AppStrings.chatNoConversations,
        description: AppStrings.chatNoConversationsDesc,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(Responsive.w(20)),
        itemCount: _data!.items.length,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (context, index) {
          final conv = _data!.items[index];
          return _buildConversationItem(conv, isDark);
        },
      ),
    );
  }

  Widget _buildConversationItem(ConversationModel conv, bool isDark) {
    final chatTypeLabel = switch (conv.chatType) {
      0 => AppStrings.chatTypeSupport,
      1 => AppStrings.chatTypeComplaint,
      2 => AppStrings.chatTypeSuggestion,
      _ => AppStrings.chatTypeGeneral,
    };

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      onTap: () => _openChat(conv),
      child: Row(
        children: [
          Container(
            width: Responsive.r(48),
            height: Responsive.r(48),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Responsive.r(14)),
            ),
            child: Icon(
              conv.isClosed
                  ? IconsaxPlusBold.message_remove
                  : IconsaxPlusBold.message,
              color: conv.isClosed ? AppColors.textCaption : AppColors.primary,
              size: Responsive.r(22),
            ),
          ),
          SizedBox(width: Responsive.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conv.subject ?? chatTypeLabel,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.textHeadlineDark
                              : AppColors.textHeadline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (conv.unreadCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(8),
                          vertical: Responsive.h(2),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(Responsive.r(10)),
                        ),
                        child: Text(
                          '${conv.unreadCount}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: Responsive.sp(10),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                if (conv.lastMessage != null) ...[
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    conv.lastMessage!,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textCaption,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
