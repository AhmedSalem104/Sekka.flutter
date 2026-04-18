import 'package:flutter/material.dart';
import '../constants/app_animations.dart';
import '../constants/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';

class SekkaBottomNavItem {
  const SekkaBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class SekkaBottomNav extends StatelessWidget {
  const SekkaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<SekkaBottomNavItem> items;

  static const Color _inactiveColor = Color(0xFFFFD1B3);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        bottom: Responsive.safePadding.bottom + Responsive.h(10),
        left: Responsive.w(16),
        right: Responsive.w(16),
      ),
      child: Container(
        height: Responsive.h(64),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(8),
          vertical: Responsive.h(6),
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(Responsive.r(20)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / items.length;
            final indicatorInset = Responsive.w(4);

            return Stack(
              children: [
                // Sliding white indicator — slides across instead of
                // fading per-tab, gives a continuous transition feel
                AnimatedPositionedDirectional(
                  duration: AppAnimations.normal,
                  curve: AppAnimations.defaultCurve,
                  start: currentIndex * itemWidth + indicatorInset,
                  top: 0,
                  bottom: 0,
                  width: itemWidth - indicatorInset * 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(Responsive.r(14)),
                    ),
                  ),
                ),
                // Tappable items on top of the indicator
                Positioned.fill(
                  child: Row(
                    children: List.generate(items.length, (index) {
                      final isActive = index == currentIndex;
                      final item = items[index];

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(index),
                          behavior: HitTestBehavior.opaque,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder<double>(
                                  duration: AppAnimations.normal,
                                  curve: AppAnimations.defaultCurve,
                                  tween: Tween(end: isActive ? 1.0 : 0.0),
                                  builder: (context, t, _) {
                                    return Icon(
                                      isActive
                                          ? item.activeIcon
                                          : item.icon,
                                      color: Color.lerp(
                                        _inactiveColor,
                                        AppColors.primary,
                                        t,
                                      ),
                                      size: Responsive.r(22) + t * 1.5,
                                    );
                                  },
                                ),
                                SizedBox(height: Responsive.h(3)),
                                AnimatedDefaultTextStyle(
                                  duration: AppAnimations.normal,
                                  curve: AppAnimations.defaultCurve,
                                  style:
                                      AppTypography.captionSmall.copyWith(
                                    fontSize: Responsive.sp(13),
                                    color: isActive
                                        ? AppColors.primary
                                        : _inactiveColor,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  child: Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
