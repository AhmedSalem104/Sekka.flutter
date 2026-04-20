import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_segmented_tabs.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../colleague_radar/data/repositories/colleague_radar_repository.dart';
import '../../../colleague_radar/presentation/bloc/colleague_radar_bloc.dart';
import '../../../colleague_radar/presentation/bloc/colleague_radar_event.dart';
import '../../../colleague_radar/presentation/bloc/colleague_radar_state.dart';
import '../../../colleague_radar/data/models/help_request_model.dart';
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

    // Colleague Radar bloc
    final radarRepo = ColleagueRadarRepository(dioClient.dio);

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
        BlocProvider(
          create: (_) => ColleagueRadarBloc(repository: radarRepo),
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
      length: 3,
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
          children: [
            const RouteTabContent(),
            const ParkingTabContent(),
            const ColleagueRadarTabContent(),
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
    return AnimatedBuilder(
      animation: tabController,
      builder: (_, __) => SekkaSegmentedTabs(
        labels: [
          AppStrings.tabRouteOptimize,
          AppStrings.tabParkingSpots,
          AppStrings.radarTab,
        ],
        selectedIndex: tabController.index,
        controller: tabController,
        onChanged: (_) {},
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

// ══════════════════════════════════════════════════════════════════════════
//  COLLEAGUE RADAR TAB — رادار الزملاء
// ══════════════════════════════════════════════════════════════════════════

class ColleagueRadarTabContent extends StatefulWidget {
  const ColleagueRadarTabContent({super.key});

  @override
  State<ColleagueRadarTabContent> createState() =>
      _ColleagueRadarTabContentState();
}

class _ColleagueRadarTabContentState extends State<ColleagueRadarTabContent> {
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _loadWithLocation();
    _locationTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _updateLocation(),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<Position?> _getPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateLocation() async {
    final position = await _getPosition();
    if (!mounted || position == null) return;
    context.read<ColleagueRadarBloc>().add(
          ColleagueRadarUpdateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
  }

  Future<void> _loadWithLocation() async {
    final position = await _getPosition();
    if (!mounted) return;
    final lat = position?.latitude ?? 0;
    final lng = position?.longitude ?? 0;
    context.read<ColleagueRadarBloc>().add(
          ColleagueRadarLoadRequested(latitude: lat, longitude: lng),
        );
    if (position != null) {
      context.read<ColleagueRadarBloc>().add(
            ColleagueRadarUpdateLocation(latitude: lat, longitude: lng),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<ColleagueRadarBloc, ColleagueRadarState>(
      listener: (context, state) {
        if (state is ColleagueRadarLoaded && state.actionMessage != null) {
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
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            );
        }
      },
      builder: (context, state) => switch (state) {
        ColleagueRadarInitial() ||
        ColleagueRadarLoading() =>
          const SekkaLoading(),
        ColleagueRadarError(:final message) => SekkaEmptyState(
            icon: IconsaxPlusLinear.radar_2,
            title: AppStrings.radarTitle,
            description: message,
            actionLabel: AppStrings.retry,
            onAction: _loadWithLocation,
          ),
        ColleagueRadarLoaded() => _RadarBody(state: state, isDark: isDark),
      },
    );
  }
}

class _RadarBody extends StatelessWidget {
  const _RadarBody({required this.state, required this.isDark});

  final ColleagueRadarLoaded state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasNearby = state.nearbyDrivers.isNotEmpty;
    final hasRequests = state.nearbyRequests.isNotEmpty;
    final hasMyRequests = state.myRequests.isNotEmpty;
    final isEmpty = !hasNearby && !hasRequests && !hasMyRequests;

    if (isEmpty) {
      return Column(
        children: [
          Expanded(
            child: SekkaEmptyState(
              icon: IconsaxPlusLinear.radar_2,
              title: AppStrings.radarNoNearby,
              description: AppStrings.radarNoNearbyHint,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: SekkaButton(
              label: AppStrings.radarSendHelp,
              icon: IconsaxPlusLinear.danger,
              onPressed: () => _showCreateHelpSheet(context),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            children: [
              // My active requests
              if (hasMyRequests) ...[
                Text(
                  AppStrings.radarMyRequests,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                ...state.myRequests
                    .where((r) => !r.isResolved)
                    .map((r) => Padding(
                          padding: EdgeInsets.only(bottom: AppSizes.sm),
                          child: _HelpRequestCard(
                            request: r,
                            isDark: isDark,
                            isMine: true,
                          ),
                        )),
                SizedBox(height: AppSizes.lg),
              ],

              // Nearby help requests
              if (hasRequests) ...[
                Text(
                  AppStrings.radarHelpRequests,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                ...state.nearbyRequests.map((r) => Padding(
                      padding: EdgeInsets.only(bottom: AppSizes.sm),
                      child: _HelpRequestCard(
                        request: r,
                        isDark: isDark,
                        isMine: false,
                      ),
                    )),
                SizedBox(height: AppSizes.lg),
              ],

              // Nearby drivers
              if (hasNearby) ...[
                Text(
                  '${AppStrings.radarNearbyDrivers} (${state.nearbyDrivers.length})',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                ...state.nearbyDrivers.map((d) => Padding(
                      padding: EdgeInsets.only(bottom: AppSizes.sm),
                      child: SekkaCard(
                        child: Row(
                          children: [
                            Container(
                              width: Responsive.r(40),
                              height: Responsive.r(40),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                IconsaxPlusLinear.user,
                                color: AppColors.success,
                                size: AppSizes.iconMd,
                              ),
                            ),
                            SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Text(
                                d.driverName,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textHeadlineDark
                                      : AppColors.textHeadline,
                                ),
                              ),
                            ),
                            Text(
                              '${d.distanceKm.toStringAsFixed(1)} ${AppStrings.radarAway}',
                              style: AppTypography.captionSmall.copyWith(
                                color: isDark
                                    ? AppColors.textCaptionDark
                                    : AppColors.textCaption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ],
          ),
        ),

        // Fixed bottom button
        Padding(
          padding: EdgeInsets.all(AppSizes.pagePadding),
          child: SekkaButton(
            label: AppStrings.radarSendHelp,
            icon: IconsaxPlusLinear.danger,
            onPressed: () => _showCreateHelpSheet(context),
          ),
        ),
      ],
    );
  }

  void _showCreateHelpSheet(BuildContext context) {
    final bloc = context.read<ColleagueRadarBloc>();
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
        child: _CreateHelpSheet(isDark: isDark),
      ),
    );
  }
}

class _HelpRequestCard extends StatelessWidget {
  const _HelpRequestCard({
    required this.request,
    required this.isDark,
    required this.isMine,
  });

  final HelpRequestModel request;
  final bool isDark;
  final bool isMine;

  Color get _statusColor => switch (request.status) {
        'Pending' => AppColors.warning,
        'Accepted' => AppColors.info,
        'Resolved' => AppColors.success,
        _ => AppColors.textCaption,
      };

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      borderColor: _statusColor.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: Responsive.r(36),
                height: Responsive.r(36),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusLinear.danger,
                  color: _statusColor,
                  size: Responsive.r(18),
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                      ),
                    ),
                    if (request.driverName.isNotEmpty)
                      Text(
                        request.driverName,
                        style: AppTypography.captionSmall.copyWith(
                          color: isDark
                              ? AppColors.textCaptionDark
                              : AppColors.textCaption,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text(
                  request.status,
                  style: AppTypography.captionSmall.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (request.description.isNotEmpty) ...[
            SizedBox(height: AppSizes.sm),
            Text(
              request.description,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Icon(
                IconsaxPlusLinear.clock,
                size: Responsive.r(12),
                color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                DateFormat('h:mm a', AppStrings.currentLang).format(request.createdAt),
                style: AppTypography.captionSmall.copyWith(
                  color: isDark
                      ? AppColors.textCaptionDark
                      : AppColors.textCaption,
                ),
              ),
              const Spacer(),
              if (!isMine && request.isPending)
                OutlinedButton.icon(
                  onPressed: () => context
                      .read<ColleagueRadarBloc>()
                      .add(ColleagueRadarRespondRequested(
                        requestId: request.id,
                      )),
                  icon: Icon(
                    IconsaxPlusLinear.like_1,
                    size: Responsive.r(14),
                  ),
                  label: Text(
                    AppStrings.radarRespond,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.xs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              if (isMine && !request.isResolved)
                TextButton.icon(
                  onPressed: () => context
                      .read<ColleagueRadarBloc>()
                      .add(ColleagueRadarResolveRequested(
                        requestId: request.id,
                      )),
                  icon: Icon(
                    IconsaxPlusLinear.tick_circle,
                    size: Responsive.r(14),
                    color: AppColors.warning,
                  ),
                  label: Text(
                    AppStrings.radarResolve,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Create Help Request Sheet ────────────────────────────────────────────

class _CreateHelpSheet extends StatefulWidget {
  const _CreateHelpSheet({required this.isDark});
  final bool isDark;

  @override
  State<_CreateHelpSheet> createState() => _CreateHelpSheetState();
}

class _CreateHelpSheetState extends State<_CreateHelpSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedType = 'Other';

  static List<(String, String)> get _helpTypes => [
    ('Mechanical', AppStrings.radarHelpTypeMechanical),
    ('Tire', AppStrings.radarHelpTypeTire),
    ('Fuel', AppStrings.radarHelpTypeFuel),
    ('Order', AppStrings.radarHelpTypeOrder),
    ('Other', AppStrings.radarHelpTypeOther),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;

    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (_) {}

    if (!mounted) return;

    context.read<ColleagueRadarBloc>().add(
          ColleagueRadarCreateHelpRequest(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            latitude: pos?.latitude ?? 0,
            longitude: pos?.longitude ?? 0,
            helpType: _selectedType,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.xxl,
        AppSizes.pagePadding,
        MediaQuery.of(context).viewInsets.bottom + AppSizes.xxxl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: Responsive.w(40),
              height: Responsive.h(4),
              decoration: BoxDecoration(
                color:
                    widget.isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
            ),
            SizedBox(height: AppSizes.xxl),

            Text(
              AppStrings.radarSendHelp,
              style: AppTypography.headlineSmall.copyWith(
                color: widget.isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: AppSizes.xl),

            // Help type chips
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: _helpTypes.map((type) {
                final isSelected = _selectedType == type.$1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type.$1),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (widget.isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: widget.isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                    ),
                    child: Text(
                      type.$2,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : (widget.isDark
                                ? AppColors.textBodyDark
                                : AppColors.textBody),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: AppSizes.xl),

            SekkaInputField(
              controller: _titleCtrl,
              label: AppStrings.radarHelpTitle,
              prefixIcon: IconsaxPlusLinear.danger,
            ),
            SizedBox(height: AppSizes.lg),

            SekkaInputField(
              controller: _descCtrl,
              label: AppStrings.radarHelpDesc,
              prefixIcon: IconsaxPlusLinear.document_text,
              maxLines: 3,
            ),
            SizedBox(height: AppSizes.xxl),

            BlocBuilder<ColleagueRadarBloc, ColleagueRadarState>(
              builder: (context, state) {
                final isSubmitting =
                    state is ColleagueRadarLoaded && state.isSubmitting;
                return SekkaButton(
                  label: AppStrings.radarSendHelp,
                  onPressed: isSubmitting ? null : _submit,
                  isLoading: isSubmitting,
                  icon: IconsaxPlusLinear.send_2,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
