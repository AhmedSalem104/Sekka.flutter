import 'package:flutter/material.dart';

abstract final class AppColors {
  // ══════════════════════════════════════════
  //  LIGHT MODE
  // ══════════════════════════════════════════

  // Primary
  static const Color primary = Color(0xFFFC5D01);
  static const Color primaryLight = Color(0xFFFFF0E6);
  static const Color primaryDark = Color(0xFFD94E00);

  // Gradient
  static const Color gradientStart = Color(0xFFFC5D01);
  static const Color gradientEnd = Color(0xFFFF8534);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Backgrounds — Light
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  // Borders — Light
  static const Color border = Color(0xFFE2E8F0);

  // Text — Light
  static const Color textHeadline = Color(0xFF1A202C);
  static const Color textBody = Color(0xFF4A5568);
  static const Color textCaption = Color(0xFF718096);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ══════════════════════════════════════════
  //  DARK MODE
  // ══════════════════════════════════════════

  // Backgrounds — Dark
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Borders — Dark
  static const Color borderDark = Color(0xFF2D3748);

  // Text — Dark
  static const Color textHeadlineDark = Color(0xFFF7FAFC);
  static const Color textBodyDark = Color(0xFFA0AEC0);
  static const Color textCaptionDark = Color(0xFF718096);

  // ══════════════════════════════════════════
  //  SHARED (same in both modes)
  // ══════════════════════════════════════════

  // Status
  static const Color success = Color(0xFF38A169);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFECC94B);
  static const Color info = Color(0xFF3182CE);

  // Order Status
  static const Color statusNew = Color(0xFF3182CE);
  static const Color statusOnTheWay = Color(0xFFFC5D01);
  static const Color statusArrived = Color(0xFFECC94B);
  static const Color statusDelivered = Color(0xFF38A169);
  static const Color statusFailed = Color(0xFFE53E3E);
  static const Color statusCancelled = Color(0xFF718096);
  static const Color statusReturned = Color(0xFF805AD5);
  static const Color statusPostponed = Color(0xFFA0AEC0);

  // Settlement Type
  static const Color settlementCash = Color(0xFF38A169);   // green — cash
  static const Color settlementBank = Color(0xFF3182CE);   // blue — bank
  static const Color settlementVodafone = Color(0xFFE53E3E); // red — vodafone
  static const Color settlementInstapay = Color(0xFF805AD5); // purple — instapay
  static const Color settlementFawry = Color(0xFFECC94B);  // yellow — fawry

  // Shadows
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x12000000);

  // Logo colors (extracted from the logo)
  static const Color logoOrange = Color(0xFFFC5D01);
  static const Color logoNavy = Color(0xFF2D3748);
}
