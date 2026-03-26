import 'package:flutter/material.dart';

/// 3-level elevation system.
///
/// Light mode: uses black shadows.
/// Dark mode: uses surface lightening (no shadows on dark backgrounds).
abstract final class AppShadows {
  // ── Light Mode ──

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // 5%
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000), // 8%
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F000000), // 12%
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  // ── Dark Mode (no shadows — use elevated surface colors) ──

  static const List<BoxShadow> none = [];
}
