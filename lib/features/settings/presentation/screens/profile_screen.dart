import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../chat/data/repositories/chat_repository.dart';
import '../../../chat/presentation/screens/conversations_screen.dart';
import '../../../notifications/data/repositories/notification_repository.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../sos/data/repositories/sos_repository.dart';
import '../../../sos/presentation/screens/sos_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
          child: Column(
            children: [
              SizedBox(height: Responsive.h(20)),

              // Profile header
              _buildProfileHeader(isDark),

              SizedBox(height: Responsive.h(28)),

              // Menu items
              _buildMenuItem(
                context,
                icon: IconsaxPlusLinear.message,
                label: 'تواصل معنا',
                isDark: isDark,
                onTap: () => _openChat(context),
              ),
              SizedBox(height: Responsive.h(10)),
              _buildMenuItem(
                context,
                icon: IconsaxPlusLinear.notification,
                label: 'الإشعارات',
                isDark: isDark,
                onTap: () => _openNotifications(context),
              ),
              SizedBox(height: Responsive.h(10)),
              _buildMenuItem(
                context,
                icon: IconsaxPlusLinear.danger,
                label: 'سجل الطوارئ',
                isDark: isDark,
                onTap: () => _openSos(context),
              ),
              SizedBox(height: Responsive.h(10)),
              _buildMenuItem(
                context,
                icon: IconsaxPlusLinear.setting_2,
                label: 'الإعدادات',
                isDark: isDark,
                onTap: () {},
              ),
              SizedBox(height: Responsive.h(10)),
              _buildMenuItem(
                context,
                icon: IconsaxPlusLinear.info_circle,
                label: 'عن سِكّة',
                isDark: isDark,
                onTap: () {},
              ),
              SizedBox(height: Responsive.h(10)),
              _buildMenuItem(
                context,
                icon: IconsaxPlusLinear.logout,
                label: 'تسجيل الخروج',
                isDark: isDark,
                isDestructive: true,
                onTap: () {},
              ),

              SizedBox(height: Responsive.h(120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: Responsive.r(80),
          height: Responsive.r(80),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(
            IconsaxPlusBold.profile_circle,
            color: AppColors.textOnPrimary,
            size: Responsive.r(40),
          ),
        ),
        SizedBox(height: Responsive.h(14)),
        Text(
          'أحمد محمد',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.textHeadlineDark
                : AppColors.textHeadline,
          ),
        ),
        SizedBox(height: Responsive.h(4)),
        Text(
          '01012345678',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textCaption,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.textHeadlineDark : AppColors.textHeadline);

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(16),
        vertical: Responsive.h(14),
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: Responsive.r(40),
            height: Responsive.r(40),
            decoration: BoxDecoration(
              color: (isDestructive ? AppColors.error : AppColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Responsive.r(12)),
            ),
            child: Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.primary,
              size: Responsive.r(20),
            ),
          ),
          SizedBox(width: Responsive.w(14)),
          Expanded(
            child: Text(
              label,
              style: AppTypography.titleMedium.copyWith(color: color),
            ),
          ),
          Icon(
            IconsaxPlusLinear.arrow_left_2,
            color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            size: Responsive.r(18),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context) {
    final dio = context.read<DioClient>().dio;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationsScreen(
          repository: ChatRepository(dio),
        ),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    final dio = context.read<DioClient>().dio;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(
          repository: NotificationRepository(dio),
        ),
      ),
    );
  }

  void _openSos(BuildContext context) {
    final dio = context.read<DioClient>().dio;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SosScreen(
          repository: SosRepository(dio),
        ),
      ),
    );
  }
}
