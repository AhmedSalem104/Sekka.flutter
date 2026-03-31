import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/break_entity.dart';
import '../bloc/break_bloc.dart';
import 'break_energy_sheet.dart';

/// Card shown on home screen when the driver has an active (ongoing) break.
class ActiveBreakCard extends StatefulWidget {
  const ActiveBreakCard({
    super.key,
    required this.activeBreak,
    required this.isDark,
  });

  final BreakEntity activeBreak;
  final bool isDark;

  @override
  State<ActiveBreakCard> createState() => _ActiveBreakCardState();
}

class _ActiveBreakCardState extends State<ActiveBreakCard> {
  late Duration _elapsed;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.activeBreak.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.activeBreak.startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success,
            AppColors.success.withValues(alpha: 0.8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  IconsaxPlusBold.coffee,
                  color: AppColors.textOnPrimary,
                  size: AppSizes.iconMd,
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.breakActiveTitle,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.activeBreak.locationDescription,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSizes.lg),

          // Timer
          Center(
            child: Text(
              _formatDuration(_elapsed),
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),

          SizedBox(height: AppSizes.lg),

          // End break button
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<BreakBloc, BreakState>(
              builder: (context, state) {
                final isEnding = state is BreakEnding;
                return ElevatedButton(
                  onPressed: isEnding
                      ? null
                      : () => showBreakEnergySheet(context, isStart: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textOnPrimary,
                    foregroundColor: AppColors.success,
                    disabledBackgroundColor:
                        AppColors.textOnPrimary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                  ),
                  child: isEnding
                      ? SizedBox(
                          width: AppSizes.iconMd,
                          height: AppSizes.iconMd,
                          child: const CircularProgressIndicator(
                            color: AppColors.success,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppStrings.breakEndBreak,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
