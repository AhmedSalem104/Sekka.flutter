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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        bottom: Responsive.safePadding.bottom + Responsive.h(10),
        left: Responsive.w(20),
        right: Responsive.w(20),
      ),
      child: Container(
        height: Responsive.h(60),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(Responsive.r(16)),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: isDark
              ? []
              : const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 24,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isActive = index == currentIndex;
            final item = items[index];

            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                curve: AppAnimations.defaultCurve,
                width: Responsive.w(60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textCaptionDark
                              : AppColors.textCaption),
                      size: Responsive.r(22),
                    ),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      item.label,
                      style: AppTypography.captionSmall.copyWith(
                        color: isActive
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption),
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
