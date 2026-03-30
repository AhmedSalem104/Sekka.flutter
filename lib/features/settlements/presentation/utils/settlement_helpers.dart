import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Maps settlement type integer to its Arabic label.
String settlementTypeLabel(int type) => switch (type) {
      0 => AppStrings.settlementCashToPartner,
      1 => AppStrings.settlementBankTransfer,
      2 => AppStrings.settlementVodafoneCash,
      3 => AppStrings.settlementInstapay,
      4 => AppStrings.settlementFawry,
      _ => AppStrings.settlementCashToPartner,
    };

/// Maps settlement type integer to its icon.
IconData settlementTypeIcon(int type) => switch (type) {
      0 => IconsaxPlusLinear.money_send,
      1 => IconsaxPlusLinear.bank,
      2 => IconsaxPlusLinear.mobile,
      3 => IconsaxPlusLinear.card_send,
      4 => IconsaxPlusLinear.receipt,
      _ => IconsaxPlusLinear.money_send,
    };

/// Maps settlement type integer to its color.
Color settlementTypeColor(int type) => switch (type) {
      0 => AppColors.settlementCash,
      1 => AppColors.settlementBank,
      2 => AppColors.settlementVodafone,
      3 => AppColors.settlementInstapay,
      4 => AppColors.settlementFawry,
      _ => AppColors.settlementCash,
    };

/// Formats a monetary amount with Arabic locale.
String formatAmount(double amount) =>
    NumberFormat('#,##0.00', 'ar_EG').format(amount);

/// Formats a DateTime to a readable Arabic-friendly string.
String formatSettlementDate(DateTime date) =>
    DateFormat('d MMM yyyy — h:mm a', 'ar').format(date);

/// Formats a DateTime to short date only.
String formatShortDate(DateTime date) =>
    DateFormat('d MMM', 'ar').format(date);
