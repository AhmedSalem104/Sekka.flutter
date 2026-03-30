import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../partners/data/models/partner_model.dart';
import '../../domain/entities/partner_balance_entity.dart';
import '../utils/settlement_helpers.dart';

class PartnerBalanceTile extends StatelessWidget {
  const PartnerBalanceTile({
    super.key,
    required this.partner,
    this.balance,
    this.onTap,
  });

  final PartnerModel partner;
  final PartnerBalanceEntity? balance;
  final VoidCallback? onTap;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final partnerColor = _parseColor(partner.color);

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
            // Partner avatar
            Container(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
              decoration: BoxDecoration(
                color: partnerColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              alignment: Alignment.center,
              child: Text(
                partner.name.isNotEmpty ? partner.name[0] : '?',
                style: AppTypography.titleLarge.copyWith(
                  color: partnerColor,
                ),
              ),
            ),
            SizedBox(width: AppSizes.md),

            // Partner info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (balance != null) ...[
                    SizedBox(height: AppSizes.xs),
                    Text(
                      '${AppStrings.pendingBalance}: ${formatAmount(balance!.pendingBalance)} ${AppStrings.currency}',
                      style: AppTypography.captionSmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow
            Icon(
              IconsaxPlusLinear.arrow_left_2,
              size: AppSizes.iconSm,
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
          ],
        ),
      ),
    );
  }
}
