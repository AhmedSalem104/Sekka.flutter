import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_event.dart';
import '../bloc/sync_state.dart';

/// Small indicator that shows sync status in the app bar or header.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        if (state is! SyncLoaded) return const SizedBox.shrink();

        final status = state.status;
        final isSyncing = state.isSyncing;

        final (icon, color, label) = isSyncing
            ? (IconsaxPlusLinear.refresh, AppColors.info, AppStrings.syncing)
            : status?.isOnline == true
                ? (IconsaxPlusLinear.tick_circle, AppColors.success, AppStrings.syncComplete)
                : (IconsaxPlusLinear.wifi_square, AppColors.warning, AppStrings.syncOffline);

        final pendingCount = status?.pendingChanges ?? 0;

        return GestureDetector(
          onTap: () => _showSyncSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(8),
              vertical: Responsive.h(4),
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSyncing)
                  SizedBox(
                    width: Responsive.r(14),
                    height: Responsive.r(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                else
                  Icon(icon, size: Responsive.r(14), color: color),
                SizedBox(width: Responsive.w(4)),
                Text(
                  pendingCount > 0 ? '$pendingCount' : label,
                  style: AppTypography.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSyncSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<SyncBloc>(),
        child: const _SyncDetailSheet(),
      ),
    );
  }
}

class _SyncDetailSheet extends StatelessWidget {
  const _SyncDetailSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncLoaded && state.actionMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      state.actionMessage!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  backgroundColor: state.isActionError
                      ? AppColors.error
                      : AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              );
            context.read<SyncBloc>().add(const SyncClearMessage());
          }
        },
        builder: (context, state) {
          final loaded = state is SyncLoaded ? state : null;
          final status = loaded?.status;
          final isSyncing = loaded?.isSyncing ?? false;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.pagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: AppSizes.lg),
                      width: Responsive.w(40),
                      height: Responsive.h(4),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusPill),
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    AppStrings.syncStatus,
                    style: AppTypography.headlineSmall,
                  ),
                  SizedBox(height: AppSizes.lg),

                  // Status card
                  SekkaCard(
                    child: Column(
                      children: [
                        _StatusRow(
                          icon: IconsaxPlusLinear.wifi,
                          label: AppStrings.syncStatus,
                          value: status?.isOnline == true
                              ? AppStrings.online
                              : AppStrings.offline,
                          color: status?.isOnline == true
                              ? AppColors.success
                              : AppColors.error,
                          isDark: isDark,
                        ),
                        _divider(isDark),
                        _StatusRow(
                          icon: IconsaxPlusLinear.clock,
                          label: AppStrings.lastSyncAt,
                          value: _formatDate(status?.lastSyncAt),
                          color: isDark
                              ? AppColors.textBodyDark
                              : AppColors.textBody,
                          isDark: isDark,
                        ),
                        _divider(isDark),
                        _StatusRow(
                          icon: IconsaxPlusLinear.document_upload,
                          label: AppStrings.pendingChanges,
                          value: '${status?.pendingChanges ?? 0}',
                          color: (status?.pendingChanges ?? 0) > 0
                              ? AppColors.warning
                              : AppColors.success,
                          isDark: isDark,
                        ),
                        _divider(isDark),
                        _StatusRow(
                          icon: IconsaxPlusLinear.warning_2,
                          label: AppStrings.conflicts,
                          value: '${status?.conflictsCount ?? 0}',
                          color: (status?.conflictsCount ?? 0) > 0
                              ? AppColors.error
                              : AppColors.success,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizes.xl),

                  // Sync now button
                  SekkaButton(
                    label: AppStrings.syncNow,
                    onPressed: isSyncing
                        ? null
                        : () => context
                            .read<SyncBloc>()
                            .add(const SyncNowRequested()),
                    isLoading: isSyncing,
                    icon: IconsaxPlusLinear.refresh,
                  ),

                  SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? AppColors.borderDark : AppColors.border,
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '-';
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSm, color: color),
          SizedBox(width: AppSizes.sm),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
