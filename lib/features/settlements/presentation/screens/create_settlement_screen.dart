import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../core/widgets/sekka_search_bar.dart';
import '../../../../core/widgets/sekka_swipe_action.dart';
import '../../../partners/data/models/partner_model.dart';
import '../bloc/settlement_bloc.dart';
import '../widgets/settlement_type_selector.dart';

class CreateSettlementScreen extends StatefulWidget {
  const CreateSettlementScreen({super.key, this.preselectedPartner});

  /// If navigating from partner detail, pre-select the partner.
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
  String _searchQuery = '';

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
                // Refresh settlements list then go back
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
                    SizedBox(height: AppSizes.lg),

                    // Partner selection
                    _buildPartnerSection(isDark),
                    SizedBox(height: AppSizes.xxl),

                    // Amount
                    SekkaInputField(
                      controller: _amountController,
                      label: AppStrings.settlementAmount,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: IconsaxPlusLinear.money_send,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: AppSizes.lg),

                    // Order count
                    SekkaInputField(
                      controller: _orderCountController,
                      label: AppStrings.orderCount,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      prefixIcon: IconsaxPlusLinear.box,
                    ),
                    SizedBox(height: AppSizes.lg),

                    // Settlement type
                    Text(
                      AppStrings.settlementType,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textHeadlineDark
                            : AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: AppSizes.sm),
                    SettlementTypeSelector(
                      selectedType: _selectedType,
                      onTypeSelected: (type) =>
                          setState(() => _selectedType = type),
                    ),
                    SizedBox(height: AppSizes.lg),

                    // Notes
                    SekkaInputField(
                      controller: _notesController,
                      label: AppStrings.settlementNotes,
                      hint: AppStrings.settlementNotes,
                      maxLines: 3,
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

  Widget _buildPartnerSection(bool isDark) {
    // If partner is already selected, show it
    if (_selectedPartner != null) {
      return _SelectedPartnerCard(
        partner: _selectedPartner!,
        onClear: widget.preselectedPartner != null
            ? null
            : () => setState(() => _selectedPartner = null),
        isDark: isDark,
      );
    }

    // Show partner picker
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        final partners = state is SettlementLoaded ? state.partners : <PartnerModel>[];
        final q = _searchQuery.trim().toLowerCase();
        final filtered = q.isEmpty
            ? partners
            : partners.where((p) {
                final name = p.name.toLowerCase();
                final phone = (p.phone ?? '').toLowerCase();
                return name.contains(q) || phone.contains(q);
              }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectPartner,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            SekkaSearchBar(
              hint: AppStrings.searchPartner,
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
            SizedBox(height: AppSizes.md),
            ...filtered.map(
              (partner) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm),
                child: _PartnerPickerItem(
                  partner: partner,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedPartner = partner),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SelectedPartnerCard extends StatelessWidget {
  const _SelectedPartnerCard({
    required this.partner,
    required this.isDark,
    this.onClear,
  });

  final PartnerModel partner;
  final bool isDark;
  final VoidCallback? onClear;

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
    return Container(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              partner.name.isNotEmpty ? partner.name[0] : '?',
              style: AppTypography.titleLarge.copyWith(color: color),
            ),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                if (partner.phone != null)
                  Text(
                    partner.phone!,
                    style: AppTypography.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
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
                color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                size: AppSizes.iconMd,
              ),
            ),
        ],
      ),
    );
  }
}

class _PartnerPickerItem extends StatelessWidget {
  const _PartnerPickerItem({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.cardPadding,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.avatarSm,
              height: AppSizes.avatarSm,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                partner.name.isNotEmpty ? partner.name[0] : '?',
                style: AppTypography.titleMedium.copyWith(color: color),
              ),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                partner.name,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
            ),
            Icon(
              IconsaxPlusLinear.arrow_left_2,
              size: AppSizes.iconSm,
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
          ],
        ),
      ),
    );
  }
}
