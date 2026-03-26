import '../utils/responsive.dart';

/// All sizes in the app.
///
/// Static values are used for const contexts (borders, etc.).
/// Use the responsive getters when you need screen-adaptive sizes.
abstract final class AppSizes {
  // ── Static (for const contexts & borders) ──

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusPill = 100.0;

  static const double buttonRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double inputRadius = 12.0;
  static const double swipeRadius = 28.0;

  // ── Responsive Padding & Margin ──

  static double get xs => Responsive.w(4);
  static double get sm => Responsive.w(8);
  static double get md => Responsive.w(12);
  static double get lg => Responsive.w(16);
  static double get xl => Responsive.w(20);
  static double get xxl => Responsive.w(24);
  static double get xxxl => Responsive.w(32);

  /// Screen-adaptive horizontal page padding
  static double get pagePadding => Responsive.horizontalPadding;

  // ── Responsive Component Heights ──

  static double get buttonHeight => Responsive.h(56);
  static double get inputHeight => Responsive.h(56);
  static double get bottomNavHeight => Responsive.h(64);
  static double get swipeHeight => Responsive.h(56);

  static double get cardPadding => Responsive.w(16);

  // ── Responsive Icons ──

  static double get iconSm => Responsive.r(16);
  static double get iconMd => Responsive.r(20);
  static double get iconLg => Responsive.r(24);
  static double get iconXl => Responsive.r(32);

  // ── Responsive Avatars ──

  static double get avatarSm => Responsive.r(32);
  static double get avatarMd => Responsive.r(40);
  static double get avatarLg => Responsive.r(56);
}
