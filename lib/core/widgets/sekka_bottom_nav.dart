import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
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
    return Container(
      height: AppSizes.bottomNavHeight + Responsive.safePadding.bottom,
      padding: EdgeInsets.only(bottom: Responsive.safePadding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;
          final item = items[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textCaption,
                    size: AppSizes.iconLg,
                  ),
                  SizedBox(height: AppSizes.xs),
                  // Active dot indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? Responsive.r(6) : 0,
                    height: isActive ? Responsive.r(6) : 0,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
