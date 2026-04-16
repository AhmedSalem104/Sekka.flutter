import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../bloc/settlement_bloc.dart';
import '../widgets/settlement_history_item.dart';

/// Full-history screen (separated from the main settlements tab).
///
/// Shows every settlement ever made, paginated. Future: filters by date
/// range, partner, and settlement type (all already supported by the bloc).
class SettlementHistoryScreen extends StatefulWidget {
  const SettlementHistoryScreen({super.key});

  @override
  State<SettlementHistoryScreen> createState() =>
      _SettlementHistoryScreenState();
}

class _SettlementHistoryScreenState extends State<SettlementHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SettlementBloc>().add(const SettlementsNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.settleFullHistoryLink),
      body: BlocBuilder<SettlementBloc, SettlementState>(
        builder: (context, state) {
          if (state is SettlementLoading) return const SekkaLoading();
          if (state is! SettlementLoaded) return const SizedBox.shrink();

          if (state.settlements.isEmpty) {
            return SekkaEmptyState(
              icon: IconsaxPlusLinear.money_send,
              title: AppStrings.noSettlements,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context
                  .read<SettlementBloc>()
                  .add(const SettlementRefreshRequested());
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.lg,
                AppSizes.pagePadding,
                AppSizes.xxxl,
              ),
              itemCount:
                  state.settlements.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: AppSizes.xs),
              itemBuilder: (context, index) {
                if (index >= state.settlements.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }
                return SettlementHistoryItem(
                  settlement: state.settlements[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
