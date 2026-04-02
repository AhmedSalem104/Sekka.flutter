import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/dio_client.dart';
import '../../data/models/address_model.dart';
import '../../data/models/customer_behavior_model.dart';
import '../../data/models/customer_detail_model.dart';
import '../../data/models/customer_engagement_model.dart';
import '../../data/models/customer_insights_profile_model.dart';
import '../../data/models/customer_interests_model.dart';
import '../../data/models/customer_order_model.dart';
import '../../data/models/customer_rating_model.dart';
import '../../data/models/customer_recommendation_model.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/customer_insights_repository.dart';
import '../bloc/customer_detail_bloc.dart';
import '../widgets/rate_customer_sheet.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final CustomerDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    final dioClient = context.read<DioClient>();
    _bloc = CustomerDetailBloc(
      repository: CustomerRepository(dioClient.dio),
      insightsRepository: CustomerInsightsRepository(dioClient.dio),
    );
    _bloc.add(CustomerDetailLoadRequested(widget.customerId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.customerDetails),
      body: BlocConsumer<CustomerDetailBloc, CustomerDetailState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is CustomerDetailActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            CustomerDetailInitial() ||
            CustomerDetailLoading() =>
              const SekkaLoading(),
            CustomerDetailError(:final message) => SekkaEmptyState(
                icon: IconsaxPlusLinear.warning_2,
                title: message,
                actionLabel: 'جرّب تاني',
                onAction: () {
                  _bloc.add(
                    CustomerDetailLoadRequested(widget.customerId),
                  );
                },
              ),
            CustomerDetailActionSuccess() => const SekkaLoading(),
            CustomerDetailLoaded(
              :final customer,
              :final insightsProfile,
              :final engagement,
              :final interests,
              :final recommendations,
              :final orders,
              :final behavior,
              :final insightsInterests,
            ) =>
              _buildContent(
                customer,
                isDark,
                insightsProfile: insightsProfile,
                engagement: engagement,
                interests: interests,
                recommendations: recommendations,
                orders: orders,
                behavior: behavior,
                insightsInterests: insightsInterests,
              ),
          };
        },
      ),
    );
  }

  Widget _buildContent(
    CustomerDetailModel customer,
    bool isDark, {
    CustomerInsightsProfileModel? insightsProfile,
    CustomerEngagementModel? engagement,
    CustomerInterestsModel? interests,
    List<CustomerRecommendationModel>? recommendations,
    PagedData<CustomerOrderModel>? orders,
    CustomerBehaviorModel? behavior,
    List<Map<String, dynamic>>? insightsInterests,
  }) {
    final displayName = customer.name ?? customer.phone;

    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: Responsive.w(20),
            right: Responsive.w(20),
            bottom: Responsive.h(80),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.h(16)),

              // Profile header with stats
              _buildProfileHeader(customer, displayName, isDark),

              SizedBox(height: Responsive.h(24)),

              // RFM Score section
              if (insightsProfile != null) ...[
                _buildSectionTitle(AppStrings.rfmScore, isDark),
                SizedBox(height: Responsive.h(12)),
                _buildRfmSection(insightsProfile, isDark),
                SizedBox(height: Responsive.h(24)),
              ],

              // Engagement section
              if (engagement != null) ...[
                _buildSectionTitle(AppStrings.engagement, isDark),
                SizedBox(height: Responsive.h(12)),
                _buildEngagementSection(engagement, isDark),
                SizedBox(height: Responsive.h(24)),
              ],

              // Interests section
              if (interests != null &&
                  (interests.topCategories.isNotEmpty ||
                      interests.preferredPartners.isNotEmpty)) ...[
                _buildSectionTitle(AppStrings.interests, isDark),
                SizedBox(height: Responsive.h(12)),
                _buildInterestsSection(interests, isDark),
                SizedBox(height: Responsive.h(24)),
              ],

              // Behavior section
              if (behavior != null) ...[
                _buildSectionTitle(AppStrings.behaviorAnalysis, isDark),
                SizedBox(height: Responsive.h(12)),
                _buildBehaviorSection(behavior, isDark),
                SizedBox(height: Responsive.h(24)),
              ],

              // Insights Interests section
              if (insightsInterests != null &&
                  insightsInterests.isNotEmpty) ...[
                _buildSectionTitle(AppStrings.insightsInterests, isDark),
                SizedBox(height: Responsive.h(12)),
                _buildInsightsInterestsSection(insightsInterests, isDark),
                SizedBox(height: Responsive.h(24)),
              ],

              // Recommendations section
              if (recommendations != null &&
                  recommendations.isNotEmpty) ...[
                _buildSectionTitle(AppStrings.recommendations, isDark),
                SizedBox(height: Responsive.h(12)),
                ...recommendations.map(
                  (rec) => _buildRecommendationCard(rec, isDark),
                ),
                SizedBox(height: Responsive.h(24)),
              ],

              // Addresses section
              if (customer.addresses.isNotEmpty) ...[
                _buildSectionTitle(AppStrings.addresses, isDark),
                SizedBox(height: Responsive.h(12)),
                ...customer.addresses.map(
                  (address) => _buildAddressCard(address, isDark),
                ),
                SizedBox(height: Responsive.h(24)),
              ],

              // Recent orders section
              if (orders != null && orders.items.isNotEmpty) ...[
                _buildSectionTitle(
                  '${AppStrings.recentOrders} (${orders.totalCount})',
                  isDark,
                ),
                SizedBox(height: Responsive.h(12)),
                ...orders.items.map(
                  (order) => _buildOrderCard(order, isDark),
                ),
                SizedBox(height: Responsive.h(24)),
              ] else if (customer.recentOrders.isNotEmpty) ...[
                _buildSectionTitle(AppStrings.recentOrders, isDark),
                SizedBox(height: Responsive.h(12)),
                ...customer.recentOrders.map(
                  (order) => _buildOrderCard(order, isDark),
                ),
                SizedBox(height: Responsive.h(24)),
              ],

              // Ratings section
              if (customer.ratings.isNotEmpty) ...[
                _buildSectionTitle(AppStrings.averageRating, isDark),
                SizedBox(height: Responsive.h(12)),
                ...customer.ratings.map(
                  (rating) => _buildRatingCard(rating, isDark),
                ),
                SizedBox(height: Responsive.h(24)),
              ],

              SizedBox(height: Responsive.h(20)),
            ],
          ),
        ),

        // Sticky bottom action buttons
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(20),
              vertical: Responsive.h(12),
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textHeadline.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _buildActionButtons(customer, isDark),
            ),
          ),
        ),
      ],
    );
  }

  // ── Profile Header ──

  Widget _buildProfileHeader(
    CustomerDetailModel customer,
    String displayName,
    bool isDark,
  ) {
    final initial = displayName.characters.first;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        children: [
          // Top row: Avatar + Name/Phone + Call/WhatsApp
          Row(
            children: [
              // Avatar
              Container(
                width: Responsive.r(52),
                height: Responsive.r(52),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(14)),

              // Name + Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.h(4)),
                    Text(
                      customer.phone,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                    if (customer.isBlocked) ...[
                      SizedBox(height: Responsive.h(6)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(8),
                          vertical: Responsive.h(2),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusPill),
                        ),
                        child: Text(
                          AppStrings.blocked,
                          style: AppTypography.captionSmall.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Call + WhatsApp
              GestureDetector(
                onTap: () => PhoneLauncher.call(customer.phone),
                child: Container(
                  padding: EdgeInsets.all(Responsive.w(10)),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconsaxPlusBold.call,
                    size: Responsive.r(18),
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(8)),
              GestureDetector(
                onTap: () => PhoneLauncher.whatsApp(customer.phone),
                child: Container(
                  padding: EdgeInsets.all(Responsive.w(10)),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconsaxPlusLinear.message,
                    size: Responsive.r(18),
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.h(16)),

          // Divider
          Container(
            height: 1,
            color: AppColors.textOnPrimary.withValues(alpha: 0.15),
          ),
          SizedBox(height: Responsive.h(14)),

          // Stats row
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${customer.totalDeliveries}',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      AppStrings.totalDeliveries,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: Responsive.h(32),
                color: AppColors.textOnPrimary.withValues(alpha: 0.15),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${customer.successfulDeliveries}',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      AppStrings.successfulDeliveries,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: Responsive.h(32),
                color: AppColors.textOnPrimary.withValues(alpha: 0.15),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IconsaxPlusBold.star_1,
                          size: Responsive.r(14),
                          color: AppColors.warning,
                        ),
                        SizedBox(width: Responsive.w(4)),
                        Text(
                          customer.averageRating.toStringAsFixed(1),
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      AppStrings.averageRating,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats Row ──

  Widget _buildStatsRow(CustomerDetailModel customer, bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          icon: IconsaxPlusBold.box_1,
          value: '${customer.totalDeliveries}',
          label: AppStrings.totalDeliveries,
          color: AppColors.primary,
          isDark: isDark,
        ),
        SizedBox(width: Responsive.w(10)),
        _buildStatCard(
          icon: IconsaxPlusBold.tick_circle,
          value: '${customer.successfulDeliveries}',
          label: AppStrings.successfulDeliveries,
          color: AppColors.success,
          isDark: isDark,
        ),
        SizedBox(width: Responsive.w(10)),
        _buildStatCard(
          icon: IconsaxPlusBold.star_1,
          value: customer.averageRating.toStringAsFixed(1),
          label: AppStrings.averageRating,
          color: AppColors.warning,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.symmetric(
          vertical: Responsive.h(14),
          horizontal: Responsive.w(8),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.w(8)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Responsive.r(18),
                color: color,
              ),
            ),
            SizedBox(height: Responsive.h(8)),
            Text(
              value,
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: Responsive.h(2)),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(
                color:
                    isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Title ──

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: Responsive.w(4),
          height: Responsive.h(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(Responsive.r(2)),
          ),
        ),
        SizedBox(width: Responsive.w(10)),
        Text(
          title,
          style: AppTypography.titleLarge.copyWith(
            color:
                isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── RFM Score Section ──

  Widget _buildRfmSection(
    CustomerInsightsProfileModel profile,
    bool isDark,
  ) {
    final rfm = profile.rfmScore;
    final segmentLabel = _rfmSegmentLabel(rfm.segment);
    final segmentColor = _rfmSegmentColor(rfm.segment);
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        children: [
          // Segment + Engagement row
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(12),
                  vertical: Responsive.h(6),
                ),
                decoration: BoxDecoration(
                  color: segmentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  segmentLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: segmentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (profile.engagementLevel.isNotEmpty) ...[
                SizedBox(width: Responsive.w(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(12),
                    vertical: Responsive.h(6),
                  ),
                  decoration: BoxDecoration(
                    color: _engagementColor(profile.engagementLevel)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    _engagementLabel(profile.engagementLevel),
                    style: AppTypography.bodySmall.copyWith(
                      color: _engagementColor(profile.engagementLevel),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${profile.totalOrders} طلب',
                style: AppTypography.bodySmall.copyWith(
                  color: captionColor,
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.h(16)),

          // RFM bars — compact
          Row(
            children: [
              _buildRfmBar(
                AppStrings.recency,
                rfm.recencyScore,
                AppColors.textHeadline.withValues(alpha: 0.6),
                isDark,
              ),
              SizedBox(width: Responsive.w(10)),
              _buildRfmBar(
                AppStrings.frequency,
                rfm.frequencyScore,
                AppColors.textHeadline.withValues(alpha: 0.6),
                isDark,
              ),
              SizedBox(width: Responsive.w(10)),
              _buildRfmBar(
                AppStrings.monetary,
                rfm.monetaryScore,
                AppColors.textHeadline.withValues(alpha: 0.6),
                isDark,
              ),
            ],
          ),

          SizedBox(height: Responsive.h(12)),

          // Lifetime value
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${AppStrings.lifetimeValue}: ',
                style: AppTypography.bodySmall.copyWith(color: captionColor),
              ),
              Text(
                '${profile.lifetimeValue.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRfmBar(
    String label,
    int score,
    Color color,
    bool isDark,
  ) {
    const maxScore = 5;
    final ratio = score / maxScore;

    return Expanded(
      child: Column(
        children: [
          Text(
            '$score',
            style: AppTypography.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: Responsive.h(6)),
          ClipRRect(
            borderRadius: BorderRadius.circular(Responsive.r(4)),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: Responsive.h(6),
              backgroundColor: isDark
                  ? AppColors.borderDark
                  : AppColors.border.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          SizedBox(height: Responsive.h(4)),
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: isDark
                  ? AppColors.textCaptionDark
                  : AppColors.textCaption,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _rfmSegmentLabel(String segment) => switch (segment.toLowerCase()) {
        'new' => 'عميل جديد',
        'champions' || 'champion' => 'بطل',
        'loyal' || 'loyal_customers' => 'عميل وفي',
        'potential' || 'potential_loyalist' => 'ممكن يبقى وفي',
        'at_risk' || 'atrisk' => 'ممكن نخسره',
        'lost' || 'hibernating' => 'عميل راح',
        'cant_lose' => 'لازم نحافظ عليه',
        _ => segment,
      };

  Color _rfmSegmentColor(String segment) => switch (segment.toLowerCase()) {
        'new' => AppColors.info,
        'champions' || 'champion' => AppColors.success,
        'loyal' || 'loyal_customers' => AppColors.success,
        'potential' || 'potential_loyalist' => AppColors.primary,
        'at_risk' || 'atrisk' => AppColors.warning,
        'lost' || 'hibernating' => AppColors.error,
        'cant_lose' => AppColors.error,
        _ => AppColors.textCaption,
      };

  String _engagementLabel(String level) => switch (level.toLowerCase()) {
        'high' => 'عالي',
        'medium' => 'متوسط',
        'low' => 'منخفض',
        _ => level,
      };

  Color _engagementColor(String level) => switch (level.toLowerCase()) {
        'high' => AppColors.success,
        'medium' => AppColors.warning,
        'low' => AppColors.error,
        _ => AppColors.textCaption,
      };

  // ── Engagement Section ──

  Widget _buildEngagementSection(
    CustomerEngagementModel engagement,
    bool isDark,
  ) {
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;
    final headlineColor =
        isDark ? AppColors.textHeadlineDark : AppColors.textHeadline;

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        children: [
          // Level + Score + Orders inline
          Row(
            children: [
              Text(AppStrings.engagement,
                  style: AppTypography.bodySmall.copyWith(color: captionColor)),
              SizedBox(width: Responsive.w(6)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(10),
                  vertical: Responsive.h(4),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  engagement.level,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${engagement.engagementScore}',
                style: AppTypography.titleLarge.copyWith(
                  color: headlineColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' نقطة',
                style: AppTypography.bodySmall.copyWith(color: captionColor),
              ),
            ],
          ),

          SizedBox(height: Responsive.h(14)),

          // Stats row — flat
          Row(
            children: [
              Expanded(
                child: _buildInlineDetail(
                  AppStrings.orders,
                  '${engagement.totalOrders}',
                  headlineColor,
                  captionColor,
                ),
              ),
              Expanded(
                child: _buildInlineDetail(
                  AppStrings.daysSinceLastOrder,
                  engagement.daysSinceLastOrder >= 0
                      ? '${engagement.daysSinceLastOrder} يوم'
                      : '-',
                  headlineColor,
                  captionColor,
                ),
              ),
            ],
          ),
          if (engagement.lastInteraction != null) ...[
            SizedBox(height: Responsive.h(8)),
            Row(
              children: [
                Icon(IconsaxPlusLinear.clock,
                    size: Responsive.r(12), color: captionColor),
                SizedBox(width: Responsive.w(4)),
                Text(
                  '${AppStrings.lastInteraction}: ${_formatDate(engagement.lastInteraction!)}',
                  style: AppTypography.captionSmall.copyWith(
                    color: captionColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineDetail(
    String label,
    String value,
    Color headlineColor,
    Color captionColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.captionSmall.copyWith(color: captionColor)),
        SizedBox(height: Responsive.h(2)),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: headlineColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Interests Section ──

  Widget _buildInterestsSection(CustomerInterestsModel interests, bool isDark) {
    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (interests.topCategories.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  IconsaxPlusBold.category_2,
                  size: Responsive.r(16),
                  color: AppColors.primary,
                ),
                SizedBox(width: Responsive.w(6)),
                Text(
                  'بيحب إيه',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(10)),
            Wrap(
              spacing: Responsive.w(8),
              runSpacing: Responsive.h(8),
              children: interests.topCategories.map((cat) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(14),
                    vertical: Responsive.h(8),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: Responsive.h(16)),
            Divider(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.border.withValues(alpha: 0.3),
              height: 1,
            ),
            SizedBox(height: Responsive.h(16)),
          ],
          if (interests.preferredPartners.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  IconsaxPlusBold.shop,
                  size: Responsive.r(16),
                  color: AppColors.info,
                ),
                SizedBox(width: Responsive.w(6)),
                Text(
                  'بيطلب من مين',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.h(10)),
            ...interests.preferredPartners.take(3).map((p) {
              return Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(8)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(12),
                    vertical: Responsive.h(10),
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(Responsive.w(6)),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(Responsive.r(8)),
                        ),
                        child: Icon(
                          IconsaxPlusLinear.shop,
                          size: Responsive.r(14),
                          color: AppColors.info,
                        ),
                      ),
                      SizedBox(width: Responsive.w(10)),
                      Expanded(
                        child: Text(
                          p.partnerName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textHeadlineDark
                                : AppColors.textHeadline,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(10),
                          vertical: Responsive.h(4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusPill),
                        ),
                        child: Text(
                          '${p.orderCount} طلب',
                          style: AppTypography.captionSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: Responsive.h(8)),
          ],

          // متوسط قيمة الطلب
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: Responsive.h(10),
              horizontal: Responsive.w(12),
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  IconsaxPlusBold.money_2,
                  size: Responsive.r(16),
                  color: AppColors.success,
                ),
                SizedBox(width: Responsive.w(8)),
                Text(
                  'متوسط الطلب: ',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
                Text(
                  '${interests.averageOrderValue.toStringAsFixed(0)} ${AppStrings.currency}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Recommendation Card ──

  Widget _buildRecommendationCard(
    CustomerRecommendationModel rec,
    bool isDark,
  ) {
    final priorityColor = switch (rec.priority?.toLowerCase()) {
      'high' => AppColors.error,
      'medium' => AppColors.warning,
      _ => AppColors.info,
    };

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with priority badge
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.lamp_charge,
                  size: Responsive.r(18),
                  color: priorityColor,
                ),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Text(
                    rec.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                      fontWeight: rec.isRead ? FontWeight.w400 : FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (rec.priority != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(8),
                      vertical: Responsive.h(3),
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Text(
                      rec.priority!,
                      style: AppTypography.captionSmall.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            // Description
            if (rec.description != null && rec.description!.isNotEmpty) ...[
              SizedBox(height: Responsive.h(8)),
              Text(
                rec.description!,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: Responsive.h(12)),

            // Action buttons
            if (!rec.isDismissed && !rec.isActedOn)
              Row(
                children: [
                  if (!rec.isRead)
                    _buildRecActionButton(
                      label: AppStrings.markAsRead,
                      icon: IconsaxPlusLinear.eye,
                      color: AppColors.info,
                      onTap: () => _bloc.add(RecommendationReadRequested(
                        customerId: widget.customerId,
                        recommendationId: rec.id,
                      )),
                    ),
                  if (!rec.isRead) SizedBox(width: Responsive.w(8)),
                  _buildRecActionButton(
                    label: AppStrings.actOnIt,
                    icon: IconsaxPlusLinear.tick_circle,
                    color: AppColors.success,
                    onTap: () => _bloc.add(RecommendationActRequested(
                      customerId: widget.customerId,
                      recommendationId: rec.id,
                    )),
                  ),
                  SizedBox(width: Responsive.w(8)),
                  _buildRecActionButton(
                    label: AppStrings.dismiss,
                    icon: IconsaxPlusLinear.close_circle,
                    color: AppColors.error,
                    onTap: () => _bloc.add(RecommendationDismissRequested(
                      customerId: widget.customerId,
                      recommendationId: rec.id,
                    )),
                  ),
                ],
              ),

            // Status indicators for already actioned
            if (rec.isActedOn)
              _buildRecStatusBadge('اتنفّذ', AppColors.success),
            if (rec.isDismissed)
              _buildRecStatusBadge('اتجاهل', AppColors.textCaption),
          ],
        ),
      ),
    );
  }

  Widget _buildRecActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(8)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Responsive.r(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: Responsive.r(14), color: color),
              SizedBox(width: Responsive.w(4)),
              Text(
                label,
                style: AppTypography.captionSmall.copyWith(
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

  Widget _buildRecStatusBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(12),
        vertical: Responsive.h(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
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

  // ── Behavior Section ──

  Widget _buildBehaviorSection(CustomerBehaviorModel behavior, bool isDark) {
    final timeLabel = _translateTime(behavior.preferredOrderTime);
    final dayLabel = _translateDay(behavior.preferredDayOfWeek);
    final tierLabel = _translateTier(behavior.spendingTier);
    final tierColor = _tierColor(behavior.spendingTier);
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;
    final headlineColor =
        isDark ? AppColors.textHeadlineDark : AppColors.textHeadline;

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: spending tier + avg order value
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(12),
                  vertical: Responsive.h(6),
                ),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  tierLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: tierColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${behavior.averageOrderValue.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' / طلب',
                style: AppTypography.captionSmall.copyWith(
                  color: captionColor,
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.h(14)),

          // Row 1: time + day
          Row(
            children: [
              Expanded(
                child: _buildInlineDetail(
                  AppStrings.preferredOrderTime,
                  timeLabel,
                  headlineColor,
                  captionColor,
                ),
              ),
              Expanded(
                child: _buildInlineDetail(
                  AppStrings.preferredDay,
                  dayLabel,
                  headlineColor,
                  captionColor,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(10)),
          // Row 2: frequency
          Row(
            children: [
              Expanded(
                child: _buildInlineDetail(
                  AppStrings.orderFrequency,
                  '${behavior.orderFrequencyPerMonth}/شهر',
                  headlineColor,
                  captionColor,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),

          // Preferred areas
          if (behavior.preferredAreas.isNotEmpty) ...[
            SizedBox(height: Responsive.h(12)),
            Wrap(
              spacing: Responsive.w(6),
              runSpacing: Responsive.h(6),
              children: behavior.preferredAreas.map((area) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(10),
                    vertical: Responsive.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textHeadline.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    area,
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Patterns
          if (behavior.patterns.isNotEmpty) ...[
            SizedBox(height: Responsive.h(10)),
            ...behavior.patterns.map((pattern) {
              return Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: AppTypography.bodySmall
                            .copyWith(color: captionColor)),
                    Expanded(
                      child: Text(
                        pattern,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textBodyDark
                              : AppColors.textBody,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _translateTime(String? time) => switch (time?.toLowerCase()) {
        'morning' => 'الصبح',
        'afternoon' => 'الضهر',
        'evening' => 'بالليل',
        'night' => 'آخر الليل',
        _ => time ?? '-',
      };

  String _translateDay(String? day) => switch (day?.toLowerCase()) {
        'saturday' => 'السبت',
        'sunday' => 'الأحد',
        'monday' => 'الإثنين',
        'tuesday' => 'الثلاثاء',
        'wednesday' => 'الأربعاء',
        'thursday' => 'الخميس',
        'friday' => 'الجمعة',
        _ => day ?? '-',
      };

  String _translateTier(String tier) => switch (tier.toLowerCase()) {
        'low' => 'منخفض',
        'medium' => 'متوسط',
        'high' => 'عالي',
        'premium' => 'مميز',
        _ => tier,
      };

  Color _tierColor(String tier) => switch (tier.toLowerCase()) {
        'low' => AppColors.textCaption,
        'medium' => AppColors.warning,
        'high' => AppColors.success,
        'premium' => AppColors.primary,
        _ => AppColors.textCaption,
      };

  // ── Insights Interests Section ──

  Widget _buildInsightsInterestsSection(
    List<Map<String, dynamic>> interests,
    bool isDark,
  ) {
    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: interests.map((item) {
          final name = item['name'] as String? ??
              item['interest'] as String? ??
              item['category'] as String? ??
              item.values.first.toString();
          final count = item['count'] as int? ??
              item['orderCount'] as int? ??
              item['score'] as int?;
          final percentage = (item['percentage'] as num?)?.toDouble();

          return Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(8)),
            child: Row(
              children: [
                Icon(
                  IconsaxPlusLinear.heart,
                  size: Responsive.r(16),
                  color: AppColors.primary,
                ),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Text(
                    name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                  ),
                ),
                if (count != null)
                  Text(
                    '$count',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (percentage != null) ...[
                  SizedBox(width: Responsive.w(6)),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Address Card ──

  Widget _buildAddressCard(AddressModel address, bool isDark) {
    final addressTypeLabel = _addressTypeLabel(address.addressType);
    final typeIcon = switch (address.addressType) {
      0 => IconsaxPlusBold.home_2,
      1 => IconsaxPlusBold.briefcase,
      2 => IconsaxPlusBold.shop,
      3 => IconsaxPlusBold.coffee,
      4 => IconsaxPlusBold.box_1,
      _ => IconsaxPlusBold.location,
    };

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(10)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Responsive.r(12)),
                  ),
                  child: Icon(
                    typeIcon,
                    size: Responsive.r(20),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: Responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.addressText,
                              style: AppTypography.titleMedium.copyWith(
                                color: isDark
                                    ? AppColors.textHeadlineDark
                                    : AppColors.textHeadline,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: Responsive.w(8)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(10),
                              vertical: Responsive.h(4),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusPill),
                            ),
                            child: Text(
                              addressTypeLabel,
                              style: AppTypography.captionSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (address.landmarks != null &&
                          address.landmarks!.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(6)),
                        Row(
                          children: [
                            Icon(
                              IconsaxPlusLinear.map_1,
                              size: Responsive.r(12),
                              color: isDark
                                  ? AppColors.textCaptionDark
                                  : AppColors.textCaption,
                            ),
                            SizedBox(width: Responsive.w(4)),
                            Expanded(
                              child: Text(
                                address.landmarks!,
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
                      if (address.deliveryNotes != null &&
                          address.deliveryNotes!.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(6)),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(Responsive.w(8)),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.backgroundDark
                                : AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                IconsaxPlusLinear.note_1,
                                size: Responsive.r(12),
                                color: AppColors.warning,
                              ),
                              SizedBox(width: Responsive.w(4)),
                              Expanded(
                                child: Text(
                                  address.deliveryNotes!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textBodyDark
                                        : AppColors.textBody,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _addressTypeLabel(int type) {
    return switch (type) {
      0 => AppStrings.addressHome,
      1 => AppStrings.addressWork,
      2 => AppStrings.addressShop,
      3 => AppStrings.addressRestaurant,
      4 => AppStrings.addressWarehouse,
      _ => AppStrings.addressOther,
    };
  }

  // ── Order Card ──

  Widget _buildOrderCard(CustomerOrderModel order, bool isDark) {
    final orderStatus = _mapStatus(order.status);

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Row(
          children: [
            // Order icon
            Container(
              padding: EdgeInsets.all(Responsive.w(10)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Responsive.r(12)),
              ),
              child: Icon(
                IconsaxPlusBold.clipboard_text,
                size: Responsive.r(20),
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: Responsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.orderId}',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Row(
                    children: [
                      Icon(
                        IconsaxPlusLinear.calendar_1,
                        size: Responsive.r(12),
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                      SizedBox(width: Responsive.w(4)),
                      Text(
                        _formatDate(order.orderDate),
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textCaptionDark
                              : AppColors.textCaption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${order.total.toStringAsFixed(0)} ${AppStrings.currency}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Responsive.h(6)),
                StatusBadge(
                  status: orderStatus,
                  compact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  OrderStatus _mapStatus(String status) {
    return switch (status.toLowerCase()) {
      'new' || 'neworder' => OrderStatus.newOrder,
      'ontheway' => OrderStatus.onTheWay,
      'arrived' => OrderStatus.arrived,
      'delivered' => OrderStatus.delivered,
      'failed' => OrderStatus.failed,
      'cancelled' => OrderStatus.cancelled,
      'returned' => OrderStatus.returned,
      'postponed' => OrderStatus.postponed,
      _ => OrderStatus.newOrder,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ── Rating Card ──

  Widget _buildRatingCard(CustomerRatingModel rating, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(10)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rating number
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(10),
                    vertical: Responsive.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconsaxPlusBold.star_1,
                        size: Responsive.r(14),
                        color: AppColors.warning,
                      ),
                      SizedBox(width: Responsive.w(4)),
                      Text(
                        '${rating.ratingValue}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.w(10)),
                // Stars
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: EdgeInsets.only(left: Responsive.w(2)),
                      child: Icon(
                        index < rating.ratingValue
                            ? IconsaxPlusBold.star_1
                            : IconsaxPlusLinear.star,
                        size: Responsive.r(14),
                        color: AppColors.warning,
                      ),
                    );
                  }),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusLinear.calendar_1,
                      size: Responsive.r(12),
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                    SizedBox(width: Responsive.w(4)),
                    Text(
                      _formatDate(rating.createdAt),
                      style: AppTypography.captionSmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (rating.driverName != null) ...[
              SizedBox(height: Responsive.h(10)),
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.user,
                    size: Responsive.r(14),
                    color: AppColors.primary,
                  ),
                  SizedBox(width: Responsive.w(6)),
                  Text(
                    rating.driverName!,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (rating.feedbackText != null &&
                rating.feedbackText!.isNotEmpty) ...[
              SizedBox(height: Responsive.h(8)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.w(12)),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  rating.feedbackText!,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textBodyDark
                        : AppColors.textBody,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Action Buttons ──

  Widget _buildActionButtons(CustomerDetailModel customer, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: SekkaButton(
            label: AppStrings.rateCustomer,
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => RateCustomerSheet(
                  onSubmit: (rating) {
                    Navigator.of(context).pop();
                    _bloc.add(CustomerRateRequested(
                      customerId: widget.customerId,
                      rating: rating,
                    ));
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(width: Responsive.w(10)),
        Expanded(
          child: SekkaButton(
            label: customer.isBlocked
                ? AppStrings.unblockCustomer
                : AppStrings.blockCustomer,
            type: SekkaButtonType.secondary,
            onPressed: () {
              if (customer.isBlocked) {
                _bloc.add(
                  CustomerUnblockRequested(widget.customerId),
                );
              } else {
                _showBlockDialog(isDark);
              }
            },
          ),
        ),
      ],
    );
  }

  void _showBlockDialog(bool isDark) {
    final reasonController = TextEditingController();
    var reportToCommunity = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              title: Text(
                AppStrings.blockCustomer,
                style: AppTypography.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: reasonController,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: AppStrings.blockReason,
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(12)),
                  Row(
                    children: [
                      Checkbox(
                        value: reportToCommunity,
                        onChanged: (value) {
                          setDialogState(() {
                            reportToCommunity = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: Text(
                          AppStrings.reportToCommunity,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textBodyDark
                                : AppColors.textBody,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    AppStrings.cancel,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _bloc.add(CustomerBlockRequested(
                      customerId: widget.customerId,
                      reason: reasonController.text,
                      reportToCommunity: reportToCommunity,
                    ));
                  },
                  child: Text(
                    AppStrings.confirm,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
