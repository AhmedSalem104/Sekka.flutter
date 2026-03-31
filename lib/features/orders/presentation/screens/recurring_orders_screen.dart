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
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class RecurringOrdersScreen extends StatefulWidget {
  const RecurringOrdersScreen({super.key});

  @override
  State<RecurringOrdersScreen> createState() => _RecurringOrdersScreenState();
}

class _RecurringOrdersScreenState extends State<RecurringOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const RecurringOrdersLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        appBar: const SekkaAppBar(title: AppStrings.recurringOrders),
        body: BlocConsumer<OrdersBloc, OrdersState>(
          listener: (context, state) {
            if (state is OrdersLoaded && state.actionMessage != null) {
              final msg = state.actionMessage!;
              final isError = state.isActionError;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        msg,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                    backgroundColor:
                        isError ? AppColors.error : AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                );

              context.read<OrdersBloc>().add(const OrdersClearMessage());
            }
          },
          builder: (context, state) {
            if (state is! OrdersLoaded) return const SekkaLoading();

            if (state.isRecurringLoading && state.recurringOrders == null) {
              return const SekkaLoading();
            }

            final items = state.recurringOrders ?? [];

            if (items.isEmpty) {
              return const SekkaEmptyState(
                icon: IconsaxPlusLinear.repeat,
                title: AppStrings.noRecurringOrders,
                description: AppStrings.noRecurringOrdersHint,
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context
                    .read<OrdersBloc>()
                    .add(const RecurringOrdersLoadRequested());
                await context.read<OrdersBloc>().stream.firstWhere(
                      (s) =>
                          s is OrdersLoaded && !s.isRecurringLoading,
                    );
              },
              child: ListView.builder(
                padding: EdgeInsets.all(AppSizes.pagePadding),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _RecurringOrderCard(
                      data: items[index],
                      isDark: isDark,
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecurringOrderCard extends StatelessWidget {
  const _RecurringOrderCard({
    required this.data,
    required this.isDark,
  });

  final Map<String, dynamic> data;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final id = data['id'] as String? ?? '';
    final orderNumber = data['orderNumber'] as String? ?? '';
    final customerName = data['customerName'] as String? ?? '-';
    final address = data['deliveryAddress'] as String? ?? '';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final pattern = data['recurrencePattern'] as String? ?? '';
    final isPaused = data['isPaused'] as bool? ?? false;
    final nextDate = data['nextScheduledDate'] as String? ?? '';

    final patternLabel = switch (pattern) {
      'Daily' => AppStrings.recurrenceDaily,
      'Weekly' => AppStrings.recurrenceWeekly,
      'Monthly' => AppStrings.recurrenceMonthly,
      _ => pattern,
    };

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.md),
      child: SekkaCard(
        onTap: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderNumber,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textBodyDark
                              : AppColors.textBody,
                        ),
                      ),
                      SizedBox(height: AppSizes.xs),
                      Text(
                        customerName,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.textHeadlineDark
                              : AppColors.textHeadline,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isPaused
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    isPaused ? AppStrings.pauseRecurring : AppStrings.resumeRecurring,
                    style: AppTypography.bodySmall.copyWith(
                      color: isPaused ? AppColors.warning : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSizes.sm),

            // Address
            if (address.isNotEmpty)
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.location,
                    size: AppSizes.iconSm,
                    color: isDark ? AppColors.textBodyDark : AppColors.textBody,
                  ),
                  SizedBox(width: AppSizes.xs),
                  Expanded(
                    child: Text(
                      address,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

            SizedBox(height: AppSizes.sm),

            // Info row
            Row(
              children: [
                _InfoChip(
                  icon: IconsaxPlusLinear.money_recive,
                  label: '${amount.toStringAsFixed(0)} ${AppStrings.currency}',
                  isDark: isDark,
                ),
                SizedBox(width: AppSizes.md),
                _InfoChip(
                  icon: IconsaxPlusLinear.repeat,
                  label: patternLabel,
                  isDark: isDark,
                ),
                if (nextDate.isNotEmpty && !nextDate.startsWith('0001')) ...[
                  SizedBox(width: AppSizes.md),
                  _InfoChip(
                    icon: IconsaxPlusLinear.calendar_1,
                    label: nextDate.length >= 10
                        ? nextDate.substring(0, 10)
                        : nextDate,
                    isDark: isDark,
                  ),
                ],
              ],
            ),

            SizedBox(height: AppSizes.md),

            // Action buttons
            Row(
              children: [
                // Pause/Resume
                Expanded(
                  child: _ActionButton(
                    icon: isPaused
                        ? IconsaxPlusLinear.play
                        : IconsaxPlusLinear.pause,
                    label: isPaused
                        ? AppStrings.resumeRecurring
                        : AppStrings.pauseRecurring,
                    color: isPaused ? AppColors.success : AppColors.warning,
                    onTap: () {
                      if (isPaused) {
                        context.read<OrdersBloc>().add(
                              RecurringOrderResumeRequested(orderId: id),
                            );
                      } else {
                        context.read<OrdersBloc>().add(
                              RecurringOrderPauseRequested(orderId: id),
                            );
                      }
                    },
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                // Delete
                Expanded(
                  child: _ActionButton(
                    icon: IconsaxPlusLinear.trash,
                    label: AppStrings.deleteRecurring,
                    color: AppColors.error,
                    onTap: () => _confirmDelete(context, id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Text(AppStrings.deleteRecurring,
              style: AppTypography.titleMedium),
          content: Text(AppStrings.confirmDeleteRecurring,
              style: AppTypography.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppStrings.duplicateCancel,
                  style: AppTypography.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<OrdersBloc>().add(
                      RecurringOrderDeleteRequested(orderId: id),
                    );
              },
              child: Text(
                AppStrings.deleteRecurring,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppSizes.iconSm,
          color: AppColors.primary,
        ),
        SizedBox(width: Responsive.w(4)),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSizes.sm,
            horizontal: AppSizes.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.iconSm, color: color),
              SizedBox(width: AppSizes.xs),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
