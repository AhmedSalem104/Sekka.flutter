import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_map_picker.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../partners/data/models/create_partner_model.dart';
import '../../../partners/data/models/partner_model.dart';
import '../../../partners/data/repositories/partner_repository.dart';

/// Shows a bottom sheet to add a new partner.
Future<void> showAddPartnerSheet(
  BuildContext context, {
  VoidCallback? onPartnerCreated,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddPartnerSheetContent(
      repository: PartnerRepository(context.read<DioClient>().dio),
      onPartnerCreated: onPartnerCreated,
    ),
  );
}

// Partner type options
final _partnerTypes = [
  AppStrings.restaurantType,
  AppStrings.shopType,
  AppStrings.pharmacyType,
  AppStrings.supermarketType,
  AppStrings.warehouseType,
  AppStrings.eCommerceType,
];

// Commission type options
final _commissionTypes = [
  AppStrings.commissionFixed,
  AppStrings.commissionPercentage,
  AppStrings.commissionMonthly,
];

// Payment method options
final _paymentMethods = [
  AppStrings.paymentCash,
  AppStrings.paymentWallet,
  AppStrings.paymentInstaPay,
  AppStrings.paymentCard,
];

// Auto color per partner type
const _typeColors = [
  '#FC5D01', // restaurant — orange
  '#3182CE', // shop — blue
  '#38A169', // pharmacy — green
  '#805AD5', // supermarket — purple
  '#ECC94B', // warehouse — yellow
  '#E53E3E', // e-commerce — red
];

class _AddPartnerSheetContent extends StatefulWidget {
  const _AddPartnerSheetContent({
    required this.repository,
    this.onPartnerCreated,
  });

  final PartnerRepository repository;
  final VoidCallback? onPartnerCreated;

  @override
  State<_AddPartnerSheetContent> createState() =>
      _AddPartnerSheetContentState();
}

class _AddPartnerSheetContentState extends State<_AddPartnerSheetContent> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _commissionValueController = TextEditingController();
  final _receiptHeaderController = TextEditingController();

  int _partnerType = 0;
  int _commissionType = 0;
  int _paymentMethod = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _commissionValueController.dispose();
    _receiptHeaderController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);

    final commissionVal =
        double.tryParse(_commissionValueController.text) ?? 0;

    final data = CreatePartnerModel(
      name: _nameController.text.trim(),
      partnerType: _partnerType,
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      commissionType: _commissionType,
      commissionValue: commissionVal,
      defaultPaymentMethod: _paymentMethod,
      color: _typeColors[_partnerType % _typeColors.length],
      receiptHeader: _receiptHeaderController.text.trim().isEmpty
          ? null
          : _receiptHeaderController.text.trim(),
    );

    final result = await widget.repository.createPartner(data: data);

    if (!mounted) return;

    switch (result) {
      case ApiSuccess<PartnerModel>():
        widget.onPartnerCreated?.call();
        Navigator.of(context).pop();
        SekkaMessageDialog.show(
          context,
          message: AppStrings.partnerAddedSuccess,
          type: SekkaMessageType.success,
        );
      case ApiFailure<PartnerModel>(:final error):
        setState(() => _isLoading = false);
        SekkaMessageDialog.show(context, message: error.arabicMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: EdgeInsets.only(top: AppSizes.md),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(AppSizes.xxl),
              children: [
                // Title
                Text(
                  AppStrings.addPartner,
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.xxl),

                // Name *
                SekkaInputField(
                  controller: _nameController,
                  label: AppStrings.partnerName,
                  hint: AppStrings.partnerName,
                  prefixIcon: IconsaxPlusLinear.shop,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: AppSizes.lg),

                // Phone *
                SekkaInputField(
                  controller: _phoneController,
                  label: AppStrings.partnerPhone,
                  hint: '01xxxxxxxxx',
                  prefixIcon: IconsaxPlusLinear.call,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: AppSizes.lg),

                // Address
                SekkaInputField(
                  controller: _addressController,
                  label: AppStrings.partnerAddress,
                  hint: AppStrings.partnerAddress,
                  prefixIcon: IconsaxPlusLinear.location,
                  suffixIcon: IconsaxPlusLinear.map,
                  onSuffixTap: () async {
                    final result = await SekkaMapPicker.show(
                      context,
                      title: AppStrings.partnerAddress,
                    );
                    if (result != null && result.address != null) {
                      _addressController.text = result.address!;
                    }
                  },
                  readOnly: false,
                ),
                SizedBox(height: AppSizes.lg),

                // Partner type
                _buildChipSelector(
                  label: AppStrings.partnerType,
                  options: _partnerTypes,
                  selected: _partnerType,
                  onSelected: (i) => setState(() => _partnerType = i),
                  isDark: isDark,
                ),
                SizedBox(height: AppSizes.lg),

                // Commission type
                _buildChipSelector(
                  label: AppStrings.commissionTypeLabel,
                  options: _commissionTypes,
                  selected: _commissionType,
                  onSelected: (i) => setState(() => _commissionType = i),
                  isDark: isDark,
                ),
                SizedBox(height: AppSizes.lg),

                // Commission value
                SekkaInputField(
                  controller: _commissionValueController,
                  label: AppStrings.commissionValue,
                  hint: '0',
                  prefixIcon: IconsaxPlusLinear.percentage_circle,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: AppSizes.lg),

                // Payment method
                _buildChipSelector(
                  label: AppStrings.defaultPaymentMethod,
                  options: _paymentMethods,
                  selected: _paymentMethod,
                  onSelected: (i) => setState(() => _paymentMethod = i),
                  isDark: isDark,
                ),
                SizedBox(height: AppSizes.lg),

                // Receipt header
                SekkaInputField(
                  controller: _receiptHeaderController,
                  label: AppStrings.receiptHeader,
                  hint: AppStrings.receiptHeader,
                  prefixIcon: IconsaxPlusLinear.receipt,
                ),
                SizedBox(height: AppSizes.xxl),

                // Submit
                SekkaButton(
                  label: AppStrings.addPartner,
                  onPressed: _isValid ? _submit : null,
                  isLoading: _isLoading,
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSelector({
    required String label,
    required List<String> options,
    required int selected,
    required ValueChanged<int> onSelected,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          children: List.generate(options.length, (index) {
            final isActive = selected == index;
            return GestureDetector(
              onTap: () => onSelected(index),
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
                          ? AppColors.surfaceDark
                          : AppColors.background,
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
                  options[index],
                  style: AppTypography.bodySmall.copyWith(
                    color: isActive
                        ? AppColors.textOnPrimary
                        : isDark
                            ? AppColors.textBodyDark
                            : AppColors.textBody,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

}
