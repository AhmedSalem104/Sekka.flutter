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
import '../../../customers/data/models/customer_model.dart';
import '../../../customers/data/repositories/customer_repository.dart';
import '../../../customers/presentation/bloc/customers_bloc.dart';
import '../../../customers/presentation/bloc/customers_event.dart';
import '../../../customers/presentation/bloc/customers_state.dart';
import '../../../partners/data/models/partner_model.dart';
import '../../../partners/data/repositories/partner_repository.dart';
import '../../../partners/presentation/bloc/partners_bloc.dart';
import '../../../partners/presentation/bloc/partners_event.dart';
import '../../../partners/presentation/bloc/partners_state.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  late final CustomersBloc _customersBloc;
  late final PartnersBloc _partnersBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();

    final dioClient = context.read<DioClient>();

    _customersBloc = CustomersBloc(
      repository: CustomerRepository(dioClient.dio),
    )..add(const CustomersLoadRequested());

    _partnersBloc = PartnersBloc(
      repository: PartnerRepository(dioClient.dio),
    )..add(const PartnersLoadRequested());

    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    _searchController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _customersBloc.close();
    _partnersBloc.close();
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
            SizedBox(height: Responsive.h(16)),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
              child: Text(
                'جهات الاتصال',
                style: AppTypography.headlineMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
            ),

            SizedBox(height: Responsive.h(16)),

            // Tab bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
              child: Container(
                height: Responsive.h(44),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(Responsive.r(12)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(Responsive.r(10)),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.textOnPrimary,
                  unselectedLabelColor: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                  labelStyle: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: AppTypography.titleMedium,
                  labelPadding: EdgeInsets.zero,
                  padding: EdgeInsets.all(Responsive.w(3)),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconsaxPlusBold.profile_2user,
                            size: Responsive.r(18),
                          ),
                          SizedBox(width: Responsive.w(6)),
                          const Text(AppStrings.customers),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            IconsaxPlusBold.building_4,
                            size: Responsive.r(18),
                          ),
                          SizedBox(width: Responsive.w(6)),
                          const Text(AppStrings.partners),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: Responsive.h(12)),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
              child: SekkaSearchBar(
                controller: _searchController,
                hint: _tabController.index == 0
                    ? AppStrings.searchCustomer
                    : AppStrings.searchPartner,
                onChanged: (value) {
                  if (_tabController.index == 0) {
                    _customersBloc.add(CustomersSearchChanged(value));
                  } else {
                    _partnersBloc.add(PartnersSearchChanged(value));
                  }
                },
              ),
            ),

            SizedBox(height: Responsive.h(12)),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCustomersTab(isDark),
                  _buildPartnersTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Customers Tab ──

  Widget _buildCustomersTab(bool isDark) {
    return BlocBuilder<CustomersBloc, CustomersState>(
      bloc: _customersBloc,
      builder: (context, state) {
        return switch (state) {
          CustomersInitial() ||
          CustomersLoading() =>
            const SekkaShimmerList(itemCount: 6),
          CustomersError(:final message) => SekkaEmptyState(
              icon: IconsaxPlusLinear.warning_2,
              title: message,
              actionLabel: 'جرّب تاني',
              onAction: () =>
                  _customersBloc.add(const CustomersLoadRequested()),
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
                  itemBuilder: (_, index) =>
                      _buildCustomerItem(customers[index], isDark),
                ),
        };
      },
    );
  }

  Widget _buildCustomerItem(CustomerModel customer, bool isDark) {
    final displayName = customer.name ?? customer.phone;
    final initial = displayName.characters.first;

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(Responsive.w(16)),
        onTap: () => context.push('/customers/${customer.id}'),
        child: Row(
          children: [
            // Avatar
            Container(
              width: Responsive.r(46),
              height: Responsive.r(46),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(14)),

            // Name + phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    customer.phone,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            ),

            // Rating + blocked
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      customer.averageRating.toStringAsFixed(1),
                      style: AppTypography.bodySmall.copyWith(
                        color:
                            isDark ? AppColors.textBodyDark : AppColors.textBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: Responsive.w(4)),
                    Icon(
                      IconsaxPlusBold.star_1,
                      size: Responsive.r(16),
                      color: AppColors.warning,
                    ),
                  ],
                ),
                if (customer.isBlocked) ...[
                  SizedBox(height: Responsive.h(6)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(8),
                      vertical: Responsive.h(2),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Responsive.r(100)),
                    ),
                    child: Text(
                      AppStrings.blocked,
                      style: AppTypography.captionSmall.copyWith(
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
  }

  // ── Partners Tab ──

  Widget _buildPartnersTab(bool isDark) {
    return BlocBuilder<PartnersBloc, PartnersState>(
      bloc: _partnersBloc,
      builder: (context, state) {
        return switch (state) {
          PartnersInitial() ||
          PartnersLoading() =>
            const SekkaShimmerList(itemCount: 6),
          PartnersError(:final message) => SekkaEmptyState(
              icon: IconsaxPlusLinear.warning_2,
              title: message,
              actionLabel: 'جرّب تاني',
              onAction: () =>
                  _partnersBloc.add(const PartnersLoadRequested()),
            ),
          PartnersLoaded(:final partners) => partners.isEmpty
              ? const SekkaEmptyState(
                  icon: IconsaxPlusLinear.building_4,
                  title: 'مفيش شركاء',
                  description: 'مفيش شركاء متاحين دلوقتي',
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(20),
                  ),
                  itemCount: partners.length,
                  itemBuilder: (_, index) =>
                      _buildPartnerItem(partners[index], isDark),
                ),
        };
      },
    );
  }

  Widget _buildPartnerItem(PartnerModel partner, bool isDark) {
    final initial = partner.name.characters.first;
    Color partnerColor;
    try {
      partnerColor = Color(
        int.parse(partner.color.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      partnerColor = AppColors.primary;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(Responsive.w(16)),
        onTap: () => context.push('/partner-detail', extra: partner),
        child: Row(
          children: [
            // Colored avatar
            Container(
              width: Responsive.r(46),
              height: Responsive.r(46),
              decoration: BoxDecoration(
                color: partnerColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: AppTypography.titleLarge.copyWith(
                    color: partnerColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(14)),

            // Name + type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    _partnerTypeLabel(partner.partnerType),
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            ),

            // Verification badge
            _buildVerificationBadge(partner.verificationStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(int status) {
    final (label, color) = switch (status) {
      1 => (AppStrings.statusVerified, AppColors.success),
      2 => (AppStrings.statusRejected, AppColors.error),
      3 => (AppStrings.statusDocumentRequested, AppColors.warning),
      _ => (AppStrings.statusPending, AppColors.warning),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(10),
        vertical: Responsive.h(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Responsive.r(100)),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _partnerTypeLabel(int type) => switch (type) {
        0 => AppStrings.restaurantType,
        1 => AppStrings.shopType,
        2 => AppStrings.pharmacyType,
        3 => AppStrings.supermarketType,
        4 => AppStrings.warehouseType,
        5 => AppStrings.eCommerceType,
        _ => 'أخرى',
      };
}
