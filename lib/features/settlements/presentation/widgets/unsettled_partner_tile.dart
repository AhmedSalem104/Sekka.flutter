import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../partners/data/models/partner_model.dart';
import '../../domain/entities/partner_balance_entity.dart';

/// Tile for a partner that still has money owed to them — the heart of the
/// settlements checklist.
///
/// Tap anywhere on the tile → opens the partner detail (to see history, etc.).
/// Tap the "سلّم" button → opens the create-settlement flow with the partner
/// pre-filled (and the amount pre-filled to the pending balance).
class UnsettledPartnerTile extends StatelessWidget {
  const UnsettledPartnerTile({
    super.key,
    required this.partner,
    required this.balance,
  });

  final PartnerModel partner;

  /// Nullable — `null` means balance hasn't loaded yet; we still render the
  /// tile but show a subtle loading state instead of the amount.
  final PartnerBalanceEntity? balance;

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
    final amount = balance?.pendingBalance ?? 0;
    final orderCount = balance?.pendingOrderCount ?? 0;
    final loading = balance == null;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: () => context.push(
          RouteNames.partnerSettlementDetail,
          extra: partner,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        splashColor: partnerColor.withValues(alpha: 0.12),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              // Partner initial avatar
              Container(
                width: Responsive.r(40),
                height: Responsive.r(40),
                decoration: BoxDecoration(
                  color: partnerColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  partner.name.isEmpty ? '?' : partner.name.characters.first,
                  style: AppTypography.titleMedium.copyWith(
                    color: partnerColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.sm),
              // Partner name + amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(2)),
                    if (loading)
                      Text(
                        AppStrings.transferLoading,
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.textCaption,
                        ),
                      )
                    else
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${amount.toStringAsFixed(0)} ',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: AppStrings.currency,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textCaption,
                              ),
                            ),
                            if (orderCount > 0)
                              TextSpan(
                                text:
                                    '  •  ${AppStrings.settleFromOrders(orderCount)}',
                                style: AppTypography.captionSmall.copyWith(
                                  color: AppColors.textCaption,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: AppSizes.sm),
              // Settle button
              _SettleButton(
                partner: partner,
                amount: amount > 0 ? amount : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettleButton extends StatelessWidget {
  const _SettleButton({required this.partner, required this.amount});

  final PartnerModel partner;
  final double? amount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppSizes.chipRadius),
      child: InkWell(
        onTap: () =>
            context.push(RouteNames.createSettlement, extra: partner),
        borderRadius: BorderRadius.circular(AppSizes.chipRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                IconsaxPlusBold.send_1,
                color: AppColors.textOnPrimary,
                size: Responsive.r(14),
              ),
              SizedBox(width: Responsive.w(4)),
              Text(
                AppStrings.settleNow,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
