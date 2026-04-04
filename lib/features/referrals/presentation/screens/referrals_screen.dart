import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../data/models/referral_model.dart';
import '../../data/models/referral_stats_model.dart';
import '../bloc/referrals_bloc.dart';
import '../bloc/referrals_event.dart';
import '../bloc/referrals_state.dart';

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.referralsTitle),
      body: BlocBuilder<ReferralsBloc, ReferralsState>(
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, state) => switch (state) {
          ReferralsInitial() || ReferralsLoading() =>
            const SekkaShimmerList(itemCount: 4),
          ReferralsError(:final message) => SekkaEmptyState(
              icon: IconsaxPlusLinear.warning_2,
              title: message,
              actionLabel: AppStrings.retry,
              onAction: () => context
                  .read<ReferralsBloc>()
                  .add(const ReferralsLoadRequested()),
            ),
          ReferralsLoaded() => _buildContent(context, state, isDark),
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ReferralsLoaded state,
    bool isDark,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => context
          .read<ReferralsBloc>()
          .add(const ReferralsRefreshRequested()),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
        children: [
          SizedBox(height: AppSizes.lg),

          // Code card
          _buildCodeCard(context, state.code, isDark),
          SizedBox(height: AppSizes.lg),

          // Stats
          _buildStatsRow(state.stats, isDark),
          SizedBox(height: AppSizes.xxl),

          // Referrals list header
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              AppStrings.referralsTotalInvited,
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
          ),
          SizedBox(height: AppSizes.md),

          // List
          if (state.referrals.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSizes.xxl),
              child: SekkaEmptyState(
                icon: IconsaxPlusLinear.people,
                title: AppStrings.referralsEmpty,
                description: AppStrings.referralsEmptyDesc,
              ),
            )
          else
            ...state.referrals.map((r) => Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.sm),
                  child: _buildReferralItem(r, isDark),
                )),

          SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }

  Widget _buildCodeCard(BuildContext context, String code, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(20)),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text(
              AppStrings.referralCode,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Responsive.h(12)),

            // Code display
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(24),
                vertical: Responsive.h(14),
              ),
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Responsive.r(12)),
              ),
              child: Text(
                code,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: Responsive.sp(24),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnPrimary,
                  letterSpacing: 4,
                ),
              ),
            ),
            SizedBox(height: Responsive.h(8)),

            Text(
              AppStrings.referralSubtitle,
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.textOnPrimary.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.h(16)),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: _codeButton(
                    label: AppStrings.copyCode,
                    icon: IconsaxPlusLinear.copy,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.codeCopied),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: Responsive.w(10)),
                Expanded(
                  child: _codeButton(
                    label: AppStrings.shareCode,
                    icon: IconsaxPlusLinear.share,
                    onTap: () => SharePlus.instance.share(
                      ShareParams(
                        text: AppStrings.currentLang == 'ar'
                            ? 'سجّل في سِكّة واستخدم كود الدعوة بتاعي: $code\nhttps://sekka.app/join?ref=$code'
                            : 'Join Sekka using my invite code: $code\nhttps://sekka.app/join?ref=$code',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _codeButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
        decoration: BoxDecoration(
          color: AppColors.textOnPrimary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Responsive.r(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: AppColors.textOnPrimary, size: Responsive.r(16)),
            SizedBox(width: Responsive.w(6)),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ReferralStatsModel stats, bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          label: AppStrings.referralsTotalInvited,
          value: '${stats.totalReferrals}',
          icon: IconsaxPlusLinear.people,
          color: AppColors.primary,
          isDark: isDark,
        ),
        SizedBox(width: AppSizes.sm),
        _buildStatCard(
          label: AppStrings.referralsActive,
          value: '${stats.activeReferrals}',
          icon: IconsaxPlusLinear.tick_circle,
          color: AppColors.success,
          isDark: isDark,
        ),
        SizedBox(width: AppSizes.sm),
        _buildStatCard(
          label: AppStrings.referralsEarned,
          value: '${stats.totalEarnings.toInt()}',
          icon: IconsaxPlusLinear.money_recive,
          color: AppColors.warning,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.symmetric(
          vertical: Responsive.h(14),
          horizontal: Responsive.w(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: Responsive.r(22)),
            SizedBox(height: Responsive.h(8)),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: Responsive.h(2)),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralItem(ReferralModel referral, bool isDark) {
    final (statusLabel, statusColor) = _referralStatus(referral.status);
    final dateFormat = DateFormat('yyyy/MM/dd');

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Avatar
            Container(
              width: Responsive.r(44),
              height: Responsive.r(44),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  referral.referredDriverName.isNotEmpty
                      ? referral.referredDriverName.characters.first
                      : '?',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(12)),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referral.referredDriverName,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    '${AppStrings.referralJoined} ${dateFormat.format(referral.createdAt)}',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(10),
                vertical: Responsive.h(4),
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                statusLabel,
                style: AppTypography.captionSmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _referralStatus(int status) => switch (status) {
        0 => (AppStrings.referralStatusPending, AppColors.warning),
        1 => (AppStrings.referralStatusActive, AppColors.success),
        2 => (AppStrings.referralStatusExpired, AppColors.textCaption),
        _ => (AppStrings.referralStatusPending, AppColors.warning),
      };
}
