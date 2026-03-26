import 'package:flutter/material.dart';

/// Responsive utility that scales sizes based on screen dimensions.
///
/// Design base: 390 x 844 (iPhone 14 / typical Android)
/// All sizes in the app are designed for this base and scale proportionally.
///
/// Must call [init] once in the root widget builder before using any method.
class Responsive {
  Responsive._();

  static double _screenWidth = 390;
  static double _screenHeight = 844;
  static double _scaleWidth = 1.0;
  static double _scaleHeight = 1.0;
  static double _scaleText = 1.0;
  static double _pixelRatio = 1.0;
  static EdgeInsets _safePadding = EdgeInsets.zero;
  static bool _initialized = false;

  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  /// Must be called once in the root widget (app.dart builder).
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _safePadding = mediaQuery.padding;

    // Prevent division issues on very small or zero-size screens
    if (_screenWidth <= 0) _screenWidth = _designWidth;
    if (_screenHeight <= 0) _screenHeight = _designHeight;

    _scaleWidth = _screenWidth / _designWidth;
    _scaleHeight = _screenHeight / _designHeight;

    // Text scale uses width but clamped to prevent extreme scaling
    // on very small phones or tablets
    _scaleText = _scaleWidth.clamp(0.8, 1.3);
    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  // ── Screen Info ──

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  static double get pixelRatio => _pixelRatio;
  static EdgeInsets get safePadding => _safePadding;

  /// Is this a small phone (width < 360)?
  static bool get isSmallPhone => _screenWidth < 360;

  /// Is this a large phone or small tablet (width >= 600)?
  static bool get isTablet => _screenWidth >= 600;

  // ── Scaling Functions ──

  /// Scale by width (for horizontal dimensions, paddings, margins)
  static double w(double size) => size * _scaleWidth;

  /// Scale by height (for vertical dimensions)
  static double h(double size) => size * _scaleHeight;

  /// Scale for text (clamped to prevent readability issues)
  static double sp(double size) => size * _scaleText;

  /// Scale using the smaller factor (safe for both dimensions — icons, avatars)
  static double r(double size) {
    final scale = _scaleWidth < _scaleHeight ? _scaleWidth : _scaleHeight;
    return size * scale;
  }

  // ── Adaptive values ──

  /// Returns different values based on screen size category.
  static T adaptive<T>({
    required T small,
    required T medium,
    T? large,
  }) {
    if (_screenWidth < 360) return small;
    if (_screenWidth >= 600) return large ?? medium;
    return medium;
  }

  /// Horizontal padding that adapts to screen size.
  static double get horizontalPadding => adaptive<double>(
        small: 12.0,
        medium: 16.0,
        large: 24.0,
      );

  /// Max content width — prevents stretching on tablets.
  static double get maxContentWidth => _screenWidth >= 600 ? 500.0 : double.infinity;
}
