import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../data/models/badge_model.dart';
import '../bloc/badge_bloc.dart';
import '../bloc/badge_event.dart';
import '../bloc/badge_state.dart';
import 'qr_scanner_screen.dart';

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.badgeTitle),
      body: BlocConsumer<BadgeBloc, BadgeState>(
        listener: (context, state) {
          if (state is BadgeVerified) {
            _showVerifyResult(context, state, isDark);
          } else if (state is BadgeVerifyError) {
            _showVerifyErrorSheet(context, state, isDark);
          }
        },
        builder: (context, state) {
          return switch (state) {
            BadgeLoading() => const SekkaLoading(),
            BadgeError(:final message) => SekkaEmptyState(
                icon: IconsaxPlusLinear.warning_2,
                title: AppStrings.badgeLoadError,
                description: message,
                actionLabel: AppStrings.retry,
                onAction: () => context
                    .read<BadgeBloc>()
                    .add(const BadgeLoadRequested()),
              ),
            BadgeLoaded(:final badge) ||
            BadgeVerifying(:final badge) ||
            BadgeVerified(:final badge) ||
            BadgeVerifyError(:final badge) =>
              _BadgeBody(badge: badge),
            _ => const SekkaLoading(),
          };
        },
      ),
    );
  }

  void _showVerifyResult(
    BuildContext context,
    BadgeVerified state,
    bool isDark,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      builder: (_) => _VerifyResultSheet(
        isValid: state.result.isValid,
        driverName: state.result.driverName,
        message: state.result.isValid
            ? AppStrings.badgeVerifyValid
            : AppStrings.badgeVerifyInvalid,
        isDark: isDark,
      ),
    );
  }

  void _showVerifyErrorSheet(
    BuildContext context,
    BadgeVerifyError state,
    bool isDark,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      builder: (_) => _VerifyResultSheet(
        isValid: false,
        driverName: null,
        message: state.message,
        isDark: isDark,
      ),
    );
  }
}

// ── Badge body ────────────────────────────────────────────────────────────────

class _BadgeBody extends StatefulWidget {
  const _BadgeBody({required this.badge});

  final BadgeModel badge;

  @override
  State<_BadgeBody> createState() => _BadgeBodyState();
}

class _BadgeBodyState extends State<_BadgeBody> {
  final _cardKey = GlobalKey();
  bool _isCapturing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.xl,
      ),
      child: Column(
        children: [
          RepaintBoundary(
            key: _cardKey,
            child: _BadgeCard(badge: widget.badge, isDark: isDark),
          ),
          SizedBox(height: AppSizes.xl),
          SekkaButton(
            label: AppStrings.badgeShare,
            icon: IconsaxPlusLinear.share,
            onPressed: _isCapturing ? null : _shareAsImage,
            isLoading: _isCapturing,
            type: SekkaButtonType.secondary,
          ),
          SizedBox(height: AppSizes.md),
          SekkaButton(
            label: AppStrings.badgeScanQr,
            icon: IconsaxPlusLinear.scan,
            onPressed: () {
              final bloc = context.read<BadgeBloc>();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: const QrScannerScreen(),
                  ),
                ),
              );
            },
            type: SekkaButtonType.primary,
          ),
          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Future<void> _shareAsImage() async {
    setState(() => _isCapturing = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sekka_badge.png');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: AppStrings.badgeShareText,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }
}

// ── Badge Card ────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, required this.isDark});

  final BadgeModel badge;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.textCaption)
                .withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _CardHeader(badge: badge),
          Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                _StatsRow(badge: badge, isDark: isDark),
                SizedBox(height: AppSizes.lg),
                _InfoRow(
                  icon: IconsaxPlusLinear.calendar,
                  label: AppStrings.memberSince,
                  value: _formatDate(badge.memberSince),
                  isDark: isDark,
                ),
                SizedBox(height: AppSizes.lg),
                Divider(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  thickness: 1,
                ),
                SizedBox(height: AppSizes.lg),
                _QrSection(badge: badge, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

// ── Card header ───────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.badge});

  final BadgeModel badge;

  String _resolveImageUrl(String url) {
    if (url.startsWith('http')) return url;
    return 'https://sekka.runasp.net$url';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = badge.profileImageUrl;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.xxl,
        horizontal: AppSizes.lg,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: Responsive.r(84),
                height: Responsive.r(84),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textOnPrimary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          _resolveImageUrl(imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildAvatarPlaceholder(),
                        )
                      : _buildAvatarPlaceholder(),
                ),
              ),
              if (badge.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: Responsive.r(24),
                    height: Responsive.r(24),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                    child: Icon(
                      IconsaxPlusLinear.verify,
                      color: AppColors.textOnPrimary,
                      size: Responsive.r(14),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSizes.md),
          Text(
            badge.driverName,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.xs),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Text(
              '${AppStrings.level} ${badge.level}',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: Responsive.sp(12),
                fontWeight: FontWeight.w700,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() => Center(
        child: Icon(
          IconsaxPlusLinear.user,
          color: AppColors.textOnPrimary,
          size: Responsive.r(36),
        ),
      );
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.badge, required this.isDark});

  final BadgeModel badge;
  final bool isDark;

  String _vehicleLabel(int type) {
    final labels = AppStrings.vehicleTypesArabic;
    final keys = labels.keys.toList();
    if (type < 0 || type >= keys.length) return '';
    return labels[keys[type]] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCell(
            icon: IconsaxPlusLinear.star_1,
            iconColor: AppColors.warning,
            value: badge.averageRating == 0
                ? '-'
                : badge.averageRating.toStringAsFixed(1),
            label: AppStrings.averageRating,
            isDark: isDark,
          ),
        ),
        _VerticalDivider(isDark: isDark),
        Expanded(
          child: _StatCell(
            icon: IconsaxPlusLinear.box,
            iconColor: AppColors.primary,
            value: badge.totalDeliveries.toString(),
            label: AppStrings.totalDeliveries,
            isDark: isDark,
          ),
        ),
        _VerticalDivider(isDark: isDark),
        Expanded(
          child: _StatCell(
            icon: IconsaxPlusLinear.car,
            iconColor: AppColors.info,
            value: _vehicleLabel(badge.vehicleType),
            label: AppStrings.vehicleType,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: AppSizes.iconMd),
        SizedBox(height: AppSizes.xs),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: Responsive.sp(11),
            color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: Responsive.h(48),
      color: isDark ? AppColors.borderDark : AppColors.border,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.iconMd,
          color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
        ),
        SizedBox(width: AppSizes.sm),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
      ],
    );
  }
}

// ── QR Code section ───────────────────────────────────────────────────────────

class _QrSection extends StatelessWidget {
  const _QrSection({required this.badge, required this.isDark});

  final BadgeModel badge;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.badgeQrTitle,
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          AppStrings.badgeQrSubtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.lg),
        Container(
          padding: EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: QrImageView(
            data: badge.qrCodeToken,
            version: QrVersions.auto,
            size: Responsive.r(180),
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.textHeadline,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.textHeadline,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Verify result bottom sheet ────────────────────────────────────────────────

class _VerifyResultSheet extends StatelessWidget {
  const _VerifyResultSheet({
    required this.isValid,
    required this.message,
    required this.isDark,
    this.driverName,
  });

  final bool isValid;
  final String? driverName;
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.xxl,
        AppSizes.pagePadding,
        AppSizes.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Responsive.w(40),
            height: Responsive.h(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
          ),
          SizedBox(height: AppSizes.xxl),
          Container(
            width: Responsive.r(72),
            height: Responsive.r(72),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isValid ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
            ),
            child: Icon(
              isValid
                  ? IconsaxPlusLinear.verify
                  : IconsaxPlusLinear.close_circle,
              color: isValid ? AppColors.success : AppColors.error,
              size: Responsive.r(36),
            ),
          ),
          SizedBox(height: AppSizes.lg),
          Text(
            message,
            style: AppTypography.headlineSmall.copyWith(
              color: isValid ? AppColors.success : AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          if (driverName != null && driverName!.isNotEmpty) ...[
            SizedBox(height: AppSizes.sm),
            Text(
              driverName!,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: AppSizes.xxl),
          SekkaButton(
            label: AppStrings.ok,
            onPressed: () => Navigator.pop(context),
            type: SekkaButtonType.primary,
          ),
        ],
      ),
    );
  }
}
