import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_button.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
          child: Column(
            children: [
              const Spacer(),
              // Success icon placeholder
              Container(
                width: AppSizes.avatarLg * 2,
                height: AppSizes.avatarLg * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: AppSizes.avatarLg * 1.5,
                  color: AppColors.success,
                ),
              ),
              SizedBox(height: AppSizes.xxxl),
              Text(
                AppStrings.accountCreated,
                style: AppTypography.headlineLarge.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.md),
              Text(
                AppStrings.welcomeToSekka,
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SekkaButton(
                label: AppStrings.startNow,
                onPressed: () => context.go(RouteNames.main),
              ),
              SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
