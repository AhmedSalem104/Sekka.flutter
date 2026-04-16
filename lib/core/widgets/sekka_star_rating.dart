import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../constants/app_colors.dart';
import '../utils/responsive.dart';

/// Interactive star rating row. Supports both tap and drag to set value.
/// Starts empty (0) by default; caller controls value via [rating] + [onChanged].
class SekkaStarRating extends StatelessWidget {
  const SekkaStarRating({
    super.key,
    required this.rating,
    required this.onChanged,
    this.count = 5,
    this.size,
    this.spacing,
    this.activeColor,
    this.inactiveColor,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final int count;
  final double? size;
  final double? spacing;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final starSize = size ?? Responsive.r(36);
    final pad = spacing ?? Responsive.w(6);
    final slot = starSize + pad * 2;
    final totalWidth = slot * count;

    void updateFromDx(double dx) {
      final clamped = dx.clamp(0.0, totalWidth);
      final value = (clamped / slot).ceil().clamp(0, count);
      if (value != rating) onChanged(value);
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => updateFromDx(d.localPosition.dx),
        onHorizontalDragStart: (d) => updateFromDx(d.localPosition.dx),
        onHorizontalDragUpdate: (d) => updateFromDx(d.localPosition.dx),
        child: SizedBox(
          width: totalWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(count, (i) {
              final filled = i < rating;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Icon(
                  filled ? IconsaxPlusBold.star_1 : IconsaxPlusLinear.star_1,
                  size: starSize,
                  color: filled
                      ? (activeColor ?? AppColors.warning)
                      : (inactiveColor ?? AppColors.textCaption),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
