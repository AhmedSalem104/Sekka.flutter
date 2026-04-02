import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../data/models/notification_model.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(
        title: AppStrings.notificationsTitle,
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            buildWhen: (prev, curr) {
              final prevHasUnread = prev is NotificationsLoaded &&
                  prev.notifications.any((n) => !n.isRead);
              final currHasUnread = curr is NotificationsLoaded &&
                  curr.notifications.any((n) => !n.isRead);
              return prevHasUnread != currHasUnread;
            },
            builder: (context, state) {
              if (state is NotificationsLoaded &&
                  state.notifications.any((n) => !n.isRead)) {
                return TextButton(
                  onPressed: () => context
                      .read<NotificationsBloc>()
                      .add(const NotificationsMarkAllAsRead()),
                  child: Text(
                    AppStrings.readAll,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        buildWhen: (prev, curr) =>
            prev.runtimeType != curr.runtimeType ||
            (prev is NotificationsLoaded &&
                curr is NotificationsLoaded &&
                prev != curr),
        builder: (context, state) => switch (state) {
          NotificationsInitial() ||
          NotificationsLoading() =>
            const SekkaShimmerList(itemCount: 6),
          NotificationsError(:final message) => SekkaEmptyState(
              icon: IconsaxPlusLinear.warning_2,
              title: message,
              actionLabel: AppStrings.retry,
              onAction: () => context
                  .read<NotificationsBloc>()
                  .add(const NotificationsLoadRequested()),
            ),
          NotificationsLoaded(:final notifications)
              when notifications.isEmpty =>
            SekkaEmptyState(
              icon: IconsaxPlusLinear.notification,
              title: AppStrings.noNotifications,
              description: AppStrings.noNotificationsDesc,
            ),
          NotificationsLoaded(:final notifications) => RefreshIndicator(
              onRefresh: () async => context
                  .read<NotificationsBloc>()
                  .add(const NotificationsRefreshRequested()),
              color: AppColors.primary,
              child: ListView.separated(
                padding: EdgeInsets.all(Responsive.w(20)),
                itemCount: notifications.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: Responsive.h(10)),
                itemBuilder: (context, index) =>
                    _buildNotificationItem(
                  context,
                  notifications[index],
                  isDark,
                ),
              ),
            ),
        },
      ),
    );
  }

  void _onNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    if (!notification.isRead) {
      context
          .read<NotificationsBloc>()
          .add(NotificationMarkAsRead(notification.id));
    }

    final action = notification.actionType;
    final data = notification.actionData;

    if (action == null || action.isEmpty) return;

    switch (action) {
      case 'order':
        if (data != null && data.isNotEmpty) {
          context.push(RouteNames.orderDetails, extra: data);
        }
      case 'wallet':
        Navigator.pop(context);
      case 'settlement':
        context.push(RouteNames.settlements);
      case 'profile':
        context.push(RouteNames.editProfile);
      case 'settings':
        context.push(RouteNames.settings);
      case 'chat':
        context.push(RouteNames.chat);
    }
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    bool isDark,
  ) {
    final (icon, color) =
        _getNotificationStyle(notification.notificationType);

    return GestureDetector(
      onTap: () => _onNotificationTap(context, notification),
      child: SekkaCard(
        color: notification.isRead
            ? (isDark ? AppColors.surfaceDark : AppColors.surface)
            : (isDark
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.primaryLight),
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Responsive.r(44),
              height: Responsive.r(44),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Responsive.r(12)),
              ),
              child: Icon(icon, color: color, size: Responsive.r(22)),
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
                          notification.title,
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark
                                ? AppColors.textHeadlineDark
                                : AppColors.textHeadline,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: Responsive.r(8),
                          height: Responsive.r(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    notification.message,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textCaption,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(6)),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getNotificationStyle(String type) => switch (type) {
        'NewOrder' => (IconsaxPlusBold.box, AppColors.primary),
        'CashAlert' => (IconsaxPlusBold.money_recive, AppColors.warning),
        'BreakReminder' => (IconsaxPlusBold.coffee, AppColors.info),
        'Maintenance' => (IconsaxPlusBold.setting_2, AppColors.textCaption),
        'Settlement' => (IconsaxPlusBold.wallet_2, AppColors.success),
        'Achievement' => (IconsaxPlusBold.medal_star, AppColors.warning),
        'SystemUpdate' => (IconsaxPlusBold.info_circle, AppColors.info),
        'Chat' => (IconsaxPlusBold.message, AppColors.primary),
        _ => (IconsaxPlusBold.notification, AppColors.textCaption),
      };

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'من ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'من ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'من ${diff.inDays} يوم';
    return '${dateTime.day}/${dateTime.month}';
  }
}
