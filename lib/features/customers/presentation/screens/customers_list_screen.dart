import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_search_bar.dart';
import '../../../../shared/network/dio_client.dart';
import '../../data/repositories/customer_repository.dart';
import '../bloc/customers_bloc.dart';
import '../bloc/customers_event.dart';
import '../bloc/customers_state.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  late final TextEditingController _searchController;
  late final CustomersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    final dioClient = context.read<DioClient>();
    final repository = CustomerRepository(dioClient.dio);
    _bloc = CustomersBloc(repository: repository);
    _bloc.add(const CustomersLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(20),
                vertical: Responsive.h(16),
              ),
              child: Text(
                AppStrings.customers,
                style: AppTypography.headlineMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
              child: SekkaSearchBar(
                controller: _searchController,
                hint: AppStrings.searchCustomer,
                onChanged: (value) {
                  _bloc.add(CustomersSearchChanged(value));
                },
              ),
            ),

            SizedBox(height: Responsive.h(12)),

            // Customer list
            Expanded(
              child: BlocBuilder<CustomersBloc, CustomersState>(
                bloc: _bloc,
                builder: (context, state) {
                  return switch (state) {
                    CustomersInitial() ||
                    CustomersLoading() =>
                      const SekkaShimmerList(itemCount: 6),
                    CustomersError(:final message) => SekkaEmptyState(
                        icon: IconsaxPlusLinear.warning_2,
                        title: message,
                        actionLabel: 'جرّب تاني',
                        onAction: () {
                          _bloc.add(const CustomersLoadRequested());
                        },
                      ),
                    CustomersLoaded(:final customers) => customers.isEmpty
                        ? const SekkaEmptyState(
                            icon: IconsaxPlusLinear.profile_2user,
                            title: 'مفيش عملاء',
                            description: 'العملاء هيظهروا هنا لما تبدأ توصيل',
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(20),
                            ),
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              final displayName =
                                  customer.name ?? customer.phone;
                              final initial = displayName.characters.first;

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: Responsive.h(10),
                                ),
                                child: SekkaCard(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : AppColors.surface,
                                  padding: EdgeInsets.all(Responsive.w(16)),
                                  onTap: () {
                                    context.push(
                                      '/customers/${customer.id}',
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      // Avatar
                                      Container(
                                        width: Responsive.r(46),
                                        height: Responsive.r(46),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            initial,
                                            style: AppTypography.titleLarge
                                                .copyWith(
                                              color: AppColors.textOnPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: Responsive.w(14)),

                                      // Name + phone
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              displayName,
                                              style: AppTypography.titleMedium
                                                  .copyWith(
                                                color: isDark
                                                    ? AppColors
                                                        .textHeadlineDark
                                                    : AppColors.textHeadline,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(
                                              height: Responsive.h(4),
                                            ),
                                            Text(
                                              customer.phone,
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                color: isDark
                                                    ? AppColors
                                                        .textCaptionDark
                                                    : AppColors.textCaption,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Rating + blocked indicator
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                customer.averageRating
                                                    .toStringAsFixed(1),
                                                style: AppTypography.bodySmall
                                                    .copyWith(
                                                  color: isDark
                                                      ? AppColors
                                                          .textBodyDark
                                                      : AppColors.textBody,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(
                                                width: Responsive.w(4),
                                              ),
                                              Icon(
                                                IconsaxPlusBold.star_1,
                                                size: Responsive.r(16),
                                                color: AppColors.warning,
                                              ),
                                            ],
                                          ),
                                          if (customer.isBlocked) ...[
                                            SizedBox(
                                              height: Responsive.h(6),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Responsive.w(8),
                                                vertical: Responsive.h(2),
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.error
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Responsive.r(100),
                                                ),
                                              ),
                                              child: Text(
                                                AppStrings.blocked,
                                                style: AppTypography
                                                    .captionSmall
                                                    .copyWith(
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
