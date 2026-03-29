import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/enums/sos_enums.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/models/sos_model.dart';
import '../../data/repositories/sos_repository.dart';
import '../screens/sos_history_screen.dart';

enum _ScreenState { trigger, details, active, resolve }

class SosScreen extends StatefulWidget {
  const SosScreen({super.key, required this.repository});
  final SosRepository repository;

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  _ScreenState _state = _ScreenState.trigger;
  SosModel? _activeSos;
  bool _isLoading = false;

  // Details state
  SosProblemType? _selectedProblem;
  final _notesController = TextEditingController();

  // Resolve state
  final _resolutionController = TextEditingController();
  bool _wasFalseAlarm = false;

  @override
  void dispose() {
    _notesController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  // ── API Actions ──

  Future<void> _activateSos() async {
    setState(() => _isLoading = true);
    HapticFeedback.heavyImpact();

    final problemLabel = _selectedProblem?.arabic ?? '';
    final userNotes = _notesController.text.trim();
    final notes = [
      if (problemLabel.isNotEmpty) '[$problemLabel]',
      if (userNotes.isNotEmpty) userNotes,
    ].join('\n');

    // TODO: get real GPS from geolocator
    final result = await widget.repository.activate(
      latitude: 30.0444,
      longitude: 31.2357,
      notes: notes.isNotEmpty ? notes : null,
    );

    if (!mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _activeSos = data;
          _isLoading = false;
          _state = _ScreenState.active;
        });
      case ApiFailure(:final error):
        setState(() => _isLoading = false);
        _showError(error.arabicMessage);
    }
  }

  Future<void> _resolve() async {
    if (_activeSos == null) return;
    setState(() => _isLoading = true);

    final result = await widget.repository.resolve(
      _activeSos!.id,
      resolution: _resolutionController.text.trim().isNotEmpty
          ? _resolutionController.text.trim()
          : null,
      wasFalseAlarm: _wasFalseAlarm,
    );

    if (!mounted) return;

    switch (result) {
      case ApiSuccess():
        Navigator.pop(context);
      case ApiFailure(:final error):
        setState(() => _isLoading = false);
        _showError(error.arabicMessage);
    }
  }

  Future<void> _dismiss() async {
    if (_activeSos == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.sosDismiss,
          style: AppTypography.titleLarge,
          textAlign: TextAlign.center,
        ),
        content: Text(
          AppStrings.sosDismissConfirm,
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
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
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    final result = await widget.repository.dismiss(_activeSos!.id);

    if (!mounted) return;

    switch (result) {
      case ApiSuccess():
        Navigator.pop(context);
      case ApiFailure(:final error):
        setState(() => _isLoading = false);
        _showError(error.arabicMessage);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openHistory() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SosHistoryScreen(repository: widget.repository),
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.error,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(24)),
          child: switch (_state) {
            _ScreenState.trigger => _buildTriggerState(),
            _ScreenState.details => _buildDetailsState(),
            _ScreenState.active => _buildActiveState(),
            _ScreenState.resolve => _buildResolveState(),
          },
        ),
      ),
    );
  }

  // ── State 1: Trigger ──

  Widget _buildTriggerState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          IconsaxPlusBold.danger,
          color: AppColors.textOnPrimary,
          size: Responsive.r(60),
        ),
        SizedBox(height: Responsive.h(24)),
        Text(
          AppStrings.sosEmergency,
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.h(12)),
        Text(
          AppStrings.sosSubtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.h(48)),

        // SOS Button
        GestureDetector(
          onTap: () => setState(() => _state = _ScreenState.details),
          child: Container(
            width: Responsive.r(140),
            height: Responsive.r(140),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: Responsive.sp(32),
                  fontWeight: FontWeight.w800,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: Responsive.h(48)),

        // History link
        GestureDetector(
          onTap: _openHistory,
          child: Text(
            AppStrings.sosHistory,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textOnPrimary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textOnPrimary.withValues(alpha: 0.5),
            ),
          ),
        ),

        SizedBox(height: Responsive.h(16)),

        // Cancel
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            AppStrings.cancel,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  // ── State 2: Details ──

  Widget _buildDetailsState() {
    return Column(
      children: [
        // Back arrow
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: GestureDetector(
            onTap: () => setState(() => _state = _ScreenState.trigger),
            child: Icon(
              IconsaxPlusLinear.arrow_right_3,
              color: AppColors.textOnPrimary,
              size: Responsive.r(28),
            ),
          ),
        ),

        SizedBox(height: Responsive.h(16)),

        Text(
          AppStrings.sosSelectProblem,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: Responsive.h(24)),

        // Problem type chips
        Wrap(
          spacing: Responsive.w(10),
          runSpacing: Responsive.h(10),
          alignment: WrapAlignment.center,
          children: SosProblemType.values.map((type) {
            final isSelected = _selectedProblem == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedProblem = type),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(16),
                  vertical: Responsive.h(12),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.textOnPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Responsive.r(12)),
                  border: isSelected
                      ? null
                      : Border.all(
                          color:
                              AppColors.textOnPrimary.withValues(alpha: 0.3),
                        ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _problemIcon(type),
                      color: isSelected
                          ? AppColors.error
                          : AppColors.textOnPrimary,
                      size: Responsive.r(18),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    Text(
                      type.arabic,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.error
                            : AppColors.textOnPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: Responsive.h(24)),

        // Notes field
        Text(
          AppStrings.sosAddNotes,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: Responsive.h(8)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(Responsive.r(12)),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            textDirection: TextDirection.rtl,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.sosNotesHint,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textOnPrimary.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(Responsive.w(14)),
            ),
          ),
        ),

        const Spacer(),

        // Send button
        SizedBox(
          width: double.infinity,
          height: Responsive.h(56),
          child: ElevatedButton(
            onPressed:
                _isLoading || _selectedProblem == null ? null : _activateSos,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textOnPrimary,
              foregroundColor: AppColors.error,
              disabledBackgroundColor:
                  AppColors.textOnPrimary.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.r(12)),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: Responsive.r(24),
                    height: Responsive.r(24),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.error,
                    ),
                  )
                : Text(
                    AppStrings.sosSendSignal,
                    style: AppTypography.button.copyWith(
                      color: AppColors.error,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── State 3: Active ──

  Widget _buildActiveState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          IconsaxPlusBold.shield_tick,
          color: AppColors.textOnPrimary,
          size: Responsive.r(60),
        ),
        SizedBox(height: Responsive.h(24)),
        Text(
          AppStrings.sosActivated,
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.h(12)),
        Text(
          AppStrings.sosActivatedSubtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),

        // Problem type recap
        if (_selectedProblem != null) ...[
          SizedBox(height: Responsive.h(20)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(16),
              vertical: Responsive.h(10),
            ),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Responsive.r(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _problemIcon(_selectedProblem!),
                  color: AppColors.textOnPrimary,
                  size: Responsive.r(18),
                ),
                SizedBox(width: Responsive.w(8)),
                Text(
                  _selectedProblem!.arabic,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: Responsive.h(48)),

        // Resolve button
        SizedBox(
          width: double.infinity,
          height: Responsive.h(56),
          child: ElevatedButton(
            onPressed: () => setState(() => _state = _ScreenState.resolve),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textOnPrimary,
              foregroundColor: AppColors.success,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.r(14)),
              ),
            ),
            child: Text(
              AppStrings.sosResolve,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ),

        SizedBox(height: Responsive.h(14)),

        // Dismiss button
        SizedBox(
          width: double.infinity,
          height: Responsive.h(56),
          child: OutlinedButton(
            onPressed: _isLoading ? null : _dismiss,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textOnPrimary,
              side: BorderSide(
                color: AppColors.textOnPrimary.withValues(alpha: 0.5),
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.r(14)),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: Responsive.r(24),
                    height: Responsive.r(24),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : Text(
                    AppStrings.sosDismiss,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── State 4: Resolve ──

  Widget _buildResolveState() {
    return Column(
      children: [
        // Back to active
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: GestureDetector(
            onTap: () => setState(() => _state = _ScreenState.active),
            child: Icon(
              IconsaxPlusLinear.arrow_right_3,
              color: AppColors.textOnPrimary,
              size: Responsive.r(28),
            ),
          ),
        ),

        SizedBox(height: Responsive.h(24)),

        Icon(
          IconsaxPlusBold.shield_tick,
          color: AppColors.textOnPrimary,
          size: Responsive.r(48),
        ),

        SizedBox(height: Responsive.h(16)),

        Text(
          AppStrings.sosResolutionNote,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: Responsive.h(24)),

        // Resolution notes
        Container(
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(Responsive.r(12)),
          ),
          child: TextField(
            controller: _resolutionController,
            maxLines: 4,
            textDirection: TextDirection.rtl,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.sosResolutionHint,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textOnPrimary.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(Responsive.w(14)),
            ),
          ),
        ),

        SizedBox(height: Responsive.h(16)),

        // False alarm checkbox
        GestureDetector(
          onTap: () => setState(() => _wasFalseAlarm = !_wasFalseAlarm),
          child: Row(
            children: [
              Container(
                width: Responsive.r(24),
                height: Responsive.r(24),
                decoration: BoxDecoration(
                  color: _wasFalseAlarm
                      ? AppColors.textOnPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(Responsive.r(6)),
                  border: Border.all(
                    color: AppColors.textOnPrimary.withValues(
                      alpha: _wasFalseAlarm ? 1.0 : 0.5,
                    ),
                    width: 2,
                  ),
                ),
                child: _wasFalseAlarm
                    ? Icon(
                        Icons.check,
                        color: AppColors.error,
                        size: Responsive.r(16),
                      )
                    : null,
              ),
              SizedBox(width: Responsive.w(10)),
              Text(
                AppStrings.sosWasFalseAlarm,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Confirm resolve button
        SizedBox(
          width: double.infinity,
          height: Responsive.h(56),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resolve,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textOnPrimary,
              foregroundColor: AppColors.success,
              disabledBackgroundColor:
                  AppColors.textOnPrimary.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.r(12)),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: Responsive.r(24),
                    height: Responsive.r(24),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.success,
                    ),
                  )
                : Text(
                    AppStrings.sosConfirmResolve,
                    style: AppTypography.button.copyWith(
                      color: AppColors.success,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ──

  IconData _problemIcon(SosProblemType type) => switch (type) {
        SosProblemType.accident => IconsaxPlusBold.car,
        SosProblemType.vehicleBreakdown => IconsaxPlusBold.setting_2,
        SosProblemType.theft => IconsaxPlusBold.shield_slash,
        SosProblemType.assault => IconsaxPlusBold.warning_2,
        SosProblemType.healthEmergency => IconsaxPlusBold.health,
        SosProblemType.roadBlock => IconsaxPlusBold.forbidden_2,
        SosProblemType.other => IconsaxPlusBold.more,
      };
}
