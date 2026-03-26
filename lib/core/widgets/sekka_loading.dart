import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/responsive.dart';

/// Full-screen centered loading indicator.
class SekkaLoading extends StatelessWidget {
  const SekkaLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 3,
      ),
    );
  }
}

/// Shimmer placeholder for a single card (used in lists).
class SekkaShimmerCard extends StatelessWidget {
  const SekkaShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.background,
      child: Container(
        height: Responsive.h(90),
        margin: EdgeInsets.only(bottom: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
      ),
    );
  }
}

/// Shimmer list — shows N placeholder cards.
class SekkaShimmerList extends StatelessWidget {
  const SekkaShimmerList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSizes.pagePadding),
      itemCount: itemCount,
      itemBuilder: (_, __) => const SekkaShimmerCard(),
    );
  }
}
