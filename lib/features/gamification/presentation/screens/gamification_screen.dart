import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

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
import '../../../../core/widgets/sekka_segmented_tabs.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/leaderboard_model.dart';
import '../../data/models/point_history_model.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(
        title: AppStrings.gamificationTitle,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(Responsive.h(56)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding,
              vertical: AppSizes.sm,
            ),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (_, __) => SekkaSegmentedTabs(
                labels: [
                  AppStrings.gamificationChallenges,
                  AppStrings.gamificationAchievements,
                  AppStrings.gamificationLeaderboard,
                ],
                selectedIndex: _tabController.index,
                controller: _tabController,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) => switch (state) {
          GamificationLoading() => const SekkaLoading(),
          GamificationError(:final message) => SekkaEmptyState(
              icon: IconsaxPlusLinear.warning_2,
              title: AppStrings.gamificationLoadError,
              description: message,
              actionLabel: AppStrings.retry,
              onAction: () => context
                  .read<GamificationBloc>()
                  .add(const GamificationLoadRequested()),
            ),
          GamificationLoaded() =>
            _GamificationBody(state: state, tabController: _tabController),
          _ => const SekkaLoading(),
        },
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _GamificationBody extends StatelessWidget {
  const _GamificationBody({
    required this.state,
    required this.tabController,
  });

  final GamificationLoaded state;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeaderSection(
          totalPoints: state.totalPoints,
          level: state.level,
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _ChallengesTab(
                challenges: state.challenges,
                claimingId: state.isClaimingId,
              ),
              _AchievementsTab(achievements: state.achievements),
              _LeaderboardTab(
                leaderboard: state.leaderboard,
                isLoading: state.isLoadingLeaderboard,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Header (Level + Points) ──────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.totalPoints,
    required this.level,
  });

  final int totalPoints;
  final int level;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(AppSizes.pagePadding),
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconsaxPlusLinear.medal_star,
                color: AppColors.textOnPrimary,
                size: AppSizes.iconLg,
              ),
              SizedBox(width: AppSizes.sm),
              Text(
                '${AppStrings.gamificationLevel} $level',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconsaxPlusLinear.coin_1,
                color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                size: AppSizes.iconMd,
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                '$totalPoints ${AppStrings.gamificationPoints}',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          GestureDetector(
            onTap: () => _showPointsHistory(context, isDark),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconsaxPlusLinear.clock,
                    color: AppColors.textOnPrimary,
                    size: Responsive.r(14),
                  ),
                  SizedBox(width: AppSizes.xs),
                  Text(
                    AppStrings.gamificationPointsHistory,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPointsHistory(BuildContext context, bool isDark) {
    final bloc = context.read<GamificationBloc>();
    bloc.add(const GamificationPointsHistoryRequested(page: 1));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.sheetRadius),
        ),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) => _PointsHistorySheet(
            scrollController: scrollController,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

// ── Challenges Tab ───────────────────────────────────────────────────────────

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab({
    required this.challenges,
    this.claimingId,
  });

  final List<ChallengeModel> challenges;
  final String? claimingId;

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return SekkaEmptyState(
        icon: IconsaxPlusLinear.cup,
        title: AppStrings.gamificationNoChallenges,
        description: AppStrings.gamificationNoChallengesHint,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      itemCount: challenges.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) => _ChallengeCard(
        challenge: challenges[index],
        isClaiming: claimingId == challenges[index].id,
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    this.isClaiming = false,
  });

  final ChallengeModel challenge;
  final bool isClaiming;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SekkaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + reward
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusLinear.coin_1,
                      color: AppColors.primary,
                      size: Responsive.r(14),
                    ),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      '${challenge.rewardPoints}',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.xs),

          // Description
          Text(
            challenge.description,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
          SizedBox(height: AppSizes.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: LinearProgressIndicator(
              value: challenge.progressPercentage / 100,
              minHeight: Responsive.h(8),
              backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                challenge.isCompleted ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: AppSizes.sm),

          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.currentProgress} / ${challenge.targetValue}',
                style: AppTypography.captionSmall.copyWith(
                  color:
                      isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                ),
              ),
              Text(
                '${challenge.progressPercentage.toInt()}%',
                style: AppTypography.captionSmall.copyWith(
                  color: challenge.isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Claim button
          if (challenge.isCompleted) ...[
            SizedBox(height: AppSizes.md),
            SekkaButton(
              label: AppStrings.gamificationClaimReward,
              onPressed: isClaiming
                  ? null
                  : () => context
                      .read<GamificationBloc>()
                      .add(GamificationClaimRequested(
                        challengeId: challenge.id,
                      )),
              isLoading: isClaiming,
              icon: IconsaxPlusLinear.gift,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Achievements Tab ─────────────────────────────────────────────────────────

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab({required this.achievements});

  final List<AchievementModel> achievements;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return SekkaEmptyState(
        icon: IconsaxPlusLinear.medal,
        title: AppStrings.gamificationNoAchievements,
        description: AppStrings.gamificationNoAchievementsHint,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      itemCount: achievements.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) =>
          _AchievementCard(achievement: achievements[index]),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final AchievementModel achievement;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SekkaCard(
      child: Row(
        children: [
          // Badge icon
          Container(
            width: Responsive.r(48),
            height: Responsive.r(48),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(
              IconsaxPlusLinear.medal_star,
              color: AppColors.success,
              size: AppSizes.iconLg,
            ),
          ),
          SizedBox(width: AppSizes.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.challengeName,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    Text(
                      achievement.badgeName,
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppSizes.sm),
                    Icon(
                      IconsaxPlusLinear.coin_1,
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                      size: Responsive.r(12),
                    ),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      '${achievement.pointsEarned}',
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
          ),

          // Date
          Text(
            _formatDate(achievement.completedAt),
            style: AppTypography.captionSmall.copyWith(
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d/M/yyyy', AppStrings.currentLang).format(date);
  }
}

// ── Leaderboard Tab ──────────────────────────────────────────────────────────

class _LeaderboardTab extends StatefulWidget {
  const _LeaderboardTab({
    required this.leaderboard,
    required this.isLoading,
  });

  final LeaderboardModel? leaderboard;
  final bool isLoading;

  @override
  State<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<_LeaderboardTab> {
  String _period = 'monthly';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    context
        .read<GamificationBloc>()
        .add(GamificationLeaderboardRequested(period: _period));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isLoading) return const SekkaLoading();

    final board = widget.leaderboard;
    if (board == null) return const SekkaLoading();

    if (board.topDrivers.isEmpty && board.myRank == 0) {
      return SekkaEmptyState(
        icon: IconsaxPlusLinear.ranking_1,
        title: AppStrings.gamificationNoLeaderboard,
        description: AppStrings.gamificationNoLeaderboardHint,
      );
    }

    return ListView(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      children: [
        // Period toggle
        _PeriodToggle(
          selected: _period,
          onChanged: (period) {
            setState(() => _period = period);
            _loadLeaderboard();
          },
          isDark: isDark,
        ),
        SizedBox(height: AppSizes.md),

        // My rank card
        _MyRankCard(
          rank: board.myRank,
          points: board.myPoints,
          isDark: isDark,
        ),
        SizedBox(height: AppSizes.lg),

        // Top drivers
        ...List.generate(board.topDrivers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSizes.sm),
            child: _LeaderboardRow(
              entry: board.topDrivers[index],
              isDark: isDark,
            ),
          );
        }),
      ],
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  final String selected;
  final ValueChanged<String> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleChip(
          label: AppStrings.gamificationPeriodMonthly,
          isSelected: selected == 'monthly',
          onTap: () => onChanged('monthly'),
          isDark: isDark,
        ),
        SizedBox(width: AppSizes.sm),
        _ToggleChip(
          label: AppStrings.gamificationPeriodWeekly,
          isSelected: selected == 'weekly',
          onTap: () => onChanged('weekly'),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected
                ? AppColors.textOnPrimary
                : (isDark ? AppColors.textBodyDark : AppColors.textBody),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MyRankCard extends StatelessWidget {
  const _MyRankCard({
    required this.rank,
    required this.points,
    required this.isDark,
  });

  final int rank;
  final int points;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      borderColor: AppColors.primary,
      child: Row(
        children: [
          Container(
            width: Responsive.r(44),
            height: Responsive.r(44),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.gamificationYourRank,
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
                Text(
                  '$points ${AppStrings.gamificationPoints}',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.isDark,
  });

  final LeaderboardEntryModel entry;
  final bool isDark;

  Color get _rankColor => switch (entry.rank) {
        1 => const Color(0xFFFFD700),
        2 => const Color(0xFFC0C0C0),
        3 => const Color(0xFFCD7F32),
        _ => isDark ? AppColors.textCaptionDark : AppColors.textCaption,
      };

  IconData get _rankIcon => switch (entry.rank) {
        1 || 2 || 3 => IconsaxPlusLinear.crown_1,
        _ => IconsaxPlusLinear.profile_circle,
      };

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: Responsive.r(32),
            child: entry.rank <= 3
                ? Icon(_rankIcon, color: _rankColor, size: AppSizes.iconLg)
                : Text(
                    '#${entry.rank}',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          SizedBox(width: AppSizes.md),

          // Name + info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.driverName,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  '${AppStrings.gamificationLevel} ${entry.level} · ${entry.ordersThisMonth} ${AppStrings.gamificationOrdersThisMonth}',
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Text(
            '${entry.points}',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Points History Bottom Sheet ──────────────────────────────────────────────

class _PointsHistorySheet extends StatelessWidget {
  const _PointsHistorySheet({
    required this.scrollController,
    required this.isDark,
  });

  final ScrollController scrollController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Padding(
          padding: EdgeInsets.only(top: AppSizes.md),
          child: Container(
            width: Responsive.w(40),
            height: Responsive.h(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
          ),
        ),
        SizedBox(height: AppSizes.lg),

        // Title
        Text(
          AppStrings.gamificationPointsHistory,
          style: AppTypography.headlineSmall.copyWith(
            color:
                isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        SizedBox(height: AppSizes.md),

        // List
        Expanded(
          child: BlocBuilder<GamificationBloc, GamificationState>(
            builder: (context, state) {
              if (state is! GamificationLoaded) return const SekkaLoading();

              if (state.pointsHistory.isEmpty && !state.isLoadingHistory) {
                return SekkaEmptyState(
                  icon: IconsaxPlusLinear.clock,
                  title: AppStrings.gamificationNoHistory,
                  description: AppStrings.gamificationNoHistoryHint,
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      notification.metrics.extentAfter < 200 &&
                      state.hasMoreHistory &&
                      !state.isLoadingHistory) {
                    context.read<GamificationBloc>().add(
                          GamificationPointsHistoryRequested(
                            page: state.pointsHistoryPage + 1,
                          ),
                        );
                  }
                  return false;
                },
                child: ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSizes.pagePadding),
                  itemCount: state.pointsHistory.length +
                      (state.isLoadingHistory ? 1 : 0),
                  separatorBuilder: (_, __) => Divider(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    if (index == state.pointsHistory.length) {
                      return Padding(
                        padding: EdgeInsets.all(AppSizes.lg),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    return _PointHistoryRow(
                      item: state.pointsHistory[index],
                      isDark: isDark,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PointHistoryRow extends StatelessWidget {
  const _PointHistoryRow({
    required this.item,
    required this.isDark,
  });

  final PointHistoryModel item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isPositive = item.points > 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        children: [
          Container(
            width: Responsive.r(36),
            height: Responsive.r(36),
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive
                  ? IconsaxPlusLinear.arrow_up_3
                  : IconsaxPlusLinear.arrow_down,
              color: isPositive ? AppColors.success : AppColors.error,
              size: Responsive.r(16),
            ),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.reason,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  _formatDateTime(item.createdAt),
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${item.points}',
            style: AppTypography.titleMedium.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('d/M · h:mm a', AppStrings.currentLang).format(date);
  }
}
