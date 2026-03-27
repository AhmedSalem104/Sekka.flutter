import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../domain/entities/emergency_contact_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../shared/network/api_exception.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<EmergencyContactEntity>? _contacts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<ProfileRepository>();
      final contacts = await repo.getEmergencyContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = AppStrings.unknownError; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.emergencyContacts,
          style: AppTypography.headlineSmall,
        ),
        leading: const SekkaBackButton(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(IconsaxPlusLinear.add, color: AppColors.textOnPrimary),
      ),
      body: _isLoading
          ? const SekkaLoading()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: AppTypography.bodyMedium),
                      SizedBox(height: AppSizes.lg),
                      TextButton(
                        onPressed: _loadContacts,
                        child: Text(AppStrings.retry,
                            style: AppTypography.titleMedium
                                .copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                )
              : _contacts!.isEmpty
                  ? SekkaEmptyState(
                      icon: IconsaxPlusLinear.call_calling,
                      title: AppStrings.noContacts,
                      actionLabel: AppStrings.addContact,
                      onAction: () => _showAddDialog(context),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadContacts,
                      child: ListView.separated(
                        padding: EdgeInsets.all(AppSizes.pagePadding),
                        itemCount: _contacts!.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, index) {
                          final c = _contacts![index];
                          return _ContactCard(
                            contact: c,
                            isDark: isDark,
                            onDelete: () => _deleteContact(c.id),
                          );
                        },
                      ),
                    ),
    );
  }

  Future<void> _deleteContact(String id) async {
    try {
      final repo = context.read<ProfileRepository>();
      await repo.deleteEmergencyContact(id);
      if (mounted) {
        setState(() => _contacts!.removeWhere((c) => c.id == id));
        context.showSnackBar('تم الحذف');
      }
    } on ApiException catch (e) {
      if (mounted) context.showSnackBar(e.message, isError: true);
    }
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.xxl,
          AppSizes.pagePadding,
          MediaQuery.of(ctx).viewInsets.bottom + AppSizes.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.addContact, style: AppTypography.headlineSmall),
            SizedBox(height: AppSizes.xl),
            SekkaInputField(
              controller: nameCtrl,
              label: AppStrings.contactName,
              prefixIcon: IconsaxPlusLinear.user,
            ),
            SizedBox(height: AppSizes.md),
            SekkaInputField(
              controller: phoneCtrl,
              label: AppStrings.contactPhone,
              prefixIcon: IconsaxPlusLinear.call,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: AppSizes.md),
            SekkaInputField(
              controller: relationCtrl,
              label: AppStrings.contactRelation,
              prefixIcon: IconsaxPlusLinear.people,
            ),
            SizedBox(height: AppSizes.xxl),
            SekkaButton(
              label: AppStrings.save,
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty ||
                    phoneCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                try {
                  final repo = context.read<ProfileRepository>();
                  await repo.addEmergencyContact({
                    'name': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    if (relationCtrl.text.trim().isNotEmpty)
                      'relation': relationCtrl.text.trim(),
                  });
                  _loadContacts();
                } on ApiException catch (e) {
                  if (mounted) context.showSnackBar(e.message, isError: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.isDark,
    required this.onDelete,
  });

  final EmergencyContactEntity contact;
  final bool isDark;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconsaxPlusLinear.user,
              size: AppSizes.iconMd,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  contact.phone,
                  style: AppTypography.bodySmall.copyWith(
                    color:
                        isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                  ),
                  textDirection: TextDirection.ltr,
                ),
                if (contact.relation != null) ...[
                  SizedBox(height: AppSizes.xs),
                  Text(
                    contact.relation!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              IconsaxPlusLinear.trash,
              size: AppSizes.iconMd,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
