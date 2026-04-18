import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/responsive.dart';

/// Typography system for Sekka.
///
/// Uses [Responsive.sp] for font sizes so text scales with screen size.
/// All styles use Tajawal font with line-height 1.5 for Arabic readability.
///
/// Usage:
/// - For const contexts (ThemeData), use the static base styles.
/// - For widget building, use the responsive getters.
abstract final class AppTypography {
  static const String fontFamily = 'Tajawal';
  static const double _lineHeight = 1.5;

  // ── Responsive Getters (use in widgets) ──

  // Headlines — Bold (700) — #1A202C
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(26),
        fontWeight: FontWeight.w700,
        color: AppColors.textHeadline,
        height: _lineHeight,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(22),
        fontWeight: FontWeight.w700,
        color: AppColors.textHeadline,
        height: _lineHeight,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(20),
        fontWeight: FontWeight.w700,
        color: AppColors.textHeadline,
        height: _lineHeight,
      );

  // Titles — SemiBold (600) — #1A202C
  static TextStyle get titleLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(18),
        fontWeight: FontWeight.w600,
        color: AppColors.textHeadline,
        height: _lineHeight,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(16),
        fontWeight: FontWeight.w600,
        color: AppColors.textHeadline,
        height: _lineHeight,
      );

  // Body — Medium (500) — #4A5568
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(18),
        fontWeight: FontWeight.w500,
        color: AppColors.textBody,
        height: _lineHeight,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(16),
        fontWeight: FontWeight.w500,
        color: AppColors.textBody,
        height: _lineHeight,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(14),
        fontWeight: FontWeight.w500,
        color: AppColors.textBody,
        height: _lineHeight,
      );

  // Captions — Medium (500) — #718096
  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(14),
        fontWeight: FontWeight.w500,
        color: AppColors.textCaption,
        height: _lineHeight,
      );

  static TextStyle get captionSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(12),
        fontWeight: FontWeight.w500,
        color: AppColors.textCaption,
        height: _lineHeight,
      );

  // Button Text
  static TextStyle get button => TextStyle(
        fontFamily: fontFamily,
        fontSize: Responsive.sp(18),
        fontWeight: FontWeight.w700,
        color: AppColors.textOnPrimary,
        height: _lineHeight,
      );

  // ── Static base styles (for ThemeData — uses fixed sizes) ──

  static const TextStyle headlineLargeBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeadline,
    height: _lineHeight,
  );

  static const TextStyle headlineMediumBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeadline,
    height: _lineHeight,
  );

  static const TextStyle headlineSmallBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeadline,
    height: _lineHeight,
  );

  static const TextStyle titleLargeBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeadline,
    height: _lineHeight,
  );

  static const TextStyle titleMediumBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeadline,
    height: _lineHeight,
  );

  static const TextStyle bodyLargeBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textBody,
    height: _lineHeight,
  );

  static const TextStyle bodyMediumBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textBody,
    height: _lineHeight,
  );

  static const TextStyle bodySmallBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textBody,
    height: _lineHeight,
  );

  static const TextStyle captionBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textCaption,
    height: _lineHeight,
  );

  static const TextStyle captionSmallBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textCaption,
    height: _lineHeight,
  );

  static const TextStyle buttonBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    height: _lineHeight,
  );
}
