import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/enums/sos_enums.dart';
import '../../data/models/sos_model.dart';
import 'sos_status_badge.dart';

class SosHistoryCard extends StatelessWidget {
  const SosHistoryCard({
    super.key,
    required this.sos,
    required this.isDark,
  });

  final SosModel sos;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final (iconData, iconColor) = _statusIcon;

    return Container(
      padding: EdgeInsets.all(Responsive.w(16)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(Responsive.r(16)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          Container(
            width: Responsive.r(44),
            height: Responsive.r(44),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: Responsive.r(22),
            ),
          ),
          SizedBox(width: Responsive.w(12)),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _title,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.textHeadlineDark
                              : AppColors.textHeadline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: Responsive.w(8)),
                    SosStatusBadge(status: sos.status, compact: true),
                  ],
                ),

                // Notes
                if (sos.notes != null && sos.notes!.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    sos.notes!,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Resolution
                if (sos.resolution != null && sos.resolution!.isNotEmpty) ...[
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    'الحل: ${sos.resolution}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.sosResolved,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Time
                SizedBox(height: Responsive.h(6)),
                Text(
                  _formatTime(sos.activatedAt),
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    if (sos.notes != null && sos.notes!.isNotEmpty) {
      final firstLine = sos.notes!.split('\n').first;
      if (firstLine.startsWith('[') && firstLine.contains(']')) {
        final end = firstLine.indexOf(']');
        return firstLine.substring(1, end);
      }
    }
    return 'حالة طوارئ';
  }

  (IconData, Color) get _statusIcon => switch (sos.status) {
        SosStatus.active => (IconsaxPlusBold.danger, AppColors.sosActive),
        SosStatus.resolved =>
          (IconsaxPlusBold.shield_tick, AppColors.sosResolved),
        SosStatus.dismissed =>
          (IconsaxPlusBold.close_circle, AppColors.sosDismissed),
        SosStatus.expired => (IconsaxPlusBold.timer, AppColors.sosExpired),
      };

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'من ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'من ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'من ${diff.inDays} يوم';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
