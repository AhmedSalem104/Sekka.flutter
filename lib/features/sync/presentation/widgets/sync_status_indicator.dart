import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_state.dart';

/// Passive connection-status indicator for the app bar.
/// Shows the current network state — no user interaction needed.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        if (state is! SyncLoaded) return const SizedBox.shrink();

        final status = state.status;
        final isOnline = status?.isOnline == true;
        final isSyncing = state.isSyncing;

        final IconData icon;
        final Color color;
        final String label;

        if (isSyncing) {
          icon = IconsaxPlusLinear.refresh;
          color = AppColors.info;
          label = AppStrings.syncing;
        } else if (!isOnline) {
          icon = IconsaxPlusLinear.wifi_square;
          color = AppColors.error;
          label = AppStrings.connectionOffline;
        } else {
          // Online & idle — don't show anything, all good
          return const SizedBox.shrink();
        }

        return Container(
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
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
