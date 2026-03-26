import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingIcon,
    this.leadingColor,
    this.trailing,
    this.trailingText,
    this.onTap,
    this.rating,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTap;
  final double? rating;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.md,
              horizontal: AppSizes.lg,
            ),
            child: Row(
              children: [
                // Leading
                _buildLeading(),
                SizedBox(width: AppSizes.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: AppSizes.xs / 2),
                        Text(
                          subtitle!,
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (rating != null) ...[
                        SizedBox(height: AppSizes.xs),
                        _buildRating(),
                      ],
                    ],
                  ),
                ),

                // Trailing
                if (trailing != null) trailing!,
                if (trailingText != null)
                  Text(
                    trailingText!,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                if (trailing == null && trailingText == null)
                  Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.textCaption,
                    size: AppSizes.iconLg,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(indent: AppSizes.lg + AppSizes.avatarMd + AppSizes.md),
      ],
    );
  }

  Widget _buildLeading() {
    if (leading != null) return leading!;

    if (leadingIcon != null) {
      return Container(
        width: AppSizes.avatarMd,
        height: AppSizes.avatarMd,
        decoration: BoxDecoration(
          color: (leadingColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Icon(
          leadingIcon,
          color: leadingColor ?? AppColors.primary,
          size: AppSizes.iconMd,
        ),
      );
    }

    // Default avatar placeholder
    return Container(
      width: AppSizes.avatarMd,
      height: AppSizes.avatarMd,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: AppSizes.iconMd,
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded,
            color: AppColors.warning, size: AppSizes.iconSm),
        SizedBox(width: AppSizes.xs / 2),
        Text(
          rating!.toStringAsFixed(1),
          style: AppTypography.captionSmall.copyWith(
            color: AppColors.textBody,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
