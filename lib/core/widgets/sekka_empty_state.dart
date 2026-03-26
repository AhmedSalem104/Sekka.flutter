import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';
import 'sekka_button.dart';

class SekkaEmptyState extends StatelessWidget {
  const SekkaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.r(80),
              height: Responsive.r(80),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Responsive.r(40),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.xl),
            Text(
              title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (description != null) ...[
              SizedBox(height: AppSizes.sm),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textCaption,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSizes.xxl),
              SekkaButton(
                label: actionLabel!,
                onPressed: onAction,
                width: Responsive.w(200),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
