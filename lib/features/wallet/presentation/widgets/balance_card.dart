import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/wallet_balance_entity.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance});

  final WalletBalanceEntity balance;

  String _formatAmount(double amount) =>
      NumberFormat('#,##0.00', 'ar_EG').format(amount);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.xxl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.currentBalance,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            '${_formatAmount(balance.totalBalance)} ${AppStrings.currency}',
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.textOnPrimary,
              fontSize: 28,
            ),
          ),
          SizedBox(height: AppSizes.xl),
          Row(
            children: [
              _MiniStat(
                label: AppStrings.cashOnHand,
                value: _formatAmount(balance.cashOnHand),
              ),
              SizedBox(width: AppSizes.xxl),
              _MiniStat(
                label: AppStrings.pendingAmount,
                value: _formatAmount(balance.pendingSettlements),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.captionSmall.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          '$value ${AppStrings.currency}',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
      ],
    );
  }
}
