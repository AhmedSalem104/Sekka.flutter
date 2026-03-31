import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';

/// Where the arrow points from.
enum HintArrowDirection { top, bottom }

/// A tooltip bubble with an arrow pointer that shows once per [hintKey].
/// Tap anywhere on it to dismiss. It won't show again.
///
/// [arrowDirection] controls whether the arrow points up (from top)
/// or down (from bottom). Default is [HintArrowDirection.top].
///
/// [arrowAlignment] controls horizontal position (0.0 = left, 1.0 = right).
/// Default is 0.15 (near start in RTL).
class SekkaHintTip extends StatefulWidget {
  const SekkaHintTip({
    super.key,
    required this.hintKey,
    required this.message,
    this.arrowDirection = HintArrowDirection.top,
    this.arrowAlignment = 0.15,
    this.onDismiss,
  });

  final String hintKey;
  final String message;
  final HintArrowDirection arrowDirection;
  final double arrowAlignment;
  final VoidCallback? onDismiss;

  @override
  State<SekkaHintTip> createState() => _SekkaHintTipState();
}

class _SekkaHintTipState extends State<SekkaHintTip>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  String get _prefsKey => 'hint_${widget.hintKey}';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _checkIfSeen();
  }

  Future<void> _checkIfSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_prefsKey) ?? false;
    if (!seen && mounted) {
      setState(() => _visible = true);
      _controller.forward();
    }
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    if (mounted) setState(() => _visible = false);
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTop = widget.arrowDirection == HintArrowDirection.top;
    final bubbleColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final arrowSize = Responsive.r(10);

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        alignment: Alignment(
          // Scale from where the arrow is
          1.0 - 2.0 * widget.arrowAlignment,
          isTop ? -1.0 : 1.0,
        ),
        child: GestureDetector(
          onTap: _dismiss,
          child: Padding(
            padding: EdgeInsets.only(
              top: isTop ? arrowSize : 0,
              bottom: isTop ? 0 : arrowSize,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Bubble
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(14),
                    vertical: Responsive.h(10),
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                                ? Colors.black
                                : AppColors.textCaption)
                            .withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.message,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textBodyDark
                                : AppColors.textBody,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Positioned(
                  top: isTop ? -arrowSize + 1 : null,
                  bottom: isTop ? null : -arrowSize + 1,
                  right: _arrowOffset(context, arrowSize),
                  child: CustomPaint(
                    size: Size(arrowSize * 2, arrowSize),
                    painter: _ArrowPainter(
                      color: bubbleColor,
                      shadowColor: (isDark
                              ? Colors.black
                              : AppColors.textCaption)
                          .withValues(alpha: 0.15),
                      pointUp: isTop,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _arrowOffset(BuildContext context, double arrowSize) {
    // RTL-aware: arrowAlignment 0.0 = start, 1.0 = end
    // We compute from the right since Arabic is RTL
    final available = MediaQuery.of(context).size.width -
        Responsive.w(40) - // page padding
        arrowSize * 2;
    return available * widget.arrowAlignment;
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    required this.color,
    required this.shadowColor,
    required this.pointUp,
  });

  final Color color;
  final Color shadowColor;
  final bool pointUp;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path();
    if (pointUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();

    // Shadow
    canvas.drawShadow(path, shadowColor, 4, false);
    // Fill
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) =>
      color != old.color || pointUp != old.pointUp;
}
