import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../colleague_radar/data/models/nearby_driver_model.dart';
import '../../../colleague_radar/data/repositories/colleague_radar_repository.dart';
import '../../../favorite_drivers/data/models/favorite_driver_model.dart';
import '../../../favorite_drivers/data/repositories/favorite_drivers_repository.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';

/// Bottom sheet that lets the user transfer an order via:
/// 1. Favorite colleagues (quick access)
/// 2. Nearby colleagues (location-based)
/// 3. Search by phone number
///
/// For app-users: direct transfer with push notification.
/// For non-app-users: WhatsApp share link.
class TransferOrderSheet extends StatefulWidget {
  const TransferOrderSheet({super.key, required this.orderId});

  final String orderId;

  static Future<void> show(BuildContext context, {required String orderId}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(24)),
        ),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: TransferOrderSheet(orderId: orderId),
      ),
    );
  }

  @override
  State<TransferOrderSheet> createState() => _TransferOrderSheetState();
}

class _TransferOrderSheetState extends State<TransferOrderSheet> {
  late final ColleagueRadarRepository _radarRepo;
  late final FavoriteDriversRepository _favRepo;
  final _reasonCtrl = TextEditingController();
  final _phoneSearchCtrl = TextEditingController();

  // Favorites
  List<FavoriteDriverModel>? _favorites;
  bool _loadingFavorites = true;

  // Nearby
  List<NearbyDriverModel>? _nearbyDrivers;
  bool _loadingNearby = true;
  String? _nearbyError;

  // Phone search
  DriverByPhoneModel? _searchResult;
  bool _searching = false;
  String? _searchError;

  // Share link loading
  bool _generatingLink = false;

  @override
  void initState() {
    super.initState();
    final dio = context.read<DioClient>().dio;
    _radarRepo = ColleagueRadarRepository(dio);
    _favRepo = FavoriteDriversRepository(dio);
    _loadFavorites();
    _loadNearby();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _phoneSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final result = await _favRepo.getFavorites();
    if (!mounted) return;
    setState(() {
      _loadingFavorites = false;
      if (result case ApiSuccess(:final data)) _favorites = data;
    });
  }

  Future<void> _loadNearby() async {
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } catch (_) {}

    final result = await _radarRepo.getNearbyDrivers(
      latitude: pos?.latitude ?? 30.0444,
      longitude: pos?.longitude ?? 31.2357,
      radiusKm: 10,
    );

    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _nearbyDrivers = data;
          _loadingNearby = false;
        });
      case ApiFailure(:final error):
        setState(() {
          _nearbyError = error.arabicMessage;
          _loadingNearby = false;
        });
    }
  }

  Future<void> _searchByPhone() async {
    final phone = _phoneSearchCtrl.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      _searching = true;
      _searchError = null;
      _searchResult = null;
    });

    final result = await _favRepo.searchByPhone(phone);
    if (!mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _searchResult = data;
          _searching = false;
        });
      case ApiFailure(:final error):
        setState(() {
          _searchError = error.message;
          _searching = false;
        });
    }
  }

  Future<void> _transferDirect(String targetDriverId, String driverName) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Text(
            AppStrings.transferToColleague,
            style: AppTypography.titleLarge.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          content: Text(
            '${AppStrings.transferConfirmMsg} $driverName؟',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                AppStrings.cancel,
                style:
                    AppTypography.button.copyWith(color: AppColors.textCaption),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                AppStrings.confirm,
                style:
                    AppTypography.button.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    context.read<OrdersBloc>().add(
          OrderTransferRequested(
            orderId: widget.orderId,
            targetDriverId: targetDriverId,
            reason: _reasonCtrl.text.trim().isEmpty
                ? null
                : _reasonCtrl.text.trim(),
          ),
        );
    Navigator.pop(context);
  }

  Future<void> _sendViaWhatsApp(String phone) async {
    setState(() => _generatingLink = true);

    final result = await _favRepo.createShareLink(widget.orderId);
    if (!mounted) return;

    setState(() => _generatingLink = false);

    switch (result) {
      case ApiSuccess(:final data):
        final encoded = Uri.encodeComponent(data.messageTemplate);
        final cleanPhone = phone.replaceAll('+', '');
        final url = Uri.parse('https://wa.me/$cleanPhone?text=$encoded');
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (mounted) Navigator.pop(context);
      case ApiFailure(:final error):
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.arabicMessage)),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.lg,
        AppSizes.pagePadding,
        MediaQuery.of(context).viewInsets.bottom + AppSizes.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: Responsive.w(40),
              height: Responsive.h(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(Responsive.r(2)),
              ),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            AppStrings.transferToColleague,
            style: AppTypography.titleLarge.copyWith(
              color:
                  isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            AppStrings.transferChooseMethod,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textCaption,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.lg),

          // Reason field
          SekkaInputField(
            controller: _reasonCtrl,
            label: AppStrings.transferReason,
            maxLines: 2,
          ),
          SizedBox(height: AppSizes.md),

          // Scrollable content
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: Responsive.h(380)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Favorites section ──
                  if (_loadingFavorites)
                    _sectionShimmer()
                  else if (_favorites != null && _favorites!.isNotEmpty) ...[
                    _sectionHeader(
                      AppStrings.favoriteDriversTitle,
                      IconsaxPlusLinear.star,
                    ),
                    SizedBox(height: AppSizes.xs),
                    ..._favorites!.map((f) => _buildFavoriteTile(f, isDark)),
                    SizedBox(height: AppSizes.lg),
                  ],

                  // ── Nearby section ──
                  _sectionHeader(
                    AppStrings.transferPickColleague,
                    IconsaxPlusLinear.location,
                  ),
                  SizedBox(height: AppSizes.xs),
                  if (_loadingNearby)
                    _sectionShimmer()
                  else if (_nearbyError != null)
                    _errorWidget(_nearbyError!, onRetry: _loadNearby)
                  else if (_nearbyDrivers?.isEmpty ?? true)
                    _emptyWidget(AppStrings.transferNoNearby)
                  else
                    ...(_nearbyDrivers ?? [])
                        .map((d) => _buildNearbyTile(d, isDark)),

                  SizedBox(height: AppSizes.lg),

                  // ── Phone search section ──
                  _sectionHeader(
                    AppStrings.orSearchNewColleague,
                    IconsaxPlusLinear.search_normal,
                  ),
                  SizedBox(height: AppSizes.xs),
                  Row(
                    children: [
                      Expanded(
                        child: SekkaInputField(
                          controller: _phoneSearchCtrl,
                          label: AppStrings.searchByPhone,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.left,
                          onSubmitted: (_) => _searchByPhone(),
                        ),
                      ),
                      SizedBox(width: AppSizes.sm),
                      _searching
                          ? const SekkaLoading()
                          : IconButton(
                              onPressed: _searchByPhone,
                              icon: Icon(
                                IconsaxPlusLinear.search_normal,
                                color: AppColors.primary,
                                size: AppSizes.iconMd,
                              ),
                            ),
                    ],
                  ),
                  if (_searchResult != null) ...[
                    SizedBox(height: AppSizes.sm),
                    _buildSearchResultTile(_searchResult!, isDark),
                  ],
                  if (_searchError != null) ...[
                    SizedBox(height: AppSizes.sm),
                    Text(
                      _searchError!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                  SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          ),

          // Loading overlay for share link generation
          if (_generatingLink)
            Padding(
              padding: EdgeInsets.only(top: AppSizes.sm),
              child: const Center(child: SekkaLoading()),
            ),
        ],
      ),
    );
  }

  // ── Section helpers ──

  Widget _sectionHeader(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: AppColors.primary),
        SizedBox(width: AppSizes.xs),
        Text(
          label,
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionShimmer() => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.md),
        child: const Center(child: SekkaLoading()),
      );

  Widget _errorWidget(String message, {VoidCallback? onRetry}) => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSizes.sm),
              SekkaButton(
                label: AppStrings.retry,
                type: SekkaButtonType.secondary,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      );

  Widget _emptyWidget(String message) => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Center(
          child: Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textCaption,
            ),
          ),
        ),
      );

  // ── Tile builders ──

  Widget _buildFavoriteTile(FavoriteDriverModel fav, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: InkWell(
        onTap: fav.isAppUser && fav.linkedDriverId != null
            ? () => _transferDirect(fav.linkedDriverId!, fav.name)
            : () => _sendViaWhatsApp(fav.phone),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusBold.star_1,
                  color: AppColors.primary,
                  size: AppSizes.iconSm,
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fav.name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      fav.phone,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textCaption,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
              // Action indicator
              _transferActionBadge(fav.isAppUser, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyTile(NearbyDriverModel driver, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.xs),
      child: InkWell(
        onTap: () => _transferDirect(driver.driverId, driver.driverName),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusBold.user,
                  color: AppColors.primary,
                  size: AppSizes.iconSm,
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.driverName,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      '${driver.distanceKm.toStringAsFixed(1)} ${AppStrings.radarAway}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
              ),
              _transferActionBadge(true, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultTile(DriverByPhoneModel driver, bool isDark) {
    return InkWell(
      onTap: () => _transferDirect(driver.id, driver.name),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusBold.tick_circle,
                color: AppColors.success,
                size: AppSizes.iconSm,
              ),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (driver.vehicleType != null) ...[
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      driver.vehicleType!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _transferActionBadge(true, isDark),
          ],
        ),
      ),
    );
  }

  Widget _transferActionBadge(bool isAppUser, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(10),
        vertical: Responsive.h(6),
      ),
      decoration: BoxDecoration(
        color: isAppUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAppUser
                ? IconsaxPlusLinear.arrow_swap_horizontal
                : IconsaxPlusLinear.message,
            size: Responsive.r(14),
            color: isAppUser ? AppColors.primary : AppColors.success,
          ),
          SizedBox(width: Responsive.w(4)),
          Text(
            isAppUser
                ? AppStrings.transferDirect
                : AppStrings.sendViaWhatsApp,
            style: AppTypography.captionSmall.copyWith(
              color: isAppUser ? AppColors.primary : AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
