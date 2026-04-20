import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_state.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.transaction});

  final TransactionEntity transaction;

  String get _title {
    if (AppStrings.currentLang == 'ar') {
      if (transaction.typeNameAr.isNotEmpty) return transaction.typeNameAr;
      return AppStrings.transactionTypeName(transaction.type);
    }
    if (transaction.typeName.isNotEmpty) return transaction.typeName;
    return AppStrings.transactionTypeName(transaction.type);
  }

  String? _resolveSubtitle(BuildContext context) {
    final ref = transaction.referenceId;
    if (ref != null && ref.isNotEmpty) {
      final ordersState = context.read<OrdersBloc>().state;
      if (ordersState is OrdersLoaded) {
        final match = ordersState.orders
            .where((o) => o.id == ref || o.orderNumber == ref)
            .firstOrNull;
        if (match != null && match.customerName != null && match.customerName!.isNotEmpty) {
          return match.customerName!;
        }
      }
    }
    // Try to extract name from description (e.g. "ربح من طلب #123 - أحمد")
    final desc = transaction.description;
    if (desc.isEmpty || desc == _title) return null;
    final dashIdx = desc.lastIndexOf(' - ');
    if (dashIdx != -1 && dashIdx + 3 < desc.length) {
      return desc.substring(dashIdx + 3).trim();
    }
    return desc;
  }

  (IconData, Color) get _iconAndColor {
    if (transaction.isIncome) {
      return (IconsaxPlusLinear.money_recive, AppColors.success);
    }
    if (transaction.isSettlement) {
      return (IconsaxPlusLinear.arrange_circle_2, AppColors.info);
    }
    return (IconsaxPlusLinear.money_send, AppColors.error);
  }

  String _formatAmount(double amount) {
    final formatted = NumberFormat('#,##0.00', AppStrings.currentLang == 'ar' ? 'ar_EG' : 'en_US').format(amount.abs());
    final prefix = amount > 0 ? '+' : '-';
    return '$prefix$formatted';
  }

  String _formatTime(DateTime dt) => DateFormat('hh:mm a', AppStrings.currentLang).format(dt);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (icon, color) = _iconAndColor;

    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: color, size: AppSizes.iconMd),
          ),
          SizedBox(width: AppSizes.md),

          // Description + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_resolveSubtitle(context) case final subtitle?) ...[
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: AppSizes.xs),
                Text(
                  _formatTime(transaction.createdAt),
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${_formatAmount(transaction.amount)} ${AppStrings.currency}',
            style: AppTypography.titleMedium.copyWith(
              color: transaction.isIncome ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
