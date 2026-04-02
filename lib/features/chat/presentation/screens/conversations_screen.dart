import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../bloc/conversations_state.dart';
import 'chat_messages_screen.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key, required this.repository});
  final ChatRepository repository;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.chatTitle),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chat_fab',
        onPressed: () => _createConversation(context),
        backgroundColor: AppColors.primary,
        child: Icon(
          IconsaxPlusBold.add,
          color: AppColors.textOnPrimary,
          size: Responsive.r(24),
        ),
      ),
      body: BlocConsumer<ConversationsBloc, ConversationsState>(
        listenWhen: (prev, curr) {
          if (curr is ConversationsLoaded) {
            return curr.createdConversation != null ||
                curr.actionMessage != null;
          }
          return false;
        },
        listener: (context, state) {
          if (state is ConversationsLoaded) {
            if (state.createdConversation != null) {
              final conv = state.createdConversation!;
              context
                  .read<ConversationsBloc>()
                  .add(const ConversationsClearMessage());
              _openChat(context, conv);
            }
            if (state.actionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage!)),
              );
              context
                  .read<ConversationsBloc>()
                  .add(const ConversationsClearMessage());
            }
          }
        },
        buildWhen: (prev, curr) {
          if (prev is ConversationsLoaded && curr is ConversationsLoaded) {
            return prev.conversations != curr.conversations;
          }
          return true;
        },
        builder: (context, state) => switch (state) {
          ConversationsInitial() ||
          ConversationsLoading() =>
            const SekkaShimmerList(itemCount: 5),
          ConversationsError(:final message) => SekkaEmptyState(
              icon: IconsaxPlusLinear.warning_2,
              title: message,
              actionLabel: AppStrings.retry,
              onAction: () => context
                  .read<ConversationsBloc>()
                  .add(const ConversationsLoadRequested()),
            ),
          ConversationsLoaded(:final conversations)
              when conversations.isEmpty =>
            SekkaEmptyState(
              icon: IconsaxPlusLinear.message,
              title: AppStrings.chatNoConversations,
              description: AppStrings.chatNoConversationsDesc,
            ),
          ConversationsLoaded(:final conversations) => RefreshIndicator(
              onRefresh: () async => context
                  .read<ConversationsBloc>()
                  .add(const ConversationsRefreshRequested()),
              color: AppColors.primary,
              child: ListView.separated(
                padding: EdgeInsets.all(Responsive.w(20)),
                itemCount: conversations.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: Responsive.h(10)),
                itemBuilder: (context, index) =>
                    _buildConversationItem(
                  context,
                  conversations[index],
                  isDark,
                ),
              ),
            ),
        },
      ),
    );
  }

  Future<void> _createConversation(BuildContext context) async {
    final args = await _showNewConversationDialog(context);
    if (args == null) return;

    final (chatType, message) = args;
    if (!context.mounted) return;

    context.read<ConversationsBloc>().add(ConversationCreateRequested(
          chatType: chatType,
          initialMessage: message,
        ));
  }

  Future<(int, String)?> _showNewConversationDialog(
    BuildContext context,
  ) async {
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
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surface,
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
              Wrap(
                spacing: Responsive.w(8),
                runSpacing: Responsive.h(8),
                children: types.map((t) {
                  final (value, label) = t;
                  final isSelected = selectedType == value;
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedType = value),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(14),
                        vertical: Responsive.h(8),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary
                                .withValues(alpha: 0.08),
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
                    borderRadius:
                        BorderRadius.circular(Responsive.r(12)),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.border,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.all(Responsive.w(12)),
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

  void _openChat(BuildContext context, ConversationModel conversation) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChatMessagesScreen(
          repository: repository,
          conversation: conversation,
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context
            .read<ConversationsBloc>()
            .add(const ConversationsRefreshRequested());
      }
    });
  }

  Widget _buildConversationItem(
    BuildContext context,
    ConversationModel conv,
    bool isDark,
  ) {
    final chatTypeLabel = switch (conv.chatType) {
      0 => AppStrings.chatTypeSupport,
      1 => AppStrings.chatTypeComplaint,
      2 => AppStrings.chatTypeSuggestion,
      _ => AppStrings.chatTypeGeneral,
    };

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      onTap: () => _openChat(context, conv),
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
              color:
                  conv.isClosed ? AppColors.textCaption : AppColors.primary,
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
