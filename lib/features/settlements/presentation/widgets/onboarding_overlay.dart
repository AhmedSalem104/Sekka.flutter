import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_button.dart';

const _kOnboardingKey = 'settlement_onboarding_seen';

/// Checks if the settlement onboarding has been seen.
Future<bool> hasSeenSettlementOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingKey) ?? false;
}

/// Marks the settlement onboarding as seen.
Future<void> markSettlementOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingKey, true);
}

class SettlementOnboardingOverlay extends StatefulWidget {
  const SettlementOnboardingOverlay({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<SettlementOnboardingOverlay> createState() =>
      _SettlementOnboardingOverlayState();
}

class _SettlementOnboardingOverlayState
    extends State<SettlementOnboardingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await markSettlementOnboardingSeen();
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: SlideTransition(
            position: _slideAnim,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppSizes.xxl),
              padding: EdgeInsets.all(AppSizes.xxl),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      IconsaxPlusLinear.money_send,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: AppSizes.xl),

                  // Title
                  Text(
                    AppStrings.onboardingHandoverTitle,
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.sm),

                  // Description
                  Text(
                    AppStrings.onboardingHandoverDesc,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.xxl),

                  // Steps
                  _StepRow(
                    number: '1',
                    icon: IconsaxPlusLinear.user,
                    text: AppStrings.onboardingStep1,
                  ),
                  SizedBox(height: AppSizes.md),
                  _StepRow(
                    number: '2',
                    icon: IconsaxPlusLinear.edit_2,
                    text: AppStrings.onboardingStep2,
                  ),
                  SizedBox(height: AppSizes.md),
                  _StepRow(
                    number: '3',
                    icon: IconsaxPlusLinear.tick_circle,
                    text: AppStrings.onboardingStep3,
                  ),
                  SizedBox(height: AppSizes.xxl),

                  // CTA
                  SekkaButton(
                    label: AppStrings.gotIt,
                    onPressed: _dismiss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.icon,
    required this.text,
  });

  final String number;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: AppSizes.md),
        Icon(icon, size: AppSizes.iconSm, color: AppColors.primary),
        SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
        ),
      ],
    );
  }
}
