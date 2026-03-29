import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../shared/enums/order_enums.dart';
import '../../data/models/order_model.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key, this.order});

  /// If provided, the screen operates in EDIT mode.
  final OrderModel? order;

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController? _tabController;
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _itemCountController = TextEditingController(text: '1');
  final _expectedChangeController = TextEditingController();
  final _notesController = TextEditingController();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  OrderPriority _selectedPriority = OrderPriority.normal;
  DateTime? _scheduledDate;

  bool get _isEditMode => widget.order != null;

  // Bulk import controllers
  final _bulkTextController = TextEditingController();
  String _bulkDelimiter = '\t';
  PaymentMethod _bulkPaymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _tabController = _isEditMode ? null : TabController(length: 2, vsync: this);
    if (_isEditMode) {
      _prefillFromOrder(widget.order!);
    }
  }

  void _prefillFromOrder(OrderModel order) {
    _customerNameController.text = order.customerName ?? '';
    _customerPhoneController.text = order.customerPhone ?? '';
    _deliveryAddressController.text = order.deliveryAddress;
    _pickupAddressController.text = order.pickupAddress ?? '';
    _amountController.text = order.amount.toStringAsFixed(
      order.amount.truncateToDouble() == order.amount ? 0 : 2,
    );
    _descriptionController.text = order.description ?? '';
    _itemCountController.text = (order.itemCount ?? 1).toString();
    _notesController.text = order.notes ?? '';
    _selectedPaymentMethod = order.paymentMethod;
    _selectedPriority = order.priority;

    if (order.scheduledDate != null) {
      _scheduledDate = DateTime.tryParse(order.scheduledDate!);
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _deliveryAddressController.dispose();
    _pickupAddressController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _itemCountController.dispose();
    _expectedChangeController.dispose();
    _notesController.dispose();
    _bulkTextController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  bool _validate() {
    final deliveryAddress = _deliveryAddressController.text.trim();
    if (deliveryAddress.isEmpty) {
      SekkaMessageDialog.show(
        context,
        message: AppStrings.deliveryAddressRequired,
        type: SekkaMessageType.error,
      );
      return false;
    }

    final amountText = _amountController.text.trim().toEnglishNumbers;
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      SekkaMessageDialog.show(
        context,
        message: AppStrings.amountInvalid,
        type: SekkaMessageType.error,
      );
      return false;
    }

    return true;
  }

  Map<String, dynamic> _buildData() {
    final phoneText = _customerPhoneController.text.trim().toEnglishNumbers;
    final amountText = _amountController.text.trim().toEnglishNumbers;
    final itemCountText = _itemCountController.text.trim().toEnglishNumbers;

    final data = <String, dynamic>{
      'deliveryAddress': _deliveryAddressController.text.trim(),
      'amount': double.parse(amountText),
      'paymentMethod': _selectedPaymentMethod.value,
      'priority': _selectedPriority.value,
    };

    final customerName = _customerNameController.text.trim();
    if (customerName.isNotEmpty) {
      data['customerName'] = customerName;
    }

    if (phoneText.isNotEmpty) {
      data['customerPhone'] = phoneText;
    }

    final pickupAddress = _pickupAddressController.text.trim();
    if (pickupAddress.isNotEmpty) {
      data['pickupAddress'] = pickupAddress;
    }

    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) {
      data['description'] = description;
    }

    final itemCount = int.tryParse(itemCountText);
    if (itemCount != null && itemCount > 0) {
      data['itemCount'] = itemCount;
    }

    final expectedChange = _expectedChangeController.text.trim().toEnglishNumbers;
    final changeAmount = double.tryParse(expectedChange);
    if (changeAmount != null && changeAmount > 0) {
      data['expectedChangeAmount'] = changeAmount;
    }

    final notes = _notesController.text.trim();
    if (notes.isNotEmpty) {
      data['notes'] = notes;
    }

    if (_scheduledDate != null) {
      data['scheduledDate'] =
          '${_scheduledDate!.year}-${_scheduledDate!.month.toString().padLeft(2, '0')}-${_scheduledDate!.day.toString().padLeft(2, '0')}';
    }

    return data;
  }

  void _submit() {
    if (!_validate()) return;

    final data = _buildData();

    if (_isEditMode) {
      context.read<OrdersBloc>().add(
            OrderUpdateRequested(
              orderId: widget.order!.id,
              data: data,
            ),
          );
    } else {
      context.read<OrdersBloc>().add(OrderCreateRequested(data: data));
    }
  }

  void _proceedWithCreate() {
    final data = _buildData();
    context.read<OrdersBloc>().add(OrderCreateRequested(data: data));
  }

  Future<void> _showDuplicateWarning() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor:
                isDark ? AppColors.surfaceDark : AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding * 2,
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning icon
                  Container(
                    width: AppSizes.avatarLg,
                    height: AppSizes.avatarLg,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.warning.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: AppColors.warning,
                      size: AppSizes.iconXl,
                    ),
                  ),
                  SizedBox(height: AppSizes.lg),

                  // Message
                  Text(
                    AppStrings.duplicateWarning,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textBodyDark
                          : AppColors.textBody,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.xxl),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SekkaButton(
                          label: AppStrings.cancel,
                          type: SekkaButtonType.secondary,
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                        ),
                      ),
                      SizedBox(width: AppSizes.md),
                      Expanded(
                        child: SekkaButton(
                          label: AppStrings.yesContinue,
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (shouldContinue == true && mounted) {
      _proceedWithCreate();
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: AppColors.textOnPrimary,
                ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrdersLoaded && state.actionMessage != null) {
            final msg = state.actionMessage!;
            final isSuccess = msg == AppStrings.orderCreatedSuccess ||
                msg == AppStrings.orderUpdatedSuccess;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  msg,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                backgroundColor:
                    isSuccess ? AppColors.success : AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            );

            if (isSuccess) {
              Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          final isLoading =
              state is OrdersLoaded && state.isActionInProgress;

          return Scaffold(
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const SekkaBackButton(),
              centerTitle: true,
              title: Text(
                _isEditMode ? AppStrings.editOrder : AppStrings.addOrder,
                style: AppTypography.headlineSmall,
              ),
            ),
            body: _isEditMode
                ? _buildFormList(state, isLoading, isDark)
                : Column(
                    children: [
                      // Styled tab bar like contacts screen
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.pagePadding,
                        ),
                        child: Container(
                          height: Responsive.h(44),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.border.withValues(alpha: 0.3),
                            borderRadius:
                                BorderRadius.circular(Responsive.r(12)),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(Responsive.r(10)),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: AppColors.textOnPrimary,
                            unselectedLabelColor: isDark
                                ? AppColors.textCaptionDark
                                : AppColors.textCaption,
                            labelStyle: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            unselectedLabelStyle: AppTypography.titleMedium,
                            labelPadding: EdgeInsets.zero,
                            padding: EdgeInsets.all(Responsive.w(3)),
                            tabs: [
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      IconsaxPlusBold.edit_2,
                                      size: Responsive.r(18),
                                    ),
                                    SizedBox(width: Responsive.w(6)),
                                    const Text('إضافة يدوي'),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      IconsaxPlusBold.document_download,
                                      size: Responsive.r(18),
                                    ),
                                    SizedBox(width: Responsive.w(6)),
                                    const Text('استيراد'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppSizes.md),

                      // Tab content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildFormList(state, isLoading, isDark),
                            _buildBulkImportTab(isLoading, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFormList(OrdersState state, bool isLoading, bool isDark) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.lg,
      ),
      children: [
                // Customer Name
                SekkaInputField(
                  controller: _customerNameController,
                  hint: AppStrings.clientName,
                  prefixIcon: IconsaxPlusLinear.user,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSizes.lg),

                // Customer Phone
                SekkaInputField(
                  controller: _customerPhoneController,
                  hint: AppStrings.phone,
                  prefixIcon: IconsaxPlusLinear.call,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSizes.lg),

                // Delivery Address (Required)
                SekkaInputField(
                  controller: _deliveryAddressController,
                  hint: AppStrings.deliveryAddress,
                  prefixIcon: IconsaxPlusLinear.location,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSizes.lg),

                // Pickup Address
                SekkaInputField(
                  controller: _pickupAddressController,
                  hint: AppStrings.pickupAddress,
                  prefixIcon: IconsaxPlusLinear.location,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSizes.lg),

                // Description
                SekkaInputField(
                  controller: _descriptionController,
                  hint: 'وصف الشحنة',
                  prefixIcon: IconsaxPlusLinear.note_1,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSizes.lg),

                // Amount (Required)
                SekkaInputField(
                  controller: _amountController,
                  hint: AppStrings.amount,
                  prefixIcon: IconsaxPlusLinear.money_recive,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSizes.lg),

                // Expected Change Amount
                SekkaInputField(
                  controller: _expectedChangeController,
                  hint: 'مبلغ الفكة',
                  prefixIcon: IconsaxPlusLinear.money_send,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSizes.lg),

                // Payment Method
                _buildSectionLabel(AppStrings.paymentMethodLabel),
                SizedBox(height: AppSizes.sm),
                _ChipSelector<PaymentMethod>(
                  items: PaymentMethod.values,
                  selectedValue: _selectedPaymentMethod,
                  labelBuilder: (item) => item.arabic,
                  onChanged: (value) =>
                      setState(() => _selectedPaymentMethod = value),
                ),
                SizedBox(height: AppSizes.lg),

                // Priority
                _buildSectionLabel(AppStrings.priorityLabel),
                SizedBox(height: AppSizes.sm),
                _ChipSelector<OrderPriority>(
                  items: OrderPriority.values,
                  selectedValue: _selectedPriority,
                  labelBuilder: (item) => item.arabic,
                  onChanged: (value) =>
                      setState(() => _selectedPriority = value),
                ),
                SizedBox(height: AppSizes.lg),

                // Item Count
                SekkaInputField(
                  controller: _itemCountController,
                  hint: AppStrings.itemCount,
                  prefixIcon: IconsaxPlusLinear.box_1,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppSizes.lg),

                // Notes
                SekkaInputField(
                  controller: _notesController,
                  hint: AppStrings.note,
                  prefixIcon: IconsaxPlusLinear.note_text,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                SizedBox(height: AppSizes.lg),

                // Scheduled Date
                _buildSectionLabel(AppStrings.scheduledDate),
                SizedBox(height: AppSizes.sm),
                _buildDatePicker(isDark),
                SizedBox(height: AppSizes.lg),

                // Time Slots
                if (!_isEditMode) ...[
                  _buildTimeSlots(state, isDark),
                  SizedBox(height: AppSizes.lg),
                ],

                // Price Calculation
                if (!_isEditMode) ...[
                  _buildPriceSection(state, isDark),
                  SizedBox(height: AppSizes.xxl),
                ],

                // Submit Button
                SekkaButton(
                  label: _isEditMode
                      ? AppStrings.saveChanges
                      : AppStrings.confirmAdd,
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                  icon: _isEditMode
                      ? IconsaxPlusLinear.edit_2
                      : IconsaxPlusLinear.add_circle,
                ),
                SizedBox(height: AppSizes.xxl),
              ],
            );
  }

  Widget _buildBulkImportTab(bool isLoading, bool isDark) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.lg,
      ),
      children: [
        Text(
          AppStrings.bulkImportHint,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
        ),
        SizedBox(height: AppSizes.lg),

        // rawText
        SekkaInputField(
          controller: _bulkTextController,
          hint: AppStrings.pasteOrdersHere,
          prefixIcon: IconsaxPlusLinear.clipboard_text,
          maxLines: 8,
        ),
        SizedBox(height: AppSizes.lg),

        // defaultPaymentMethod
        _buildSectionLabel(AppStrings.paymentMethodLabel),
        SizedBox(height: AppSizes.sm),
        _ChipSelector<PaymentMethod>(
          items: PaymentMethod.values,
          selectedValue: _bulkPaymentMethod,
          labelBuilder: (item) => item.arabic,
          onChanged: (value) => setState(() => _bulkPaymentMethod = value),
        ),
        SizedBox(height: AppSizes.xxl),

        SekkaButton(
          label: AppStrings.importOrders,
          isLoading: isLoading,
          onPressed: isLoading
              ? null
              : () {
                  final text = _bulkTextController.text.trim();
                  if (text.isEmpty) return;
                  context.read<OrdersBloc>().add(
                        OrderBulkImportRequested(
                          text: text,
                          defaultPaymentMethod: _bulkPaymentMethod.value,
                        ),
                      );
                },
        ),
        SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: AppTypography.titleMedium);
  }

  Widget _buildDatePicker(bool isDark) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final iconColor = isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        height: AppSizes.inputHeight,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              IconsaxPlusLinear.calendar_1,
              size: AppSizes.iconLg,
              color: iconColor,
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                _scheduledDate != null
                    ? _formatDate(_scheduledDate!)
                    : AppStrings.notScheduled,
                style: _scheduledDate != null
                    ? AppTypography.bodyLarge
                    : AppTypography.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textCaptionDark
                            : AppColors.textCaption,
                      ),
              ),
            ),
            if (_scheduledDate != null)
              GestureDetector(
                onTap: () => setState(() => _scheduledDate = null),
                child: Icon(
                  IconsaxPlusLinear.close_circle,
                  size: AppSizes.iconMd,
                  color: iconColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots(OrdersState state, bool isDark) {
    final slots = state is OrdersLoaded ? state.timeSlots : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Text('المواعيد المتاحة', style: AppTypography.titleMedium),
            const Spacer(),
            GestureDetector(
              onTap: () => context
                  .read<OrdersBloc>()
                  .add(const OrderTimeSlotsLoadRequested()),
              child: Text(
                'حمّل المواعيد',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        if (slots.isEmpty)
          Text(
            'اضغط "حمّل المواعيد" عشان تشوف المتاح',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
          )
        else
          SizedBox(
            height: Responsive.h(40),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: slots.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSizes.sm),
              itemBuilder: (_, index) {
                final slot = slots[index] as Map<String, dynamic>;
                final label = slot['label'] as String? ??
                    slot['time'] as String? ??
                    'موعد ${index + 1}';
                return Chip(
                  label: Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection(OrdersState state, bool isDark) {
    final priceData = state is OrdersLoaded ? state.priceCalculation : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Text('سعر التوصيل المقترح', style: AppTypography.titleMedium),
            const Spacer(),
            GestureDetector(
              onTap: () {
                final deliveryAddr = _deliveryAddressController.text.trim();
                if (deliveryAddr.isEmpty) return;
                context.read<OrdersBloc>().add(
                      OrderCalculatePriceRequested(data: {
                        'deliveryAddress': deliveryAddr,
                        'pickupAddress': _pickupAddressController.text.trim(),
                        'itemCount': int.tryParse(
                                _itemCountController.text.trim()) ??
                            1,
                        'priority': _selectedPriority.value,
                      }),
                    );
              },
              child: Text(
                'احسب السعر',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.sm),
        if (priceData != null)
          SekkaCard(
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السعر المقترح',
                  style: AppTypography.bodyMedium,
                ),
                Text(
                  '${priceData['suggestedPrice'] ?? '—'} ج.م',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            'اكتب العنوان واضغط "احسب السعر"',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
            ),
          ),
      ],
    );
  }
}

class _ChipSelector<T> extends StatelessWidget {
  const _ChipSelector({
    required this.items,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onChanged,
  });

  final List<T> items;
  final T selectedValue;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: items.map((item) {
        final isSelected = item == selectedValue;

        return GestureDetector(
          onTap: () => onChanged(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(16),
              vertical: Responsive.h(10),
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : surfaceColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(
                color: isSelected ? AppColors.primary : borderColor,
                width: 1.5,
              ),
            ),
            child: Text(
              labelBuilder(item),
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected
                    ? AppColors.textOnPrimary
                    : isDark
                        ? AppColors.textBodyDark
                        : AppColors.textBody,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
