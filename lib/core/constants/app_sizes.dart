import '../utils/responsive.dart';

/// All sizes in the app.
///
/// Static values are used for const contexts (borders, etc.).
/// Use the responsive getters when you need screen-adaptive sizes.
abstract final class AppSizes {
  // ── Static (for const contexts & borders) ──

  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusPill = 100.0;

  /// ── Proportional Radius System ──
  /// All radii are ~25% of the element's height for visual consistency.
  /// Change [radiusRatio] to adjust all radii at once.
  static const double radiusRatio = 0.25;

  /// Button: height=56 → radius=14
  static double get buttonRadius => (56 * radiusRatio).roundToDouble();

  /// Card: height varies, uses a base of 64 → radius=16
  static const double cardRadius = 16.0;

  /// Input field: height=56 → radius=14
  static double get inputRadius => (56 * radiusRatio).roundToDouble();

  /// Chip/Category: height=40 → radius=10
  static double get chipRadius => (40 * radiusRatio).roundToDouble();

  /// FAB: height=48 → radius=12
  static double get fabRadius => (48 * radiusRatio).roundToDouble();

  /// Bottom sheet top corners: uses base of 80 → radius=20
  static double get sheetRadius => (80 * radiusRatio).roundToDouble();

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
