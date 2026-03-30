import 'package:flutter/material.dart';
import 'package:sekka/core/core.dart';

class StatSummaryCard extends StatelessWidget {
  const StatSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.symmetric(
        vertical: Responsive.h(16),
        horizontal: Responsive.w(12),
      ),
      child: Column(
        children: [
          Container(
            width: Responsive.r(40),
            height: Responsive.r(40),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              icon,
              size: Responsive.r(20),
              color: iconColor ?? AppColors.primary,
            ),
          ),
          SizedBox(height: Responsive.h(10)),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: valueColor ??
                  (isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Responsive.h(4)),
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
