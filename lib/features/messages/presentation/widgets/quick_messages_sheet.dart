import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/models/message_template_model.dart';
import '../../data/repositories/message_template_repository.dart';

// تصنيفات الرسائل
const _categories = <(int, String)>[
  (0, 'توصيل'),
  (1, 'دفع'),
  (2, 'تحية'),
  (3, 'اعتذار'),
  (4, 'عام'),
];

class QuickMessagesSheet extends StatefulWidget {
  const QuickMessagesSheet({
    super.key,
    required this.repository,
    required this.onTemplateSelected,
    this.customerPhone,
  });

  final MessageTemplateRepository repository;
  final void Function(String messageText) onTemplateSelected;
  final String? customerPhone;

  @override
  State<QuickMessagesSheet> createState() => _QuickMessagesSheetState();
}

class _QuickMessagesSheetState extends State<QuickMessagesSheet> {
  List<MessageTemplateModel> _templates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.repository.getTemplates();
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _templates = data;
          _isLoading = false;
        });
      case ApiFailure(:final error):
        setState(() {
          _isLoading = false;
          _errorMessage = error.arabicMessage;
        });
    }
  }

  // ── إضافة رسالة ──────────────────────────────────────────────────────

  void _showAddDialog() {
    _showTemplateDialog(
      title: 'إضافة رسالة',
      onSubmit: (messageText, category) async {
        final result = await widget.repository.create(
          messageText: messageText,
          category: category,
        );
        if (!mounted) return;
        switch (result) {
          case ApiSuccess(:final data):
            setState(() => _templates.add(data));
            SekkaMessageDialog.show(
              context,
              message: 'الرسالة اتضافت',
              type: SekkaMessageType.success,
            );
          case ApiFailure(:final error):
            SekkaMessageDialog.show(context, message: error.arabicMessage);
        }
      },
    );
  }

  // ── تعديل رسالة ──────────────────────────────────────────────────────

  void _showEditDialog(MessageTemplateModel template) {
    _showTemplateDialog(
      title: 'تعديل الرسالة',
      initialText: template.messageText,
      initialCategory: template.category,
      onSubmit: (messageText, category) async {
        final result = await widget.repository.update(
          template.id,
          messageText: messageText,
          category: category,
        );
        if (!mounted) return;
        switch (result) {
          case ApiSuccess(:final data):
            setState(() {
              final index = _templates.indexWhere((t) => t.id == template.id);
              if (index != -1) _templates[index] = data;
            });
            SekkaMessageDialog.show(
              context,
              message: 'الرسالة اتعدلت',
              type: SekkaMessageType.success,
            );
          case ApiFailure(:final error):
            SekkaMessageDialog.show(context, message: error.arabicMessage);
        }
      },
    );
  }

  // ── حذف رسالة ──────────────────────────────────────────────────────

  Future<void> _deleteTemplate(MessageTemplateModel template) async {
    final result = await widget.repository.delete(template.id);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess():
        setState(() => _templates.removeWhere((t) => t.id == template.id));
        SekkaMessageDialog.show(
          context,
          message: 'الرسالة اتمسحت',
          type: SekkaMessageType.success,
        );
      case ApiFailure(:final error):
        SekkaMessageDialog.show(context, message: error.arabicMessage);
    }
  }

  // ── Long press options ────────────────────────────────────────────────

  void _showOptionsSheet(MessageTemplateModel template) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Responsive.r(20)),
          ),
        ),
        child: SafeArea(
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
              SizedBox(height: Responsive.h(8)),

              // تعديل
              ListTile(
                leading: const Icon(
                  IconsaxPlusLinear.edit_2,
                  color: AppColors.primary,
                ),
                title: Text(
                  'تعديل الرسالة',
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(template);
                },
              ),

              // حذف
              ListTile(
                leading: const Icon(
                  IconsaxPlusLinear.trash,
                  color: AppColors.error,
                ),
                title: Text(
                  'حذف الرسالة',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(template);
                },
              ),
              SizedBox(height: Responsive.h(10)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(MessageTemplateModel template) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          title: Text(
            'حذف الرسالة؟',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          content: Text(
            template.messageText,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'لا',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.textBodyDark : AppColors.textBody,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTemplate(template);
              },
              child: Text(
                'امسح',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialog إضافة / تعديل ──────────────────────────────────────────────

  void _showTemplateDialog({
    required String title,
    String? initialText,
    int? initialCategory,
    required Future<void> Function(String messageText, int category) onSubmit,
  }) {
    final textController = TextEditingController(text: initialText);
    int selectedCategory = initialCategory ?? 4;
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final isDark =
              Theme.of(dialogContext).brightness == Brightness.dark;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              title: Text(
                title,
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نص الرسالة
                    SekkaInputField(
                      controller: textController,
                      label: 'نص الرسالة',
                      hint: 'اكتب الرسالة هنا...',
                      maxLines: 3,
                      prefixIcon: IconsaxPlusLinear.message_text_1,
                    ),
                    SizedBox(height: AppSizes.lg),

                    // التصنيف
                    Text(
                      'التصنيف',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: AppSizes.sm),
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: _categories.map((entry) {
                        final (value, label) = entry;
                        final isActive = selectedCategory == value;
                        return GestureDetector(
                          onTap: () => setDialogState(
                            () => selectedCategory = value,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.lg,
                              vertical: AppSizes.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : isDark
                                      ? AppColors.backgroundDark
                                      : AppColors.background,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusPill),
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
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    'إلغاء',
                    style: AppTypography.titleMedium.copyWith(
                      color:
                          isDark ? AppColors.textBodyDark : AppColors.textBody,
                    ),
                  ),
                ),
                SekkaButton(
                  label: initialText != null ? 'حفظ' : 'إضافة',
                  isLoading: isSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final text = textController.text.trim();
                          if (text.isEmpty) return;
                          setDialogState(() => isSubmitting = true);
                          await onSubmit(text, selectedCategory);
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _selectTemplate(MessageTemplateModel template) {
    widget.repository.recordUsage(template.id);
    widget.onTemplateSelected(template.messageText);
    if (mounted) Navigator.pop(context);
  }

  // ── فتح تطبيقات المراسلة ──────────────────────────────────────────────

  Future<void> _openMessagingApps(String messageText) async {
    final phone = widget.customerPhone;
    if (phone == null || phone.isEmpty) {
      // مفيش رقم — ننسخ بس
      _selectTemplate(
        MessageTemplateModel(
          id: '',
          messageText: messageText,
          category: 0,
          usageCount: 0,
          isSystemTemplate: false,
          sortOrder: 0,
        ),
      );
      return;
    }

    var normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized.startsWith('0')) {
      normalized = '+2$normalized';
    } else if (!normalized.startsWith('+')) {
      normalized = '+$normalized';
    }

    final uri = Uri(
      scheme: 'sms',
      path: normalized,
      queryParameters: {'body': messageText},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: Responsive.screenHeight * 0.6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(Responsive.r(20))),
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

          // Title + Add button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(20),
              vertical: Responsive.h(14),
            ),
            child: Row(
              children: [
                Icon(
                  IconsaxPlusBold.message_text,
                  color: AppColors.primary,
                  size: Responsive.r(22),
                ),
                SizedBox(width: Responsive.w(10)),
                Text(
                  'رسائل سريعة',
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showAddDialog,
                  child: Container(
                    padding: EdgeInsets.all(Responsive.r(6)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconsaxPlusLinear.add,
                      color: AppColors.primary,
                      size: Responsive.r(20),
                    ),
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
          else if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.all(Responsive.w(40)),
              child: Column(
                children: [
                  Icon(
                    IconsaxPlusLinear.wifi_square,
                    color: AppColors.statusFailed,
                    size: Responsive.r(40),
                  ),
                  SizedBox(height: Responsive.h(12)),
                  Text(
                    _errorMessage!,
                    style: AppTypography.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.textBodyDark : AppColors.textBody,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.h(16)),
                  GestureDetector(
                    onTap: _load,
                    child: Text(
                      'حاول تاني',
                      style: AppTypography.titleMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            )
          else if (_templates.isEmpty)
            Padding(
              padding: EdgeInsets.all(Responsive.w(40)),
              child: Column(
                children: [
                  Icon(
                    IconsaxPlusLinear.message_text,
                    color: isDark
                        ? AppColors.textCaptionDark
                        : AppColors.textCaption,
                    size: Responsive.r(40),
                  ),
                  SizedBox(height: Responsive.h(12)),
                  Text(
                    'مفيش رسائل جاهزة',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ],
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
                itemCount: _templates.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: Responsive.h(8)),
                itemBuilder: (_, index) {
                  final t = _templates[index];
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
    final categoryLabel = _categories
        .firstWhere(
          (c) => c.$1 == t.category,
          orElse: () => (4, 'عام'),
        )
        .$2;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: BorderRadius.circular(Responsive.r(12)),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // الرسالة — tap = select, long press = options
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _selectTemplate(t),
              onLongPress: () => _showOptionsSheet(t),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(16),
                  vertical: Responsive.h(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.messageText,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
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
            ),
          ),

          // أيقونة الإرسال — tap = فتح تطبيقات المراسلة
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.repository.recordUsage(t.id);
              _openMessagingApps(t.messageText);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(14),
                vertical: Responsive.h(14),
              ),
              child: Container(
                padding: EdgeInsets.all(Responsive.r(8)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconsaxPlusLinear.send_1,
                  color: AppColors.primary,
                  size: Responsive.r(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
