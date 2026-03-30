import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_expandable_section.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_toggle_tile.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.settings),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded && state.errorMessage != null) {
            context.showSnackBar(state.errorMessage!, isError: true);
            context
                .read<SettingsBloc>()
                .add(const SettingsErrorCleared());
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) return const SekkaLoading();
          if (state is SettingsLoaded) return _buildContent(context, state);
          if (state is SettingsError) return _buildError(context, state.message);
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          TextButton(
            onPressed: () => context
                .read<SettingsBloc>()
                .add(const SettingsLoadRequested()),
            child: Text(
              AppStrings.retry,
              style: AppTypography.titleMedium
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, SettingsLoaded state) {
    final s = state.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void toggle(String key, bool val) {
      context.read<SettingsBloc>().add(SettingsToggled(key, val));
    }

    void update(Map<String, dynamic> updates) {
      context.read<SettingsBloc>().add(SettingsUpdateRequested(updates));
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      children: [
        SizedBox(height: AppSizes.lg),

        // Saving indicator
        if (state.isSaving)
          Padding(
            padding: EdgeInsets.only(bottom: AppSizes.sm),
            child: const LinearProgressIndicator(color: AppColors.primary),
          ),

        // ── Appearance ──────────────────────────────
        SekkaExpandableSection(
          title: AppStrings.appearance,
          leadingIcon: IconsaxPlusLinear.brush_1,
          children: [
            _ThemeSelector(
              currentTheme: s.theme,
              isDark: isDark,
              onChanged: (val) => update({'theme': val}),
            ),
            SizedBox(height: AppSizes.sm),
            _LanguageSelector(
              currentLang: s.language,
              isDark: isDark,
              onChanged: (val) => update({'language': val}),
            ),
            SizedBox(height: AppSizes.sm),
            _NumberFormatSelector(
              currentFormat: s.numberFormat,
              isDark: isDark,
              onChanged: (val) => update({'numberFormat': val}),
            ),
          ],
        ),

        // ── Notifications ───────────────────────────
        SekkaExpandableSection(
          title: AppStrings.notifications,
          leadingIcon: IconsaxPlusLinear.notification,
          children: [
            SekkaToggleTile(
              label: AppStrings.notifyNewOrder,
              value: s.notifyNewOrder,
              onChanged: (val) => toggle('notifyNewOrder', val),
            ),
            SekkaToggleTile(
              label: AppStrings.notifyCashAlert,
              value: s.notifyCashAlert,
              onChanged: (val) => toggle('notifyCashAlert', val),
            ),
            SekkaToggleTile(
              label: AppStrings.notifyBreakReminder,
              value: s.notifyBreakReminder,
              onChanged: (val) => toggle('notifyBreakReminder', val),
            ),
            SekkaToggleTile(
              label: AppStrings.notifyMaintenance,
              value: s.notifyMaintenance,
              onChanged: (val) => toggle('notifyMaintenance', val),
            ),
            SekkaToggleTile(
              label: AppStrings.notifySettlement,
              value: s.notifySettlement,
              onChanged: (val) => toggle('notifySettlement', val),
            ),
            SekkaToggleTile(
              label: AppStrings.notifyAchievement,
              value: s.notifyAchievement,
              onChanged: (val) => toggle('notifyAchievement', val),
            ),
            Divider(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            _QuietHoursRow(
              start: s.quietHoursStart,
              end: s.quietHoursEnd,
              isDark: isDark,
              onChanged: (start, end) {
                context.read<SettingsBloc>().add(
                      SettingsQuietHoursUpdated(start: start, end: end),
                    );
              },
            ),
            Divider(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            SekkaToggleTile(
              label: AppStrings.notifySound,
              value: s.notifySound,
              onChanged: (val) => toggle('notifySound', val),
            ),
            SekkaToggleTile(
              label: AppStrings.notifyVibration,
              value: s.notifyVibration,
              onChanged: (val) => toggle('notifyVibration', val),
            ),
          ],
        ),

        // ── Focus Mode ──────────────────────────────
        SekkaExpandableSection(
          title: AppStrings.focusMode,
          leadingIcon: IconsaxPlusLinear.driver,
          children: [
            SekkaToggleTile(
              label: AppStrings.focusModeAuto,
              value: s.focusModeAutoTrigger,
              onChanged: (val) => toggle('focusModeAutoTrigger', val),
            ),
            SizedBox(height: AppSizes.sm),
            _SliderTile(
              label: AppStrings.focusModeSpeed,
              value: s.focusModeSpeedThreshold.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              unit: ' km/h',
              isDark: isDark,
              onChanged: (val) =>
                  update({'focusModeSpeedThreshold': val.round()}),
            ),
          ],
        ),

        // ── Delivery Preferences ────────────────────
        SekkaExpandableSection(
          title: AppStrings.deliveryPreferences,
          leadingIcon: IconsaxPlusLinear.box_1,
          children: [
            SekkaToggleTile(
              label: AppStrings.autoReceipt,
              value: s.autoSendReceipt,
              onChanged: (val) => toggle('autoSendReceipt', val),
            ),
            SizedBox(height: AppSizes.sm),
            _MapAppSelector(
              currentApp: s.preferredMapApp,
              isDark: isDark,
              onChanged: (val) => update({'preferredMapApp': val}),
            ),
            SizedBox(height: AppSizes.sm),
            _SliderTile(
              label: AppStrings.maxOrdersShift,
              value: (s.maxOrdersPerShift ?? 20).toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              unit: '',
              isDark: isDark,
              onChanged: (val) =>
                  update({'maxOrdersPerShift': val.round()}),
            ),
          ],
        ),

        // ── Location ────────────────────────────────
        SekkaExpandableSection(
          title: AppStrings.locationSettings,
          leadingIcon: IconsaxPlusLinear.location,
          children: [
            _HomeLocationRow(
              address: s.homeAddress,
              isDark: isDark,
              onTap: () => _showHomeLocationSheet(context, s.homeAddress),
            ),
            SekkaToggleTile(
              label: AppStrings.backToBase,
              value: s.backToBaseAlertEnabled,
              onChanged: (val) => toggle('backToBaseAlertEnabled', val),
            ),
            if (s.backToBaseAlertEnabled) ...[
              SizedBox(height: AppSizes.sm),
              _SliderTile(
                label: AppStrings.backToBaseRadius,
                value: s.backToBaseRadiusKm,
                min: 0.5,
                max: 10,
                divisions: 19,
                unit: ' km',
                isDark: isDark,
                onChanged: (val) => update({
                  'backToBaseRadiusKm':
                      double.parse(val.toStringAsFixed(1)),
                }),
              ),
            ],
          ],
        ),

        // ── Technical ───────────────────────────────
        SekkaExpandableSection(
          title: AppStrings.technicalSettings,
          leadingIcon: IconsaxPlusLinear.setting_3,
          children: [
            SekkaToggleTile(
              label: AppStrings.textToSpeech,
              value: s.textToSpeechEnabled,
              onChanged: (val) => toggle('textToSpeechEnabled', val),
            ),
            SekkaToggleTile(
              label: AppStrings.hapticFeedback,
              value: s.hapticFeedback,
              onChanged: (val) => toggle('hapticFeedback', val),
            ),
            SizedBox(height: AppSizes.sm),
            _SliderTile(
              label: AppStrings.locationInterval,
              value: s.locationTrackingInterval.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              unit: 's',
              isDark: isDark,
              onChanged: (val) =>
                  update({'locationTrackingInterval': val.round()}),
            ),
            SizedBox(height: AppSizes.md),
            _SliderTile(
              label: AppStrings.syncInterval,
              value: s.offlineSyncInterval.toDouble(),
              min: 10,
              max: 120,
              divisions: 11,
              unit: 's',
              isDark: isDark,
              onChanged: (val) =>
                  update({'offlineSyncInterval': val.round()}),
            ),
          ],
        ),

        SizedBox(height: AppSizes.xxxl),
      ],
    );
  }

  void _showHomeLocationSheet(BuildContext context, String? currentAddress) {
    final addressCtrl = TextEditingController(text: currentAddress);
    double? detectedLat;
    double? detectedLng;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final sheetDark = Theme.of(ctx).brightness == Brightness.dark;

            Future<void> detectLocation() async {
              setSheetState(() {});

              bool serviceEnabled =
                  await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                if (context.mounted) {
                  context.showSnackBar(
                    AppStrings.locationServiceDisabled,
                    isError: true,
                  );
                }
                return;
              }

              LocationPermission permission =
                  await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied ||
                    permission == LocationPermission.deniedForever) {
                  if (context.mounted) {
                    context.showSnackBar(
                      AppStrings.locationPermissionDenied,
                      isError: true,
                    );
                  }
                  return;
                }
              }

              final position = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.high,
                ),
              );
              setSheetState(() {
                detectedLat = position.latitude;
                detectedLng = position.longitude;
              });
              if (context.mounted) {
                context.showSnackBar(AppStrings.locationDetected);
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                AppSizes.xxl,
                AppSizes.pagePadding,
                MediaQuery.of(ctx).viewInsets.bottom + AppSizes.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.setHomeLocation,
                    style: AppTypography.headlineSmall.copyWith(
                      color: sheetDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                    ),
                  ),
                  SizedBox(height: AppSizes.xl),

                  // GPS button
                  SekkaButton(
                    label: detectedLat != null
                        ? '${AppStrings.locationDetected} (${detectedLat!.toStringAsFixed(4)}, ${detectedLng!.toStringAsFixed(4)})'
                        : AppStrings.useCurrentLocation,
                    type: detectedLat != null
                        ? SekkaButtonType.secondary
                        : SekkaButtonType.primary,
                    icon: IconsaxPlusLinear.gps,
                    onPressed: detectLocation,
                  ),

                  SizedBox(height: AppSizes.md),
                  SekkaInputField(
                    controller: addressCtrl,
                    label: AppStrings.enterAddress,
                    prefixIcon: IconsaxPlusLinear.location,
                  ),
                  SizedBox(height: AppSizes.xxl),
                  SekkaButton(
                    label: AppStrings.save,
                    onPressed: () {
                      final addr = addressCtrl.text.trim();
                      if (detectedLat == null || addr.isEmpty) return;
                      Navigator.pop(ctx);
                      context.read<SettingsBloc>().add(
                            SettingsHomeLocationSet(
                              latitude: detectedLat!,
                              longitude: detectedLng!,
                              address: addr,
                            ),
                          );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Private helper widgets ─────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.currentTheme,
    required this.isDark,
    required this.onChanged,
  });

  final int currentTheme;
  final bool isDark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppStrings.themeSystem,
      AppStrings.themeLight,
      AppStrings.themeDark,
    ];

    return Row(
      children: List.generate(3, (i) {
        final isActive = currentTheme == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: AppSizes.xs),
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : isDark
                        ? AppColors.backgroundDark
                        : AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : isDark
                          ? AppColors.borderDark
                          : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: AppTypography.bodySmall.copyWith(
                  color: isActive
                      ? AppColors.textOnPrimary
                      : isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.currentLang,
    required this.isDark,
    required this.onChanged,
  });

  final String currentLang;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.languageLabel,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
            ),
          ),
          _ChipButton(
            label: AppStrings.arabic,
            isActive: currentLang == 'ar',
            isDark: isDark,
            onTap: () => onChanged('ar'),
          ),
          SizedBox(width: AppSizes.sm),
          _ChipButton(
            label: AppStrings.english,
            isActive: currentLang == 'en',
            isDark: isDark,
            onTap: () => onChanged('en'),
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : isDark
                    ? AppColors.borderDark
                    : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isActive
                ? AppColors.textOnPrimary
                : isDark
                    ? AppColors.textBodyDark
                    : AppColors.textBody,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _NumberFormatSelector extends StatelessWidget {
  const _NumberFormatSelector({
    required this.currentFormat,
    required this.isDark,
    required this.onChanged,
  });

  final int currentFormat;
  final bool isDark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.numberFormatLabel,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
            ),
          ),
          _ChipButton(
            label: AppStrings.arabicNumerals,
            isActive: currentFormat == 0,
            isDark: isDark,
            onTap: () => onChanged(0),
          ),
          SizedBox(width: AppSizes.sm),
          _ChipButton(
            label: AppStrings.westernNumerals,
            isActive: currentFormat == 1,
            isDark: isDark,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _MapAppSelector extends StatelessWidget {
  const _MapAppSelector({
    required this.currentApp,
    required this.isDark,
    required this.onChanged,
  });

  final int currentApp;
  final bool isDark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppStrings.googleMaps,
      AppStrings.waze,
      AppStrings.otherMapApp,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.preferredMap,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Row(
            children: List.generate(labels.length, (i) {
              return Padding(
                padding: EdgeInsets.only(
                  left: i > 0 ? AppSizes.sm : 0,
                ),
                child: _ChipButton(
                  label: labels[i],
                  isActive: currentApp == i,
                  isDark: isDark,
                  onTap: () => onChanged(i),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _QuietHoursRow extends StatelessWidget {
  const _QuietHoursRow({
    required this.start,
    required this.end,
    required this.isDark,
    required this.onChanged,
  });

  final String? start;
  final String? end;
  final bool isDark;
  final void Function(String start, String end) onChanged;

  TimeOfDay _parse(String? value) {
    if (value == null || !value.contains(':')) {
      return const TimeOfDay(hour: 22, minute: 0);
    }
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 22,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final startTime = _parse(start);
    final endTime = _parse(end);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.moon,
            size: AppSizes.iconSm,
            color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
          ),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              AppStrings.quietHours,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
            ),
          ),
          _TimeChip(
            label: '${AppStrings.quietHoursFrom} ${start ?? '--:--'}',
            isDark: isDark,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: startTime,
              );
              if (picked != null) {
                onChanged(_format(picked), end ?? _format(endTime));
              }
            },
          ),
          SizedBox(width: AppSizes.sm),
          _TimeChip(
            label: '${AppStrings.quietHoursTo} ${end ?? '--:--'}',
            isDark: isDark,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: endTime,
              );
              if (picked != null) {
                onChanged(start ?? _format(startTime), _format(picked));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.captionSmall.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
        ),
      ),
    );
  }
}

class _HomeLocationRow extends StatelessWidget {
  const _HomeLocationRow({
    required this.address,
    required this.isDark,
    required this.onTap,
  });

  final String? address;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null && address!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.homeLocation,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.textBodyDark : AppColors.textBody,
                ),
              ),
            ),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      hasAddress ? address! : AppStrings.setHomeLocation,
                      style: AppTypography.bodySmall.copyWith(
                        color: hasAddress
                            ? (isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption)
                            : AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSizes.xs),
                  Icon(
                    IconsaxPlusLinear.edit_2,
                    size: AppSizes.iconSm,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.isDark,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final bool isDark;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                '${value.round()}$unit',
                style: AppTypography.captionSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor:
                isDark ? AppColors.borderDark : AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: Responsive.h(4),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
