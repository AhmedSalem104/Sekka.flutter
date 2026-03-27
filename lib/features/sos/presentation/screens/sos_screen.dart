import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/repositories/sos_repository.dart';
import '../../data/models/sos_model.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key, required this.repository});
  final SosRepository repository;

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  SosModel? _activeSos;
  bool _isActivating = false;

  Future<void> _activateSos() async {
    setState(() => _isActivating = true);
    HapticFeedback.heavyImpact();

    // TODO: get real GPS from geolocator
    final result = await widget.repository.activate(
      latitude: 30.0444,
      longitude: 31.2357,
      notes: null,
    );

    if (!mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _activeSos = data;
          _isActivating = false;
        });
      case ApiFailure(:final error):
        setState(() => _isActivating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.arabicMessage)),
        );
    }
  }

  Future<void> _dismiss() async {
    if (_activeSos == null) return;
    final result = await widget.repository.dismiss(_activeSos!.id);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        Navigator.pop(context);
      case ApiFailure(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.arabicMessage)),
        );
    }
  }

  Future<void> _resolve() async {
    if (_activeSos == null) return;
    final result = await widget.repository.resolve(
      _activeSos!.id,
      wasFalseAlarm: false,
    );
    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        Navigator.pop(context);
      case ApiFailure(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.arabicMessage)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.error,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(24)),
          child: _activeSos != null ? _buildActiveState() : _buildTriggerState(),
        ),
      ),
    );
  }

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
          'حالة طوارئ',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.h(12)),
        Text(
          'اضغط الزر لإرسال إشارة طوارئ\nلجهات الاتصال والإدارة',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.h(48)),

        // SOS Button
        GestureDetector(
          onTap: _isActivating ? null : _activateSos,
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
              child: _isActivating
                  ? CircularProgressIndicator(
                      color: AppColors.error,
                      strokeWidth: 3,
                    )
                  : Text(
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

        // Cancel
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

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
          'تم تفعيل الطوارئ',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.h(12)),
        Text(
          'تم إبلاغ جهات الطوارئ والإدارة\nابقى في مكانك',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: Responsive.h(48)),

        // Resolve
        GestureDetector(
          onTap: _resolve,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary,
              borderRadius: BorderRadius.circular(Responsive.r(14)),
            ),
            child: Text(
              'تم حل المشكلة',
              style: AppTypography.titleLarge.copyWith(color: AppColors.success),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: Responsive.h(14)),

        // Dismiss
        GestureDetector(
          onTap: _dismiss,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: Responsive.h(16)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Responsive.r(14)),
              border: Border.all(color: AppColors.textOnPrimary.withValues(alpha: 0.5)),
            ),
            child: Text(
              'كان بالغلط',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textOnPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
