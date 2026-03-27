import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_completion_card.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_section_tile.dart';
import '../widgets/profile_stats_summary.dart';
import '../widgets/referral_code_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.profileTitle, style: AppTypography.headlineSmall),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            SekkaMessageDialog.show(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) return const SekkaLoading();
          if (state is ProfileLoaded) return _buildContent(context, state, isDark);
          if (state is ProfileError) return _buildError(context, state.message);
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: AppTypography.bodyMedium),
          SizedBox(height: AppSizes.lg),
          TextButton(
            onPressed: () => context
                .read<ProfileBloc>()
                .add(const ProfileLoadRequested()),
            child: Text(
              AppStrings.retry,
              style: AppTypography.titleMedium
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProfileLoaded state,
    bool isDark,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<ProfileBloc>().add(const ProfileRefreshRequested());
      },
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
        children: [
          SizedBox(height: AppSizes.lg),

          // Header — avatar, name, phone, level, edit button
          ProfileHeaderCard(
            profile: state.profile,
            onEditTap: () => context.push(RouteNames.editProfile),
          ),
          SizedBox(height: AppSizes.lg),

          // Completion — progress bar + pending steps
          ProfileCompletionCard(
            completion: state.completion,
            onStepTap: (_) => context.push(RouteNames.editProfile),
          ),
          if (!state.completion.isProfileComplete) SizedBox(height: AppSizes.lg),

          // Quick stats
          ProfileStatsSummary(stats: state.stats),
          SizedBox(height: AppSizes.lg),

          // Referral code
          ReferralCodeCard(code: state.profile.referralCode ?? ''),
          SizedBox(height: AppSizes.xxl),

          // ── Sections ──────────────────────────────
          ProfileSectionTile(
            icon: IconsaxPlusLinear.chart_2,
            label: AppStrings.detailedStats,
            onTap: () => context.push(RouteNames.profileStats),
          ),
          SizedBox(height: AppSizes.sm),

          ProfileSectionTile(
            icon: IconsaxPlusLinear.call_calling,
            label: AppStrings.emergencyContacts,
            onTap: () => context.push(RouteNames.emergencyContacts),
          ),
          SizedBox(height: AppSizes.sm),

          ProfileSectionTile(
            icon: IconsaxPlusLinear.money_send,
            label: AppStrings.expenses,
            onTap: () => context.push(RouteNames.profileExpenses),
          ),
          SizedBox(height: AppSizes.sm),

          ProfileSectionTile(
            icon: IconsaxPlusLinear.setting_2,
            label: AppStrings.settings,
            onTap: () => context.push(RouteNames.settings),
          ),
          SizedBox(height: AppSizes.xxl),

          // Logout
          ProfileSectionTile(
            icon: IconsaxPlusLinear.logout,
            label: AppStrings.logout,
            color: AppColors.error,
            trailing: const SizedBox.shrink(),
            onTap: () => _showLogoutDialog(context),
          ),
          SizedBox(height: AppSizes.xxl),

          // Bottom safe area
          SizedBox(height: AppSizes.bottomNavHeight + AppSizes.xl),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        title: Text(
          AppStrings.logout,
          style: AppTypography.headlineSmall,
        ),
        content: Text(
          AppStrings.logoutConfirm,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textCaption,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: Text(
              AppStrings.logout,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
