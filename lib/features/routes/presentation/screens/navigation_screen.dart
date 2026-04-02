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
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../parking/data/datasources/parking_remote_datasource.dart';
import '../../../parking/data/models/parking_model.dart';
import '../../../parking/data/repositories/parking_repository_impl.dart';
import '../../../parking/presentation/bloc/parking_bloc.dart';
import '../../../parking/presentation/bloc/parking_event.dart';
import '../../../parking/presentation/bloc/parking_state.dart';
import '../../data/datasources/route_remote_datasource.dart';
import '../../data/repositories/route_repository_impl.dart';
import '../bloc/route_bloc.dart';
import '../bloc/route_event.dart';
import 'route_screen.dart';

/// Combined navigation screen with two tabs:
/// 1. Route optimization (حسّن مسارك)
/// 2. Parking spots (أماكن الركن)
class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final dioClient = context.read<DioClient>();

    // Route bloc
    final routeDatasource = RouteRemoteDataSource(dioClient);
    final routeRepo = RouteRepositoryImpl(remoteDataSource: routeDatasource);

    // Parking bloc
    final parkingDatasource = ParkingRemoteDataSource(dioClient);
    final parkingRepo =
        ParkingRepositoryImpl(remoteDataSource: parkingDatasource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => RouteBloc(repository: routeRepo)
            ..add(const RouteActiveLoadRequested()),
        ),
        BlocProvider(
          create: (_) => ParkingBloc(repository: parkingRepo)
            ..add(const ParkingLoadRequested()),
        ),
      ],
      child: _NavigationScreenBody(initialTab: initialTab),
    );
  }
}

class _NavigationScreenBody extends StatefulWidget {
  const _NavigationScreenBody({required this.initialTab});

  final int initialTab;

  @override
  State<_NavigationScreenBody> createState() => _NavigationScreenBodyState();
}

class _NavigationScreenBodyState extends State<_NavigationScreenBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        appBar: SekkaAppBar(
          title: AppStrings.navigationTitle,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(Responsive.h(56)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
                vertical: AppSizes.sm,
              ),
              child: _NavigationTabBar(
                tabController: _tabController,
                isDark: isDark,
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            RouteTabContent(),
            ParkingTabContent(),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  TAB BAR — التابات
// ══════════════════════════════════════════════════════════════════════════

class _NavigationTabBar extends StatelessWidget {
  const _NavigationTabBar({
    required this.tabController,
    required this.isDark,
  });

  final TabController tabController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.border.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.chipRadius),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.chipRadius),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor:
            isDark ? AppColors.textBodyDark : AppColors.textBody,
        labelStyle: AppTypography.titleMedium,
        unselectedLabelStyle: AppTypography.titleMedium,
        tabs: const [
          Tab(text: AppStrings.tabRouteOptimize),
          Tab(text: AppStrings.tabParkingSpots),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  PARKING TAB CONTENT — أماكن الركن (full tab, not bottom sheet)
// ══════════════════════════════════════════════════════════════════════════

class ParkingTabContent extends StatelessWidget {
  const ParkingTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<ParkingBloc, ParkingState>(
      listener: (context, state) {
        if (state is ParkingLoaded && state.actionMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    state.actionMessage!,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textOnPrimary),
                  ),
                ),
                backgroundColor:
                    state.isActionError ? AppColors.error : AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            );
          context.read<ParkingBloc>().add(const ParkingClearMessage());
        }
      },
      builder: (context, state) => switch (state) {
        ParkingInitial() || ParkingLoading() => const SekkaLoading(),
        ParkingLoaded(:final spots) => spots.isEmpty
            ? _ParkingEmptyState(isDark: isDark)
            : _ParkingSpotsList(spots: spots, isDark: isDark),
        ParkingError(:final message) => Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.pagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconsaxPlusLinear.warning_2,
                    size: Responsive.r(48),
                    color: AppColors.error,
                  ),
                  SizedBox(height: AppSizes.lg),
                  Text(
                    message,
                    style: AppTypography.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.textBodyDark : AppColors.textBody,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.xl),
                  SekkaButton(
                    label: AppStrings.retry,
                    type: SekkaButtonType.secondary,
                    onPressed: () => context
                        .read<ParkingBloc>()
                        .add(const ParkingLoadRequested()),
                  ),
                ],
              ),
            ),
          ),
      },
    );
  }
}

class _ParkingEmptyState extends StatelessWidget {
  const _ParkingEmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.r(28)),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusBold.car,
                size: Responsive.r(52),
                color: AppColors.info,
              ),
            ),
            SizedBox(height: AppSizes.xxl),
            Text(
              AppStrings.noParkingSpots,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              AppStrings.noParkingSpotsHint,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.xxl + AppSizes.lg),
            SekkaButton(
              label: AppStrings.addParkingSpot,
              icon: IconsaxPlusLinear.car,
              onPressed: () => showCreateParkingSheet(context, isDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParkingSpotsList extends StatelessWidget {
  const _ParkingSpotsList({required this.spots, required this.isDark});

  final List<ParkingModel> spots;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with add button
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.pagePadding,
            AppSizes.md,
            AppSizes.pagePadding,
            AppSizes.sm,
          ),
          child: Row(
            children: [
              Text(
                '${AppStrings.myParkingSpots} (${spots.length})',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => showCreateParkingSheet(context, isDark),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
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
                        IconsaxPlusLinear.add,
                        size: AppSizes.iconSm,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        AppStrings.addParkingSpot,
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Spots list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding,
            ),
            itemCount: spots.length,
            separatorBuilder: (_, __) => SizedBox(height: AppSizes.sm),
            itemBuilder: (context, index) => ParkingSpotTile(
              spot: spots[index],
              isDark: isDark,
            ),
          ),
        ),
      ],
    );
  }
}
