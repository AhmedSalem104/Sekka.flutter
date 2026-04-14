import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

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
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';

/// Bottom sheet that lists nearby colleague drivers and lets the user
/// transfer the current order to one of them.
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
  late final ColleagueRadarRepository _repo;
  final _reasonCtrl = TextEditingController();
  List<NearbyDriverModel>? _drivers;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = ColleagueRadarRepository(context.read<DioClient>().dio);
    _load();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } catch (_) {}

    final result = await _repo.getNearbyDrivers(
      latitude: pos?.latitude ?? 30.0444,
      longitude: pos?.longitude ?? 31.2357,
      radiusKm: 10,
    );

    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _drivers = data;
          _loading = false;
        });
      case ApiFailure(:final error):
        setState(() {
          _error = error.arabicMessage;
          _loading = false;
        });
    }
  }

  Future<void> _confirmAndTransfer(NearbyDriverModel driver) async {
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
            '${AppStrings.transferConfirmMsg} ${driver.driverName}؟',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                AppStrings.cancel,
                style: AppTypography.button.copyWith(
                  color: AppColors.textCaption,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                AppStrings.confirm,
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                ),
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
            targetDriverId: driver.driverId,
            reason: _reasonCtrl.text.trim().isEmpty
                ? null
                : _reasonCtrl.text.trim(),
          ),
        );
    Navigator.pop(context);
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
            AppStrings.transferPickColleague,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textCaption,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.lg),
          SekkaInputField(
            controller: _reasonCtrl,
            label: AppStrings.transferReason,
            maxLines: 2,
          ),
          SizedBox(height: AppSizes.md),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: Responsive.h(320)),
            child: _buildList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isDark) {
    if (_loading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.xl),
          child: const SekkaLoading(),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.md),
              SekkaButton(
                label: AppStrings.retry,
                type: SekkaButtonType.secondary,
                onPressed: _load,
              ),
            ],
          ),
        ),
      );
    }
    final drivers = _drivers ?? const [];
    if (drivers.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                IconsaxPlusLinear.user_search,
                size: AppSizes.iconXl,
                color: AppColors.textCaption,
              ),
              SizedBox(height: AppSizes.sm),
              Text(
                AppStrings.transferNoNearby,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textCaption,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: drivers.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSizes.xs),
      itemBuilder: (_, i) {
        final d = drivers[i];
        return InkWell(
          onTap: () => _confirmAndTransfer(d),
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
                    size: AppSizes.iconMd,
                  ),
                ),
                SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.driverName,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.textHeadlineDark
                              : AppColors.textHeadline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Responsive.h(2)),
                      Text(
                        '${d.distanceKm.toStringAsFixed(1)} ${AppStrings.radarAway}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textCaption,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  IconsaxPlusLinear.arrow_left_2,
                  size: AppSizes.iconSm,
                  color: AppColors.textCaption,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
