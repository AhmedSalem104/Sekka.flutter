import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/settlement_entity.dart';
import '../utils/settlement_helpers.dart';

class SettlementHistoryItem extends StatelessWidget {
  const SettlementHistoryItem({
    super.key,
    required this.settlement,
    this.onTap,
  });

  final SettlementEntity settlement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = settlementTypeColor(settlement.settlementType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: AppSizes.avatarSm,
              height: AppSizes.avatarSm,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              alignment: Alignment.center,
              child: Icon(
                settlementTypeIcon(settlement.settlementType),
                size: AppSizes.iconSm,
                color: typeColor,
              ),
            ),
            SizedBox(width: AppSizes.md),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settlementTypeLabel(settlement.settlementType),
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    settlement.partnerName ??
                        formatSettlementDate(settlement.settledAt),
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Amount + order count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${formatAmount(settlement.amount)} ${AppStrings.currency}',
                  style: AppTypography.titleMedium.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (settlement.orderCount > 0) ...[
                  SizedBox(height: AppSizes.xs),
                  Text(
                    '${settlement.orderCount} ${AppStrings.orderCount}',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
