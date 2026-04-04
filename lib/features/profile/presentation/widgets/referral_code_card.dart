import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../referrals/data/repositories/referral_repository.dart';
import '../../../referrals/presentation/bloc/referrals_bloc.dart';
import '../../../referrals/presentation/bloc/referrals_event.dart';
import '../../../referrals/presentation/screens/referrals_screen.dart';

class ReferralCodeCard extends StatelessWidget {
  const ReferralCodeCard({
    super.key,
    required this.code,
  });

  final String code;

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _openReferrals(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              // Icon
              Container(
                width: Responsive.r(48),
                height: Responsive.r(48),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Responsive.r(12)),
                ),
                child: Icon(
                  IconsaxPlusLinear.gift,
                  color: AppColors.textOnPrimary,
                  size: Responsive.r(24),
                ),
              ),
              SizedBox(width: Responsive.w(14)),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.referralCode,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      code,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textOnPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                IconsaxPlusLinear.arrow_left_2,
                color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                size: Responsive.r(18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReferrals(BuildContext context) {
    final dio = context.read<DioClient>().dio;
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ReferralsBloc(
            repository: ReferralRepository(dio),
          )..add(const ReferralsLoadRequested()),
          child: const ReferralsScreen(),
        ),
      ),
    );
  }
}
