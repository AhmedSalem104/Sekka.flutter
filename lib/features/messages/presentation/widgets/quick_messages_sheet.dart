import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/models/message_template_model.dart';
import '../../data/repositories/message_template_repository.dart';

class QuickMessagesSheet extends StatefulWidget {
  const QuickMessagesSheet({
    super.key,
    required this.repository,
    required this.onTemplateSelected,
  });

  final MessageTemplateRepository repository;
  final void Function(String messageText) onTemplateSelected;

  @override
  State<QuickMessagesSheet> createState() => _QuickMessagesSheetState();
}

class _QuickMessagesSheetState extends State<QuickMessagesSheet> {
  List<MessageTemplateModel>? _templates;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.repository.getTemplates();
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() { _templates = data; _isLoading = false; });
      case ApiFailure():
        setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTemplate(MessageTemplateModel template) async {
    widget.repository.recordUsage(template.id);
    widget.onTemplateSelected(template.messageText);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: Responsive.screenHeight * 0.6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.r(20))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: Responsive.h(10)),
            width: Responsive.w(40),
            height: Responsive.h(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.all(Responsive.w(20)),
            child: Row(
              children: [
                Icon(IconsaxPlusBold.message_text, color: AppColors.primary, size: Responsive.r(22)),
                SizedBox(width: Responsive.w(10)),
                Text(
                  'رسائل سريعة',
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: isDark ? AppColors.borderDark : AppColors.border),

          // Templates
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(Responsive.w(40)),
              child: const SekkaLoading(),
            )
          else if (_templates == null || _templates!.isEmpty)
            Padding(
              padding: EdgeInsets.all(Responsive.w(40)),
              child: Text(
                'مفيش رسائل جاهزة',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(20),
                  vertical: Responsive.h(10),
                ),
                itemCount: _templates!.length,
                separatorBuilder: (_, __) => SizedBox(height: Responsive.h(8)),
                itemBuilder: (_, index) {
                  final t = _templates![index];
                  return _buildTemplateItem(t, isDark);
                },
              ),
            ),

          SizedBox(height: Responsive.safePadding.bottom + Responsive.h(10)),
        ],
      ),
    );
  }

  Widget _buildTemplateItem(MessageTemplateModel t, bool isDark) {
    final categoryLabel = switch (t.category) {
      0 => 'توصيل',
      1 => 'دفع',
      2 => 'تحية',
      3 => 'اعتذار',
      _ => 'عام',
    };

    return GestureDetector(
      onTap: () => _selectTemplate(t),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(16),
          vertical: Responsive.h(14),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          borderRadius: BorderRadius.circular(Responsive.r(12)),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.messageText,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(4)),
                  Text(
                    categoryLabel,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              IconsaxPlusLinear.send_1,
              color: AppColors.primary,
              size: Responsive.r(18),
            ),
          ],
        ),
      ),
    );
  }
}
