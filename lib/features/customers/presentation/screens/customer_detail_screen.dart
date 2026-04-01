import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Responsive.h(16)),

          // Profile header
          _buildProfileHeader(customer, displayName, isDark),

          SizedBox(height: Responsive.h(20)),

          // Stats row
          _buildStatsRow(customer, isDark),

          SizedBox(height: Responsive.h(24)),

          // RFM Score section (from insights profile)
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
          if (recommendations != null && recommendations.isNotEmpty) ...[
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

          // Action buttons
          _buildActionButtons(customer, isDark),

          SizedBox(height: Responsive.h(40)),
        ],
      ),
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
            AppColors.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(Responsive.r(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(Responsive.w(24)),
      child: Column(
        children: [
          // Avatar
          Container(
            width: Responsive.r(80),
            height: Responsive.r(80),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: Responsive.sp(32),
                ),
              ),
            ),
          ),

          SizedBox(height: Responsive.h(14)),

          // Name
          Text(
            displayName,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: Responsive.h(6)),

          // Phone
          Text(
            customer.phone,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
            ),
          ),

          SizedBox(height: Responsive.h(12)),

          // Rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconsaxPlusBold.star_1,
                size: Responsive.r(20),
                color: AppColors.warning,
              ),
              SizedBox(width: Responsive.w(6)),
              Text(
                customer.averageRating.toStringAsFixed(1),
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Blocked badge
          if (customer.isBlocked) ...[
            SizedBox(height: Responsive.h(12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(16),
                vertical: Responsive.h(6),
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                AppStrings.blocked,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Stats Row ──

  Widget _buildStatsRow(CustomerDetailModel customer, bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          value: '${customer.totalDeliveries}',
          label: AppStrings.totalDeliveries,
          isDark: isDark,
        ),
        SizedBox(width: Responsive.w(10)),
        _buildStatCard(
          value: '${customer.successfulDeliveries}',
          label: AppStrings.successfulDeliveries,
          isDark: isDark,
        ),
        SizedBox(width: Responsive.w(10)),
        _buildStatCard(
          value: customer.averageRating.toStringAsFixed(1),
          label: AppStrings.averageRating,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
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
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: Responsive.h(4)),
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
    return Text(
      title,
      style: AppTypography.titleLarge.copyWith(
        color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
      ),
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

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        children: [
          // Segment badge
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: Responsive.h(10),
            ),
            decoration: BoxDecoration(
              color: segmentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Responsive.r(12)),
            ),
            child: Column(
              children: [
                Text(
                  AppStrings.customerSegment,
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
                SizedBox(height: Responsive.h(4)),
                Text(
                  segmentLabel,
                  style: AppTypography.titleLarge.copyWith(
                    color: segmentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Responsive.h(16)),

          // RFM bars
          Row(
            children: [
              _buildRfmBar(
                AppStrings.recency,
                rfm.recencyScore,
                AppColors.info,
                isDark,
              ),
              SizedBox(width: Responsive.w(10)),
              _buildRfmBar(
                AppStrings.frequency,
                rfm.frequencyScore,
                AppColors.success,
                isDark,
              ),
              SizedBox(width: Responsive.w(10)),
              _buildRfmBar(
                AppStrings.monetary,
                rfm.monetaryScore,
                AppColors.warning,
                isDark,
              ),
            ],
          ),

          SizedBox(height: Responsive.h(14)),

          // Extra info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.lifetimeValue}: ${profile.lifetimeValue.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                ),
              ),
              Text(
                '${AppStrings.orders}: ${profile.totalOrders}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                ),
              ),
            ],
          ),

          // Engagement level
          if (profile.engagementLevel.isNotEmpty) ...[
            SizedBox(height: Responsive.h(8)),
            Row(
              children: [
                Text(
                  '${AppStrings.engagement}: ',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(10),
                    vertical: Responsive.h(3),
                  ),
                  decoration: BoxDecoration(
                    color: _engagementColor(profile.engagementLevel)
                        .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    _engagementLabel(profile.engagementLevel),
                    style: AppTypography.captionSmall.copyWith(
                      color: _engagementColor(profile.engagementLevel),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
        'loyal' || 'loyal_customers' => 'عميل مخلص',
        'potential' || 'potential_loyalist' => 'محتمل الولاء',
        'at_risk' || 'atrisk' => 'معرّض للخسارة',
        'lost' || 'hibernating' => 'عميل خامل',
        'cant_lose' => 'لا يمكن خسارته',
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
    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        children: [
          // Level + Score row
          Row(
            children: [
              Expanded(
                child: _buildEngagementChip(
                  AppStrings.engagement,
                  engagement.level,
                  AppColors.primary,
                  isDark,
                ),
              ),
              SizedBox(width: Responsive.w(10)),
              Expanded(
                child: _buildEngagementChip(
                  AppStrings.engagementScore,
                  '${engagement.engagementScore}',
                  AppColors.info,
                  isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(14)),
          // Stats row
          Row(
            children: [
              _buildMiniStat(
                '${engagement.totalOrders}',
                AppStrings.orders,
                isDark,
              ),
              _buildMiniStat(
                engagement.daysSinceLastOrder >= 0
                    ? '${engagement.daysSinceLastOrder}'
                    : '-',
                AppStrings.daysSinceLastOrder,
                isDark,
              ),
            ],
          ),
          if (engagement.lastInteraction != null) ...[
            SizedBox(height: Responsive.h(10)),
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.clock,
                  size: Responsive.r(14),
                  color:
                      isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                ),
                SizedBox(width: Responsive.w(6)),
                Text(
                  '${AppStrings.lastInteraction}: ${_formatDate(engagement.lastInteraction!)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEngagementChip(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.h(10),
        horizontal: Responsive.w(10),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Responsive.r(12)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
          ),
          SizedBox(height: Responsive.h(4)),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, bool isDark) {
    return Expanded(
      child: Column(
        children: [
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
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            Text(
              'الفئات المفضلة',
              style: AppTypography.bodySmall.copyWith(
                color:
                    isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              ),
            ),
            SizedBox(height: Responsive.h(8)),
            Wrap(
              spacing: Responsive.w(8),
              runSpacing: Responsive.h(6),
              children: interests.topCategories.map((cat) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(12),
                    vertical: Responsive.h(6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
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
            SizedBox(height: Responsive.h(14)),
          ],
          if (interests.preferredPartners.isNotEmpty) ...[
            Text(
              'شركاء مفضلين',
              style: AppTypography.bodySmall.copyWith(
                color:
                    isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              ),
            ),
            SizedBox(height: Responsive.h(8)),
            ...interests.preferredPartners.take(3).map((p) {
              return Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(6)),
                child: Row(
                  children: [
                    Icon(
                      IconsaxPlusLinear.shop,
                      size: Responsive.r(16),
                      color: AppColors.primary,
                    ),
                    SizedBox(width: Responsive.w(8)),
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
                    Text(
                      '${p.orderCount} طلب',
                      style: AppTypography.captionSmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          Row(
            children: [
              Text(
                'متوسط قيمة الطلب: ',
                style: AppTypography.bodySmall.copyWith(
                  color:
                      isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                ),
              ),
              Text(
                '${interests.averageOrderValue.toStringAsFixed(0)} ${AppStrings.currency}',
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
              _buildRecStatusBadge('تم التنفيذ', AppColors.success),
            if (rec.isDismissed)
              _buildRecStatusBadge('تم التجاهل', AppColors.textCaption),
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

    return SekkaCard(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.all(Responsive.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: time + day
          Row(
            children: [
              _buildBehaviorChip(
                IconsaxPlusLinear.clock,
                AppStrings.preferredOrderTime,
                timeLabel,
                AppColors.primary,
                isDark,
              ),
              SizedBox(width: Responsive.w(8)),
              _buildBehaviorChip(
                IconsaxPlusLinear.calendar_1,
                AppStrings.preferredDay,
                dayLabel,
                AppColors.info,
                isDark,
              ),
            ],
          ),

          SizedBox(height: Responsive.h(10)),

          // Second row: frequency + spending
          Row(
            children: [
              _buildBehaviorChip(
                IconsaxPlusLinear.repeat,
                AppStrings.orderFrequency,
                '${behavior.orderFrequencyPerMonth}',
                AppColors.success,
                isDark,
              ),
              SizedBox(width: Responsive.w(8)),
              _buildBehaviorChip(
                IconsaxPlusLinear.dollar_circle,
                AppStrings.spendingTier,
                tierLabel,
                tierColor,
                isDark,
              ),
            ],
          ),

          SizedBox(height: Responsive.h(10)),

          // Average order value
          Row(
            children: [
              Text(
                'متوسط قيمة الطلب: ',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                ),
              ),
              Text(
                '${behavior.averageOrderValue.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Preferred areas
          if (behavior.preferredAreas.isNotEmpty) ...[
            SizedBox(height: Responsive.h(12)),
            Text(
              AppStrings.preferredAreas,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
            ),
            SizedBox(height: Responsive.h(6)),
            Wrap(
              spacing: Responsive.w(8),
              runSpacing: Responsive.h(6),
              children: behavior.preferredAreas.map((area) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(12),
                    vertical: Responsive.h(6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconsaxPlusLinear.location,
                        size: Responsive.r(12),
                        color: AppColors.info,
                      ),
                      SizedBox(width: Responsive.w(4)),
                      Text(
                        area,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // Patterns
          if (behavior.patterns.isNotEmpty) ...[
            SizedBox(height: Responsive.h(12)),
            Text(
              'أنماط السلوك',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
            ),
            SizedBox(height: Responsive.h(6)),
            ...behavior.patterns.map((pattern) {
              return Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(4)),
                child: Row(
                  children: [
                    Icon(
                      IconsaxPlusLinear.trend_up,
                      size: Responsive.r(14),
                      color: AppColors.success,
                    ),
                    SizedBox(width: Responsive.w(6)),
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

  Widget _buildBehaviorChip(
    IconData icon,
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.h(10),
          horizontal: Responsive.w(8),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(Responsive.r(10)),
        ),
        child: Column(
          children: [
            Icon(icon, size: Responsive.r(18), color: color),
            SizedBox(height: Responsive.h(4)),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: Responsive.h(2)),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _translateTime(String? time) => switch (time?.toLowerCase()) {
        'morning' => 'صباحاً',
        'afternoon' => 'ظهراً',
        'evening' => 'مساءً',
        'night' => 'ليلاً',
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
                Icon(
                  IconsaxPlusLinear.location,
                  size: Responsive.r(18),
                  color: AppColors.primary,
                ),
                SizedBox(width: Responsive.w(8)),
                Expanded(
                  child: Text(
                    address.addressText,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(10),
                    vertical: Responsive.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
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
              SizedBox(height: Responsive.h(8)),
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.map_1,
                    size: Responsive.r(14),
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  SizedBox(width: Responsive.w(6)),
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
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.note_1,
                    size: Responsive.r(14),
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                  SizedBox(width: Responsive.w(6)),
                  Expanded(
                    child: Text(
                      address.deliveryNotes!,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                    ),
                  ),
                  SizedBox(height: Responsive.h(4)),
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
                // Stars
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.ratingValue
                          ? IconsaxPlusBold.star_1
                          : IconsaxPlusLinear.star,
                      size: Responsive.r(16),
                      color: AppColors.warning,
                    );
                  }),
                ),
                const Spacer(),
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
            if (rating.driverName != null) ...[
              SizedBox(height: Responsive.h(8)),
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
            if (rating.feedbackText != null &&
                rating.feedbackText!.isNotEmpty) ...[
              SizedBox(height: Responsive.h(6)),
              Text(
                rating.feedbackText!,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textBodyDark
                      : AppColors.textBody,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Action Buttons ──

  Widget _buildActionButtons(CustomerDetailModel customer, bool isDark) {
    return Column(
      children: [
        SekkaButton(
          label: AppStrings.rateCustomer,
          icon: IconsaxPlusLinear.star,
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
        SizedBox(height: Responsive.h(12)),
        SekkaButton(
          label: customer.isBlocked
              ? AppStrings.unblockCustomer
              : AppStrings.blockCustomer,
          icon: customer.isBlocked
              ? IconsaxPlusLinear.unlock
              : IconsaxPlusLinear.lock,
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
