import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';
import 'sekka_button.dart';

/// نتيجة اختيار الموقع من الخريطة.
class MapPickerResult {
  const MapPickerResult({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;
}

/// شاشة اختيار موقع على الخريطة — UX محسّن.
class SekkaMapPicker extends StatefulWidget {
  const SekkaMapPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.title,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final String? title;

  static Future<MapPickerResult?> show(
    BuildContext context, {
    double? initialLatitude,
    double? initialLongitude,
    String? title,
  }) {
    return Navigator.of(context).push<MapPickerResult>(
      MaterialPageRoute(
        builder: (_) => SekkaMapPicker(
          initialLatitude: initialLatitude,
          initialLongitude: initialLongitude,
          title: title,
        ),
      ),
    );
  }

  @override
  State<SekkaMapPicker> createState() => _SekkaMapPickerState();
}

class _SekkaMapPickerState extends State<SekkaMapPicker>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late LatLng _center;
  bool _isLocating = false;
  String? _currentAddress;
  bool _isLoadingAddress = false;
  Timer? _addressDebounce;
  Timer? _bounceDebounce;

  // Search
  final _searchController = TextEditingController();
  List<_SearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  Timer? _searchDebounce;

  // Animation
  late final AnimationController _pinAnimController;
  late final Animation<double> _pinBounce;

  static const _defaultLat = 30.0444;
  static const _defaultLng = 31.2357;
  static const _defaultZoom = 16.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _center = LatLng(
      widget.initialLatitude ?? _defaultLat,
      widget.initialLongitude ?? _defaultLng,
    );

    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pinBounce = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _pinAnimController, curve: Curves.easeOut),
    );

    if (widget.initialLatitude == null) {
      _goToCurrentLocation();
    } else {
      _reverseGeocode(_center);
    }
  }

  @override
  void dispose() {
    _pinAnimController.dispose();
    _searchController.dispose();
    _addressDebounce?.cancel();
    _bounceDebounce?.cancel();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ── Pin bounce ──

  void _triggerBounce() {
    _pinAnimController.forward().then((_) {
      if (mounted) _pinAnimController.reverse();
    });
  }

  // ── GPS ──

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;

      final newCenter = LatLng(position.latitude, position.longitude);
      setState(() => _center = newCenter);
      _mapController.move(newCenter, _defaultZoom);
      _triggerBounce();
      _reverseGeocode(newCenter);
    } catch (_) {
      // fallback to default
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ── Reverse Geocoding (Nominatim) ──

  Future<void> _reverseGeocode(LatLng point) async {
    _addressDebounce?.cancel();
    _addressDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      setState(() => _isLoadingAddress = true);

      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=${point.latitude}&lon=${point.longitude}'
          '&accept-language=ar&zoom=18&addressdetails=1',
        );
        final response = await http
            .get(url, headers: {'User-Agent': 'Sekka/1.0'}).timeout(
          const Duration(seconds: 5),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final displayName = data['display_name'] as String?;
          setState(() {
            _currentAddress = _shortenAddress(displayName);
            _isLoadingAddress = false;
          });
        } else {
          setState(() => _isLoadingAddress = false);
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingAddress = false);
      }
    });
  }

  String? _shortenAddress(String? full) {
    if (full == null) return null;
    // خد أول 3 أجزاء بس عشان يبقى قصير
    final parts = full.split('،').map((e) => e.trim()).toList();
    if (parts.length <= 3) return full;
    return parts.take(3).join('، ');
  }

  // ── Search (Nominatim) ──

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 600), () {
      _searchPlaces(query.trim());
    });
  }

  Future<void> _searchPlaces(String query) async {
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?format=json&q=${Uri.encodeComponent(query)}'
        '&countrycodes=eg&limit=5&accept-language=ar',
      );
      final response = await http
          .get(url, headers: {'User-Agent': 'Sekka/1.0'}).timeout(
        const Duration(seconds: 5),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List;
        setState(() {
          _searchResults = list
              .map((e) => _SearchResult(
                    name: e['display_name'] as String,
                    lat: double.parse(e['lat'] as String),
                    lng: double.parse(e['lon'] as String),
                  ))
              .toList();
          _showSearchResults = _searchResults.isNotEmpty;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(_SearchResult result) {
    final newCenter = LatLng(result.lat, result.lng);
    setState(() {
      _center = newCenter;
      _showSearchResults = false;
      _searchController.clear();
      _currentAddress = _shortenAddress(result.name);
    });
    _mapController.move(newCenter, _defaultZoom);
    _triggerBounce();
    FocusScope.of(context).unfocus();
  }

  // ── Zoom ──

  void _zoomIn() {
    final current = _mapController.camera.zoom;
    _mapController.move(_center, (current + 1).clamp(3, 18));
  }

  void _zoomOut() {
    final current = _mapController.camera.zoom;
    _mapController.move(_center, (current - 1).clamp(3, 18));
  }

  // ── Confirm ──

  void _confirmLocation() {
    Navigator.of(context).pop(
      MapPickerResult(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: _currentAddress,
      ),
    );
  }

  // ──────────────── BUILD ────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // ── الخريطة ──
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: _defaultZoom,
                // Disable fling inertia — user wanted the map to stop at the
                // exact release point instead of sliding past it
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.flingAnimation,
                ),
                onTap: (tapPosition, point) {
                  _mapController.move(point, _mapController.camera.zoom);
                  _triggerBounce();
                  FocusScope.of(context).unfocus();
                },
                onPositionChanged: (camera, hasGesture) {
                  _center = camera.center;
                  if (hasGesture) {
                    _reverseGeocode(camera.center);
                    _bounceDebounce?.cancel();
                    _bounceDebounce = Timer(
                      const Duration(milliseconds: 180),
                      () {
                        if (mounted) _triggerBounce();
                      },
                    );
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sekkaride.driver',
                ),
              ],
            ),

            // ── دبوس ثابت في المنتصف (tip points at geographic center) ──
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pinBounce,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                      0,
                      -Responsive.r(34) + _pinBounce.value,
                    ),
                    child: child,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: Responsive.r(52),
                        height: Responsive.r(52),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          IconsaxPlusBold.location,
                          color: Colors.white,
                          size: Responsive.r(28),
                        ),
                      ),
                      CustomPaint(
                        size: Size(Responsive.r(3), Responsive.r(16)),
                        painter: const _PinNeedlePainter(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Top bar: back + search ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.sm,
                    AppSizes.md,
                    0,
                  ),
                  child: Column(
                    children: [
                      // Search bar + back
                      Row(
                        children: [
                          _MapCircleButton(
                            icon: Icons.close,
                            onTap: () => Navigator.of(context).pop(),
                            isDark: isDark,
                          ),
                          SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Container(
                              height: Responsive.h(48),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusPill,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                style: AppTypography.bodyMedium,
                                textDirection: TextDirection.rtl,
                                decoration: InputDecoration(
                                  hintText: AppStrings.searchPlace,
                                  hintStyle: AppTypography.bodyMedium.copyWith(
                                    color: isDark
                                        ? AppColors.textCaptionDark
                                        : AppColors.textCaption,
                                  ),
                                  prefixIcon: _isSearching
                                      ? Padding(
                                          padding: EdgeInsets.all(
                                            Responsive.r(12),
                                          ),
                                          child: SizedBox(
                                            width: Responsive.r(20),
                                            height: Responsive.r(20),
                                            child:
                                                const CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          IconsaxPlusLinear.search_normal_1,
                                          color: AppColors.textCaption,
                                          size: AppSizes.iconMd,
                                        ),
                                  suffixIcon:
                                      _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.close,
                                                size: AppSizes.iconSm,
                                                color: AppColors.textCaption,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {
                                                  _searchResults = [];
                                                  _showSearchResults = false;
                                                });
                                              },
                                            )
                                          : null,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppSizes.lg,
                                    vertical: Responsive.h(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Search results dropdown
                      if (_showSearchResults)
                        Container(
                          margin: EdgeInsets.only(
                            top: AppSizes.xs,
                            right: Responsive.r(44) + AppSizes.sm,
                          ),
                          constraints: BoxConstraints(
                            maxHeight: Responsive.h(250),
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.sm,
                            ),
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                              indent: AppSizes.lg,
                              endIndent: AppSizes.lg,
                            ),
                            itemBuilder: (_, index) {
                              final result = _searchResults[index];
                              return InkWell(
                                onTap: () => _selectSearchResult(result),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSizes.lg,
                                    vertical: AppSizes.md,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        IconsaxPlusLinear.location,
                                        size: AppSizes.iconMd,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: AppSizes.sm),
                                      Expanded(
                                        child: Text(
                                          result.name,
                                          style: AppTypography.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Right side controls: GPS + Zoom ──
            Positioned(
              left: AppSizes.md,
              bottom: Responsive.h(200),
              child: Column(
                children: [
                  // GPS
                  _MapCircleButton(
                    icon: IconsaxPlusBold.gps,
                    onTap: _isLocating ? null : _goToCurrentLocation,
                    isDark: isDark,
                    isLoading: _isLocating,
                  ),
                  SizedBox(height: AppSizes.sm),
                  // Zoom in
                  _MapCircleButton(
                    icon: Icons.add,
                    onTap: _zoomIn,
                    isDark: isDark,
                  ),
                  SizedBox(height: AppSizes.xs),
                  // Zoom out
                  _MapCircleButton(
                    icon: Icons.remove,
                    onTap: _zoomOut,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // ── Bottom confirmation panel ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusXl),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.pagePadding,
                      AppSizes.lg,
                      AppSizes.pagePadding,
                      AppSizes.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Container(
                          width: Responsive.w(40),
                          height: Responsive.h(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusPill),
                          ),
                        ),
                        SizedBox(height: AppSizes.lg),

                        // Address row
                        Row(
                          children: [
                            Container(
                              width: Responsive.r(40),
                              height: Responsive.r(40),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSm,
                                ),
                              ),
                              child: Icon(
                                IconsaxPlusBold.location,
                                size: AppSizes.iconMd,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title ??
                                        AppStrings.pickLocationOnMap,
                                    style:
                                        AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: AppSizes.xs),
                                  if (_isLoadingAddress)
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: Responsive.r(12),
                                          height: Responsive.r(12),
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                          ),
                                        ),
                                        SizedBox(width: AppSizes.xs),
                                        Text(
                                          AppStrings.fetchingAddress,
                                          style: AppTypography.caption
                                              .copyWith(
                                            color: isDark
                                                ? AppColors.textCaptionDark
                                                : AppColors.textCaption,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      _currentAddress ??
                                          AppStrings.moveMapToSelect,
                                      style:
                                          AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textCaptionDark
                                            : AppColors.textCaption,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.md),

                        // Current location button
                        SekkaButton(
                          label: AppStrings.useCurrentLocation,
                          icon: IconsaxPlusBold.gps,
                          type: SekkaButtonType.secondary,
                          isLoading: _isLocating,
                          onPressed:
                              _isLocating ? null : _goToCurrentLocation,
                        ),
                        SizedBox(height: AppSizes.sm),

                        // Confirm button
                        SekkaButton(
                          label: AppStrings.confirmLocation,
                          icon: IconsaxPlusLinear.tick_circle,
                          onPressed: _confirmLocation,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pin needle painter ──

class _PinNeedlePainter extends CustomPainter {
  const _PinNeedlePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Circle button ──

class _MapCircleButton extends StatelessWidget {
  const _MapCircleButton({
    required this.icon,
    required this.isDark,
    this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Responsive.r(44),
        height: Responsive.r(44),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: AppSizes.iconSm,
                  height: AppSizes.iconSm,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: AppSizes.iconMd, color: AppColors.primary),
        ),
      ),
    );
  }
}

// ── Search result model ──

class _SearchResult {
  const _SearchResult({
    required this.name,
    required this.lat,
    required this.lng,
  });

  final String name;
  final double lat;
  final double lng;
}
