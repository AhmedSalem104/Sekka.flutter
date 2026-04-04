import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/enums/address_type.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_search_bar.dart';
import '../../../../shared/network/api_result.dart';
import '../../../customers/data/models/address_model.dart';
import '../../../customers/data/repositories/address_repository.dart';

/// Bottom sheet that lets the driver pick a saved customer address,
/// search via autocomplete, or browse nearby addresses.
///
/// Returns the selected [AddressModel] or `null` if dismissed.
class AddressPickerSheet extends StatefulWidget {
  const AddressPickerSheet({
    super.key,
    required this.addressRepository,
    this.customerId,
    this.currentLatitude,
    this.currentLongitude,
  });

  final AddressRepository addressRepository;
  final String? customerId;
  final double? currentLatitude;
  final double? currentLongitude;

  /// Show the bottom sheet and return the selected address.
  static Future<AddressModel?> show(
    BuildContext context, {
    required AddressRepository addressRepository,
    String? customerId,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return showModalBottomSheet<AddressModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
      builder: (_) => AddressPickerSheet(
        addressRepository: addressRepository,
        customerId: customerId,
        currentLatitude: currentLatitude,
        currentLongitude: currentLongitude,
      ),
    );
  }

  @override
  State<AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<AddressPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  // Customer saved addresses
  List<AddressModel> _savedAddresses = [];
  bool _isLoadingSaved = false;

  // Autocomplete results
  List<AddressModel> _autocompleteResults = [];
  bool _isLoadingAutocomplete = false;

  // Nearby addresses
  List<AddressModel> _nearbyAddresses = [];
  bool _isLoadingNearby = false;

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
    _loadNearbyAddresses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Data Loading ──

  Future<void> _loadSavedAddresses() async {
    if (widget.customerId == null) return;
    setState(() => _isLoadingSaved = true);

    final result = await widget.addressRepository.searchAddresses(
      customerId: widget.customerId,
      pageSize: 20,
    );
    if (!mounted) return;

    setState(() {
      _isLoadingSaved = false;
      if (result case ApiSuccess(:final data)) {
        _savedAddresses = data;
      }
    });
  }

  Future<void> _loadNearbyAddresses() async {
    if (widget.currentLatitude == null || widget.currentLongitude == null) return;
    setState(() => _isLoadingNearby = true);

    final result = await widget.addressRepository.nearby(
      latitude: widget.currentLatitude!,
      longitude: widget.currentLongitude!,
      radiusKm: 5,
    );
    if (!mounted) return;

    setState(() {
      _isLoadingNearby = false;
      if (result case ApiSuccess(:final data)) {
        _nearbyAddresses = data;
      }
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _autocompleteResults = [];
        _isLoadingAutocomplete = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _isLoadingAutocomplete = true);

      final result = await widget.addressRepository.autocomplete(
        query.trim(),
        latitude: widget.currentLatitude,
        longitude: widget.currentLongitude,
      );
      if (!mounted) return;

      setState(() {
        _isLoadingAutocomplete = false;
        if (result case ApiSuccess(:final data)) {
          _autocompleteResults = data;
        }
      });
    });
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final result = await widget.addressRepository.deleteAddress(address.id);
    if (!mounted) return;

    if (result case ApiSuccess()) {
      setState(() {
        _savedAddresses.removeWhere((a) => a.id == address.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.addressDeleted)),
        );
      }
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.cardRadius),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.only(top: AppSizes.md),
              child: Center(
                child: Container(
                  width: Responsive.w(40),
                  height: Responsive.h(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Text(
                AppStrings.selectAddress,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              child: SekkaSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hint: AppStrings.searchAddress,
                autofocus: false,
              ),
            ),
            SizedBox(height: AppSizes.md),

            // Content
            Expanded(
              child: _isSearching
                  ? _buildAutocompleteList(isDark, scrollController)
                  : _buildMainContent(isDark, scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDark, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      children: [
        // ── Saved Addresses ──
        if (widget.customerId != null) ...[
          _buildSectionHeader(
            AppStrings.savedAddresses,
            IconsaxPlusLinear.archive_book,
            isDark,
          ),
          SizedBox(height: AppSizes.sm),
          if (_isLoadingSaved)
            _buildLoading()
          else if (_savedAddresses.isEmpty)
            _buildEmpty(AppStrings.noSavedAddresses, isDark)
          else
            ..._savedAddresses.map(
              (addr) => _AddressTile(
                address: addr,
                isDark: isDark,
                onTap: () => Navigator.pop(context, addr),
                onDelete: () => _deleteAddress(addr),
              ),
            ),
          SizedBox(height: AppSizes.xl),
        ],

        // ── Nearby Addresses ──
        if (widget.currentLatitude != null) ...[
          _buildSectionHeader(
            AppStrings.nearbyAddresses,
            IconsaxPlusLinear.location,
            isDark,
          ),
          SizedBox(height: AppSizes.sm),
          if (_isLoadingNearby)
            _buildLoading()
          else if (_nearbyAddresses.isEmpty)
            _buildEmpty(AppStrings.noNearbyAddresses, isDark)
          else
            ..._nearbyAddresses.map(
              (addr) => _AddressTile(
                address: addr,
                isDark: isDark,
                onTap: () => Navigator.pop(context, addr),
              ),
            ),
          SizedBox(height: AppSizes.xl),
        ],

        SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  Widget _buildAutocompleteList(
    bool isDark,
    ScrollController scrollController,
  ) {
    if (_isLoadingAutocomplete) return _buildLoading();

    if (_autocompleteResults.isEmpty) {
      return Center(
        child: _buildEmpty(AppStrings.noResults, isDark),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      itemCount: _autocompleteResults.length,
      itemBuilder: (_, index) => _AddressTile(
        address: _autocompleteResults[index],
        isDark: isDark,
        onTap: () => Navigator.pop(context, _autocompleteResults[index]),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: Responsive.r(18),
          color: AppColors.primary,
        ),
        SizedBox(width: AppSizes.sm),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: isDark
                ? AppColors.textHeadlineDark
                : AppColors.textHeadline,
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.xxl),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEmpty(String message, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
      child: Text(
        message,
        style: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Address Tile ──

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.isDark,
    required this.onTap,
    this.onDelete,
  });

  final AddressModel address;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final type = AddressType.fromValue(address.addressType);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Type icon
              Container(
                width: Responsive.r(40),
                height: Responsive.r(40),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  _addressTypeIcon(type),
                  size: Responsive.r(20),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSizes.md),

              // Address text + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.addressText,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.xs),
                    Row(
                      children: [
                        Text(
                          _addressTypeLabel(type),
                          style: AppTypography.captionSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (address.visitCount > 0) ...[
                          SizedBox(width: AppSizes.sm),
                          Text(
                            '${address.visitCount} ${AppStrings.visits}',
                            style: AppTypography.captionSmall.copyWith(
                              color: isDark
                                  ? AppColors.textCaptionDark
                                  : AppColors.textCaption,
                            ),
                          ),
                        ],
                        if (address.distanceKm != null) ...[
                          SizedBox(width: AppSizes.sm),
                          Icon(
                            IconsaxPlusLinear.routing_2,
                            size: Responsive.r(12),
                            color: isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption,
                          ),
                          SizedBox(width: AppSizes.xs),
                          Text(
                            '${address.distanceKm!.toStringAsFixed(1)} km',
                            style: AppTypography.captionSmall.copyWith(
                              color: isDark
                                  ? AppColors.textCaptionDark
                                  : AppColors.textCaption,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (address.landmarks != null &&
                        address.landmarks!.isNotEmpty) ...[
                      SizedBox(height: AppSizes.xs),
                      Text(
                        address.landmarks!,
                        style: AppTypography.captionSmall.copyWith(
                          color: isDark
                              ? AppColors.textCaptionDark
                              : AppColors.textCaption,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Delete button (only for saved)
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    IconsaxPlusLinear.trash,
                    size: Responsive.r(18),
                    color: AppColors.error,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _addressTypeIcon(AddressType type) {
    return switch (type) {
      AddressType.home => IconsaxPlusLinear.home_2,
      AddressType.work => IconsaxPlusLinear.building,
      AddressType.shop => IconsaxPlusLinear.shop,
      AddressType.restaurant => IconsaxPlusLinear.coffee,
      AddressType.warehouse => IconsaxPlusLinear.box_1,
      AddressType.other => IconsaxPlusLinear.location,
    };
  }

  static String _addressTypeLabel(AddressType type) {
    return switch (type) {
      AddressType.home => 'بيت',
      AddressType.work => 'شغل',
      AddressType.shop => 'محل',
      AddressType.restaurant => 'مطعم',
      AddressType.warehouse => 'مخزن',
      AddressType.other => 'أخرى',
    };
  }
}
