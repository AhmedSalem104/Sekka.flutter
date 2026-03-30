import 'package:flutter/material.dart';
import 'package:sekka/core/core.dart';

class StatDetailRow extends StatelessWidget {
  const StatDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(10)),
      child: Row(
        children: [
          Container(
            width: Responsive.r(36),
            height: Responsive.r(36),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              icon,
              size: Responsive.r(18),
              color: iconColor ?? AppColors.primary,
            ),
          ),
          SizedBox(width: Responsive.w(12)),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
        ],
      ),
    );
  }
}
