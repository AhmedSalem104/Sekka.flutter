import 'package:flutter/material.dart';
import '../constants/app_animations.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
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
        child: Row(
          children: List.generate(items.length, (index) {
            final isActive = index == currentIndex;
            final item = items[index];

            return Expanded(
              flex: isActive ? 5 : 2,
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: AppAnimations.fast,
                  curve: AppAnimations.defaultCurve,
                  margin: EdgeInsets.symmetric(horizontal: Responsive.w(2)),
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        isActive ? Responsive.w(12) : Responsive.w(4),
                    vertical: Responsive.h(8),
                  ),
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppColors.surface : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color:
                            isActive ? AppColors.primary : _inactiveColor,
                        size: Responsive.r(22),
                      ),
                      if (isActive) ...[
                        SizedBox(width: Responsive.w(8)),
                        Flexible(
                          child: Text(
                            item.label,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
