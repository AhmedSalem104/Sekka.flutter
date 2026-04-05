import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_button.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({
    super.key,
    this.updateUrl,
    this.message,
  });

  final String? updateUrl;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Responsive.r(100),
                height: Responsive.r(100),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusLinear.arrow_up_1,
                  size: Responsive.r(48),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSizes.xxl),
              Text(
                AppStrings.forceUpdateTitle,
                style: AppTypography.headlineMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.md),
              Text(
                message ?? AppStrings.forceUpdateMessage,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.textBodyDark : AppColors.textBody,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.xxxl),
              SekkaButton(
                label: AppStrings.forceUpdateButton,
                icon: IconsaxPlusLinear.arrow_up_1,
                onPressed: () {
                  if (updateUrl != null) {
                    launchUrl(
                      Uri.parse(updateUrl!),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
