import 'package:flutter/material.dart';
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
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/api_response.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.repository});
  final NotificationRepository repository;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  PagedData<NotificationModel>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await widget.repository.getNotifications();

    if (!mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _data = data;
          _isLoading = false;
        });
      case ApiFailure(:final error):
        setState(() {
          _error = error.arabicMessage;
          _isLoading = false;
        });
    }
  }

  Future<void> _markAsRead(String id) async {
    await widget.repository.markAsRead(id);
    _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    await widget.repository.markAllAsRead();
    _loadNotifications();
  }

  void _onNotificationTap(NotificationModel notification) {
    // Mark as read first
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate based on actionType
    final action = notification.actionType;
    final data = notification.actionData;

    if (action == null || action.isEmpty) return;

    switch (action) {
      case 'order':
        if (data != null && data.isNotEmpty) {
          context.push(RouteNames.orderDetails, extra: data);
        }
      case 'wallet':
        // MainShell tab 3 is wallet — pop to main first
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(
        title: AppStrings.notificationsTitle,
        actions: [
          if (_data != null && _data!.items.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                AppStrings.readAll,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const SekkaShimmerList(itemCount: 6);
    }

    if (_error != null) {
      return SekkaEmptyState(
        icon: IconsaxPlusLinear.warning_2,
        title: _error!,
        actionLabel: AppStrings.retry,
        onAction: _loadNotifications,
      );
    }

    if (_data == null || _data!.items.isEmpty) {
      return SekkaEmptyState(
        icon: IconsaxPlusLinear.notification,
        title: AppStrings.noNotifications,
        description: AppStrings.noNotificationsDesc,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(Responsive.w(20)),
        itemCount: _data!.items.length,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (context, index) {
          final notification = _data!.items[index];
          return _buildNotificationItem(notification, isDark);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, bool isDark) {
    final (icon, color) = _getNotificationStyle(notification.notificationType);

    return GestureDetector(
      onTap: () => _onNotificationTap(notification),
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
            // Icon
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

            // Content
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
