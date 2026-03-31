import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../domain/entities/break_entity.dart';
import '../bloc/break_bloc.dart';

class BreakHistoryScreen extends StatefulWidget {
  const BreakHistoryScreen({super.key});

  @override
  State<BreakHistoryScreen> createState() => _BreakHistoryScreenState();
}

class _BreakHistoryScreenState extends State<BreakHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<BreakBloc>().add(const BreakHistoryRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BreakBloc>().add(const BreakHistoryNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.breakHistoryTitle),
      body: BlocBuilder<BreakBloc, BreakState>(
        builder: (context, state) {
          if (state is BreakHistoryLoading) {
            return const SekkaShimmerList(itemCount: 8);
          }

          if (state is BreakHistoryLoaded) {
            if (state.breaks.isEmpty) {
              return SekkaEmptyState(
                icon: IconsaxPlusLinear.coffee,
                title: AppStrings.breakHistoryEmpty,
                description: AppStrings.breakHistoryEmptyDesc,
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(AppSizes.pagePadding),
              itemCount:
                  state.breaks.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.breaks.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }
                return _BreakHistoryItem(
                  breakEntity: state.breaks[index],
                  isDark: isDark,
                );
              },
            );
          }

          if (state is BreakError) {
            return SekkaEmptyState(
              icon: IconsaxPlusLinear.warning_2,
              title: state.message,
              actionLabel: AppStrings.retry,
              onAction: () =>
                  context.read<BreakBloc>().add(const BreakHistoryRequested()),
            );
          }

          return const SekkaShimmerList(itemCount: 8);
        },
      ),
    );
  }
}

class _BreakHistoryItem extends StatelessWidget {
  const _BreakHistoryItem({
    required this.breakEntity,
    required this.isDark,
  });

  final BreakEntity breakEntity;
  final bool isDark;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _energyDot(int energy) {
    final color = switch (energy) {
      1 || 2 => AppColors.error,
      3 => AppColors.warning,
      _ => AppColors.success,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: i < energy
                ? color
                : (isDark ? AppColors.borderDark : AppColors.border),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + duration
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.coffee,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
                SizedBox(width: Responsive.w(6)),
                Text(
                  _formatDate(breakEntity.startTime),
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
                const Spacer(),
                if (breakEntity.durationMinutes != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Text(
                      '${breakEntity.durationMinutes} ${AppStrings.breakMinutes}',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Text(
                      AppStrings.breakActiveTitle,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: AppSizes.sm),

            // Time range
            Text(
              '${_formatTime(breakEntity.startTime)}'
              '${breakEntity.endTime != null ? ' – ${_formatTime(breakEntity.endTime!)}' : ''}',
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),

            // Location
            if (breakEntity.locationDescription.isNotEmpty) ...[
              SizedBox(height: AppSizes.xs),
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.location,
                    size: AppSizes.iconSm,
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  SizedBox(width: Responsive.w(4)),
                  Expanded(
                    child: Text(
                      breakEntity.locationDescription,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Energy levels
            if (breakEntity.energyAfter != null) ...[
              SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.breakEnergyBefore,
                          style: AppTypography.captionSmall.copyWith(
                            color: isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption,
                          ),
                        ),
                        SizedBox(height: Responsive.h(4)),
                        _energyDot(breakEntity.energyBefore),
                      ],
                    ),
                  ),
                  Icon(
                    IconsaxPlusLinear.arrow_left_2,
                    size: AppSizes.iconSm,
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppStrings.breakEnergyAfter,
                          style: AppTypography.captionSmall.copyWith(
                            color: isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption,
                          ),
                        ),
                        SizedBox(height: Responsive.h(4)),
                        _energyDot(breakEntity.energyAfter!),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
