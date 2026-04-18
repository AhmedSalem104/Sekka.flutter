import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../core/widgets/sekka_search_bar.dart';
import '../../../../core/widgets/sekka_swipe_action.dart';
import '../../../partners/data/models/partner_model.dart';
import '../bloc/settlement_bloc.dart';
import '../widgets/add_partner_sheet.dart';
import '../widgets/settlement_type_selector.dart';

class CreateSettlementScreen extends StatefulWidget {
  const CreateSettlementScreen({super.key, this.preselectedPartner});

  final PartnerModel? preselectedPartner;

  @override
  State<CreateSettlementScreen> createState() => _CreateSettlementScreenState();
}

class _CreateSettlementScreenState extends State<CreateSettlementScreen> {
  final _amountController = TextEditingController();
  final _orderCountController = TextEditingController();
  final _notesController = TextEditingController();

  PartnerModel? _selectedPartner;
  int _selectedType = 0;

  @override
  void initState() {
    super.initState();
    _selectedPartner = widget.preselectedPartner;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _orderCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return _selectedPartner != null && amount > 0;
  }

  void _onSwipeConfirm() {
    if (!_isValid) return;

    final amount = double.parse(_amountController.text);
    final orderCount = int.tryParse(_orderCountController.text) ?? 0;

    context.read<SettlementBloc>().add(
          SettlementCreateRequested(
            partnerId: _selectedPartner!.id,
            amount: amount,
            settlementType: _selectedType,
            orderCount: orderCount,
            notes: _notesController.text.isEmpty
                ? null
                : _notesController.text,
          ),
        );
  }

  void _openPartnerPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<Object>(
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
        child: _PartnerPickerSheet(
          isDark: isDark,
          onPartnerCreated: () {
            context
                .read<SettlementBloc>()
                .add(const SettlementRefreshRequested());
          },
        ),
      ),
    ).then<void>((result) {
      if (!mounted) return;
      if (result is _PickerResult && result == _PickerResult.addNew) {
        showAddPartnerSheet(
          context,
          onPartnerCreated: () {
            context
                .read<SettlementBloc>()
                .add(const SettlementRefreshRequested());
          },
        );
      } else if (result is PartnerModel) {
        setState(() => _selectedPartner = result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.newHandover),
      body: BlocListener<SettlementBloc, SettlementState>(
        listener: (context, state) {
          if (state is SettlementCreated) {
            SekkaMessageDialog.show(
              context,
              message: AppStrings.handoverSuccess,
              type: SekkaMessageType.success,
            ).then((_) {
              if (context.mounted) {
                context
                    .read<SettlementBloc>()
                    .add(const SettlementRefreshRequested());
                Navigator.of(context).pop();
              }
            });
          }
          if (state is SettlementError) {
            SekkaMessageDialog.show(context, message: state.message);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding,
                  ),
                  children: [
                    SizedBox(height: AppSizes.xl),

                    // 1. Partner selector (tap → bottom sheet)
                    _PartnerSelector(
                      partner: _selectedPartner,
                      onTap: _openPartnerPicker,
                      onClear: widget.preselectedPartner != null
                          ? null
                          : () => setState(() => _selectedPartner = null),
                      isDark: isDark,
                    ),
                    SizedBox(height: AppSizes.xl),

                    // 2. Amount + Order count (side by side)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: SekkaInputField(
                            controller: _amountController,
                            hint: AppStrings.settlementAmount,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            prefixIcon: IconsaxPlusLinear.money_send,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        SizedBox(width: AppSizes.md),
                        Expanded(
                          child: SekkaInputField(
                            controller: _orderCountController,
                            hint: AppStrings.orderCountShort,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.xl),

                    // 3. Settlement type
                    Text(
                      AppStrings.settlementType,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textCaption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSizes.sm),
                    SettlementTypeSelector(
                      selectedType: _selectedType,
                      onTypeSelected: (type) =>
                          setState(() => _selectedType = type),
                    ),
                    SizedBox(height: AppSizes.xl),

                    // 4. Notes (optional)
                    SekkaInputField(
                      controller: _notesController,
                      label: AppStrings.settlementNotes,
                      hint: AppStrings.settlementNotes,
                      maxLines: 2,
                      prefixIcon: IconsaxPlusLinear.note,
                    ),
                    SizedBox(height: AppSizes.xxl),
                  ],
                ),
              ),

              // Swipe to confirm
              Padding(
                padding: EdgeInsets.all(AppSizes.pagePadding),
                child: BlocBuilder<SettlementBloc, SettlementState>(
                  builder: (context, state) {
                    if (state is SettlementCreating) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isValid ? 1.0 : 0.4,
                      child: IgnorePointer(
                        ignoring: !_isValid,
                        child: SekkaSwipeAction(
                          label: AppStrings.swipeToConfirmHandover,
                          onCompleted: _onSwipeConfirm,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Partner selector (tappable field → opens bottom sheet) ──
// ════════════════════════════════════════════════════════════════════════

class _PartnerSelector extends StatelessWidget {
  const _PartnerSelector({
    required this.partner,
    required this.onTap,
    required this.isDark,
    this.onClear,
  });

  final PartnerModel? partner;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool isDark;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (partner == null) {
      return _buildEmpty();
    }
    return _buildSelected();
  }

  Widget _buildEmpty() {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1.5,
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
                  IconsaxPlusLinear.shop,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  AppStrings.selectPartner,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textCaption,
                  ),
                ),
              ),
              Icon(
                IconsaxPlusLinear.arrow_down_1,
                size: AppSizes.iconSm,
                color: AppColors.textCaption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelected() {
    final color = _parseColor(partner!.color);
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: Responsive.r(40),
                height: Responsive.r(40),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  partner!.name.isNotEmpty ? partner!.name[0] : '?',
                  style: AppTypography.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner!.name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (partner!.phone != null)
                      Text(
                        partner!.phone!,
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.textCaption,
                        ),
                      ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    IconsaxPlusLinear.close_circle,
                    color: AppColors.textCaption,
                    size: AppSizes.iconMd,
                  ),
                )
              else
                Icon(
                  IconsaxPlusLinear.arrow_swap_horizontal,
                  size: AppSizes.iconSm,
                  color: AppColors.textCaption,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// ── Partner picker bottom sheet ──
// ════════════════════════════════════════════════════════════════════════

class _PartnerPickerSheet extends StatefulWidget {
  const _PartnerPickerSheet({
    required this.isDark,
    required this.onPartnerCreated,
  });

  final bool isDark;
  final VoidCallback onPartnerCreated;

  @override
  State<_PartnerPickerSheet> createState() => _PartnerPickerSheetState();
}

class _PartnerPickerSheetState extends State<_PartnerPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.lg,
          AppSizes.pagePadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: Responsive.w(40),
                height: Responsive.h(4),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? AppColors.borderDark
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              AppStrings.selectPartner,
              style: AppTypography.titleLarge.copyWith(
                color: widget.isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.md),
            SekkaSearchBar(
              hint: AppStrings.searchPartner,
              onChanged: (q) => setState(() => _query = q),
            ),
            SizedBox(height: AppSizes.md),
            Expanded(
              child: BlocBuilder<SettlementBloc, SettlementState>(
                builder: (context, state) {
                  final partners = state is SettlementLoaded
                      ? state.partners
                      : <PartnerModel>[];
                  final q = _query.trim().toLowerCase();
                  final filtered = q.isEmpty
                      ? partners
                      : partners.where((p) {
                          final name = p.name.toLowerCase();
                          final phone = (p.phone ?? '').toLowerCase();
                          return name.contains(q) || phone.contains(q);
                        }).toList();

                  return ListView.separated(
                    controller: scrollController,
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSizes.xs),
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return _AddPartnerTile(
                          isDark: widget.isDark,
                          onTap: () =>
                              Navigator.pop(context, _PickerResult.addNew),
                        );
                      }
                      final p = filtered[index];
                      return _PartnerTile(
                        partner: p,
                        isDark: widget.isDark,
                        onTap: () => Navigator.pop(context, p),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerTile extends StatelessWidget {
  const _PartnerTile({
    required this.partner,
    required this.isDark,
    required this.onTap,
  });

  final PartnerModel partner;
  final bool isDark;
  final VoidCallback onTap;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(partner.color);
    return Material(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        splashColor: color.withValues(alpha: 0.12),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                width: Responsive.r(36),
                height: Responsive.r(36),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  partner.name.isNotEmpty ? partner.name[0] : '?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (partner.phone != null)
                      Text(
                        partner.phone!,
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.textCaption,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PickerResult { addNew }

class _AddPartnerTile extends StatelessWidget {
  const _AddPartnerTile({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconsaxPlusLinear.add_circle,
                size: AppSizes.iconSm,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                AppStrings.addPartner,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
