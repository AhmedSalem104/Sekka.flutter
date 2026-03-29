import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../constants/app_colors.dart';
import '../utils/responsive.dart';

/// Resolves image URLs — handles both full URLs and relative API paths.
String _resolveImageUrl(String url) {
  if (url.startsWith('http')) return url;
  return 'https://sekka.runasp.net$url';
}

class SekkaAvatar extends StatelessWidget {
  const SekkaAvatar({
    super.key,
    this.imageUrl,
    this.size = 56,
    this.showCameraOverlay = false,
    this.onTap,
  });

  final String? imageUrl;
  final double size;
  final bool showCameraOverlay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedSize = Responsive.r(size);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: resolvedSize,
            height: resolvedSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      _resolveImageUrl(imageUrl!),
                      fit: BoxFit.cover,
                      width: resolvedSize,
                      height: resolvedSize,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          if (showCameraOverlay)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: Responsive.r(28),
                height: Responsive.r(28),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Icon(
                  IconsaxPlusLinear.camera,
                  size: Responsive.r(14),
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        IconsaxPlusLinear.user,
        size: Responsive.r(size * 0.45),
        color: AppColors.primary,
      ),
    );
  }
}
