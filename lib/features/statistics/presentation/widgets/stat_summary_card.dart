import 'package:flutter/material.dart';
import 'package:sekka/core/core.dart';

class StatSummaryCard extends StatelessWidget {
  const StatSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.symmetric(
        vertical: Responsive.h(10),
        horizontal: Responsive.w(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color:
                  isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Responsive.h(4)),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: valueColor ??
                  (isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline),
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
