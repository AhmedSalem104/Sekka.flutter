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
import '../../data/models/partner_model.dart';
import '../../data/repositories/partner_repository.dart';
import '../bloc/partners_bloc.dart';
import '../bloc/partners_event.dart';
import '../bloc/partners_state.dart';

class PartnersListScreen extends StatefulWidget {
  const PartnersListScreen({super.key});

  @override
  State<PartnersListScreen> createState() => _PartnersListScreenState();
}

class _PartnersListScreenState extends State<PartnersListScreen> {
  late final PartnerRepository _repository;
  late final PartnersBloc _bloc;

  @override
  void initState() {
    super.initState();
    final dioClient = context.read<DioClient>();
    _repository = PartnerRepository(dioClient.dio);
    _bloc = PartnersBloc(repository: _repository)
      ..add(const PartnersLoadRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
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
                  AppStrings.partners,
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
                  hint: AppStrings.searchPartner,
                  onChanged: (value) {
                    _bloc.add(PartnersSearchChanged(value));
                  },
                ),
              ),
              SizedBox(height: Responsive.h(12)),

              // List
              Expanded(
                child: BlocBuilder<PartnersBloc, PartnersState>(
                  builder: (context, state) => switch (state) {
                    PartnersInitial() ||
                    PartnersLoading() =>
                      const SekkaShimmerList(),
                    PartnersError(:final message) => SekkaEmptyState(
                        icon: IconsaxPlusLinear.warning_2,
                        title: message,
                        actionLabel: 'جرّب تاني',
                        onAction: () =>
                            _bloc.add(const PartnersLoadRequested()),
                      ),
                    PartnersLoaded(:final partners) when partners.isEmpty =>
                      const SekkaEmptyState(
                        icon: IconsaxPlusLinear.building_4,
                        title: 'مفيش شركاء',
                        description: 'مفيش شركاء متاحين دلوقتي',
                      ),
                    PartnersLoaded(:final partners) => ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(20),
                        ),
                        itemCount: partners.length,
                        itemBuilder: (context, index) =>
                            _buildPartnerItem(partners[index], isDark),
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerItem(PartnerModel partner, bool isDark) {
    final partnerColor = _parseColor(partner.color);

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        onTap: () => context.push(
          '/partner-detail',
          extra: partner,
        ),
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Row(
          children: [
            // Leading avatar
            Container(
              width: Responsive.r(48),
              height: Responsive.r(48),
              decoration: BoxDecoration(
                color: partnerColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  partner.name.isNotEmpty ? partner.name.characters.first : '',
                  style: AppTypography.titleLarge.copyWith(
                    color: partnerColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(14)),

            // Info
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
                  Row(
                    children: [
                      Text(
                        _partnerTypeLabel(partner.partnerType),
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textCaptionDark
                              : AppColors.textCaption,
                        ),
                      ),
                      if (partner.phone != null) ...[
                        SizedBox(width: Responsive.w(8)),
                        Container(
                          width: Responsive.r(4),
                          height: Responsive.r(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: Responsive.w(8)),
                        Flexible(
                          child: Text(
                            partner.phone!,
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
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: Responsive.w(8)),

            // Verification badge
            _buildVerificationBadge(partner.verificationStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(int status) {
    final (Color bgColor, Color textColor, String label) = switch (status) {
      1 => (
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
          AppStrings.statusVerified,
        ),
      2 => (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error,
          AppStrings.statusRejected,
        ),
      _ => (
          AppColors.warning.withValues(alpha: 0.12),
          AppColors.warning,
          AppStrings.statusPending,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(10),
        vertical: Responsive.h(4),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Responsive.r(100)),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
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
