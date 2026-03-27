import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
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
    final result = await widget.repository.getConversations();
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() { _data = data; _isLoading = false; });
      case ApiFailure(:final error):
        setState(() { _error = error.arabicMessage; _isLoading = false; });
    }
  }

  Future<void> _createConversation() async {
    final result = await widget.repository.createConversation(
      chatType: 0,
      subject: 'محادثة جديدة',
      initialMessage: 'مرحبا، محتاج مساعدة',
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

  void _openChat(ConversationModel conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
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
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        title: Text(
          'تواصل معنا',
          style: AppTypography.headlineSmall.copyWith(
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createConversation,
        backgroundColor: AppColors.primary,
        child: Icon(IconsaxPlusBold.add, color: AppColors.textOnPrimary, size: Responsive.r(24)),
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
        actionLabel: 'حاول تاني',
        onAction: _load,
      );
    }

    if (_data == null || _data!.items.isEmpty) {
      return const SekkaEmptyState(
        icon: IconsaxPlusLinear.message,
        title: 'مفيش محادثات',
        description: 'ابدأ محادثة جديدة مع فريق الدعم',
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
      0 => 'دعم فني',
      1 => 'شكوى',
      2 => 'اقتراح',
      _ => 'عام',
    };

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      onTap: () => _openChat(conv),
      child: Row(
        children: [
          // Icon
          Container(
            width: Responsive.r(48),
            height: Responsive.r(48),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Responsive.r(14)),
            ),
            child: Icon(
              conv.isClosed ? IconsaxPlusBold.message_remove : IconsaxPlusBold.message,
              color: conv.isClosed ? AppColors.textCaption : AppColors.primary,
              size: Responsive.r(22),
            ),
          ),
          SizedBox(width: Responsive.w(14)),

          // Content
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
                          color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
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
                          borderRadius: BorderRadius.circular(Responsive.r(10)),
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
                      color: isDark ? AppColors.textBodyDark : AppColors.textCaption,
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
