import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';

/// The signature swipe-to-confirm widget for Sekka.
///
/// Used for critical actions: deliver order, confirm settlement, etc.
/// Prevents accidental taps — requires a deliberate swipe gesture.
class SekkaSwipeAction extends StatefulWidget {
  const SekkaSwipeAction({
    super.key,
    required this.label,
    required this.onCompleted,
    this.color,
    this.icon,
  });

  final String label;
  final VoidCallback onCompleted;
  final Color? color;
  final IconData? icon;

  @override
  State<SekkaSwipeAction> createState() => _SekkaSwipeActionState();
}

class _SekkaSwipeActionState extends State<SekkaSwipeAction>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _completed = false;

  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;

  double get _thumbSize => Responsive.r(48);
  double get _maxDrag =>
      Responsive.screenWidth - AppSizes.pagePadding * 2 - _thumbSize - 8;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_completed) return;
    setState(() {
      // RTL: drag goes left (negative), so we flip
      _dragPosition = (_dragPosition - details.delta.dx).clamp(0, _maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_completed) return;

    if (_dragPosition >= _maxDrag * 0.85) {
      // Complete!
      setState(() {
        _dragPosition = _maxDrag;
        _completed = true;
      });
      HapticFeedback.heavyImpact();
      widget.onCompleted();
    } else {
      // Reset with animation
      _resetAnimation = Tween<double>(
        begin: _dragPosition,
        end: 0,
      ).animate(CurvedAnimation(
        parent: _resetController,
        curve: Curves.easeOut,
      ))
        ..addListener(() {
          setState(() => _dragPosition = _resetAnimation.value);
        });
      _resetController
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.color ?? AppColors.primary;
    final progress = _maxDrag > 0 ? _dragPosition / _maxDrag : 0.0;

    return Container(
      height: AppSizes.swipeHeight,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.swipeRadius),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Label (fades out as you swipe)
          Center(
            child: Opacity(
              opacity: (1 - progress * 2).clamp(0, 1),
              child: Text(
                widget.label,
                style: AppTypography.titleMedium.copyWith(color: bgColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Completed check
          if (_completed)
            Center(
              child: Icon(
                Icons.check_rounded,
                color: bgColor,
                size: AppSizes.iconXl,
              ),
            ),

          // Draggable thumb
          Positioned(
            right: _dragPosition + 4,
            child: GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  color: _completed ? AppColors.success : bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _completed
                      ? Icons.check_rounded
                      : (widget.icon ?? Icons.arrow_forward_rounded),
                  color: AppColors.textOnPrimary,
                  size: AppSizes.iconMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
