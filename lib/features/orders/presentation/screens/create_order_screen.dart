import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../core/widgets/sekka_map_picker.dart';
import '../../../../core/widgets/sekka_stepper.dart';
import '../../../../shared/enums/order_enums.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../partners/data/models/partner_model.dart';
import '../../../partners/data/models/pickup_point_model.dart';
import '../../../partners/data/repositories/partner_repository.dart';
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
  // ── Tab (manual / bulk) ──
  late final TabController? _tabController;

  // ── Step navigation ──
  int _currentStep = 0;
  static const _totalSteps = 3;

  // ── Order Type ──
  OrderType _orderType = OrderType.normal;

  // ── Step 1: Customer info ──
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  String? _selectedPartnerId;

  // ── Partners & Pickup Points ──
  late final PartnerRepository _partnerRepo;
  List<PartnerModel> _partners = [];
  List<PickupPointModel> _pickupPoints = [];
  PickupPointModel? _selectedPickupPoint;
  bool _isLoadingPartners = true;
  bool _isLoadingPickupPoints = false;

  // ── Step 2: Addresses ──
  final _pickupAddressController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  double? _pickupLat;
  double? _pickupLng;
  double? _deliveryLat;
  double? _deliveryLng;

  // ── Step 3: Order details ──
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _itemCountController = TextEditingController(text: '1');
  final _expectedChangeController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  OrderPriority _selectedPriority = OrderPriority.normal;
  DateTime? _scheduledDate;
  TimeOfDay? _timeWindowStart;
  TimeOfDay? _timeWindowEnd;
  bool _isRecurring = false;
  String _recurrencePattern = 'Daily';
  DateTime? _recurrenceStartDate;
  DateTime? _recurrenceEndDate;
  late final String _idempotencyKey;

  bool get _isEditMode => widget.order != null;

  // ── Bulk import ──
  final _bulkTextController = TextEditingController();
  PaymentMethod _bulkPaymentMethod = PaymentMethod.cash;

  // ── Steps definition ──
  static const _steps = [
    SekkaStepperItem(label: AppStrings.stepCustomerInfo, icon: IconsaxPlusLinear.user),
    SekkaStepperItem(label: AppStrings.stepAddresses, icon: IconsaxPlusLinear.location),
    SekkaStepperItem(label: AppStrings.stepDetails, icon: IconsaxPlusLinear.document_text),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = _isEditMode ? null : TabController(length: 2, vsync: this);
    _idempotencyKey = const Uuid().v4();
    _partnerRepo = PartnerRepository(context.read<DioClient>().dio);

    if (_isEditMode) {
      _prefillFromOrder(widget.order!);
    }

    _loadPartners();
  }

  Future<void> _loadPartners() async {
    final result = await _partnerRepo.getPartners(pageSize: 100);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _partners = data;
          _isLoadingPartners = false;
        });
      case ApiFailure():
        setState(() => _isLoadingPartners = false);
    }
  }

  Future<void> _loadPickupPoints(String partnerId) async {
    setState(() {
      _isLoadingPickupPoints = true;
      _pickupPoints = [];
      _selectedPickupPoint = null;
    });

    final result = await _partnerRepo.getPickupPoints(partnerId);
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _pickupPoints = data;
          _isLoadingPickupPoints = false;
          // لو فيه نقطة واحدة بس، اختارها تلقائي
          if (data.length == 1) {
            _selectPickupPoint(data.first);
          }
        });
      case ApiFailure():
        setState(() => _isLoadingPickupPoints = false);
    }
  }

  void _selectPickupPoint(PickupPointModel point) {
    setState(() {
      _selectedPickupPoint = point;
      _pickupAddressController.text = point.address;
      _pickupLat = point.latitude;
      _pickupLng = point.longitude;
    });
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

  // ── Validation per step ──

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        // Step 1: customer info — optional fields, no strict validation
        return true;
      case 1:
        // Step 2: delivery address required
        if (_deliveryAddressController.text.trim().isEmpty) {
          SekkaMessageDialog.show(
            context,
            message: AppStrings.deliveryAddressRequired,
            type: SekkaMessageType.error,
          );
          return false;
        }
        return true;
      case 2:
        // Step 3: amount required
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
        // Recurring: start date required
        if (_isRecurring && _recurrenceStartDate == null) {
          SekkaMessageDialog.show(
            context,
            message: AppStrings.recurrenceStartDateRequired,
            type: SekkaMessageType.error,
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (!_validateStep(_currentStep)) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // ── GPS ──

  // ── Time picker ──

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _timeWindowStart : _timeWindowEnd) ??
          TimeOfDay.now(),
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
      setState(() {
        if (isStart) {
          _timeWindowStart = picked;
        } else {
          _timeWindowEnd = picked;
        }
      });
    }
  }

  // ── Date picker ──

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

  String _formatTime(TimeOfDay time) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$h:$m $period';
  }

  // ── Build data map ──

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
    if (customerName.isNotEmpty) data['customerName'] = customerName;

    if (phoneText.isNotEmpty) data['customerPhone'] = phoneText;

    if (_selectedPartnerId != null) data['partnerId'] = _selectedPartnerId;

    final pickupAddress = _pickupAddressController.text.trim();
    if (pickupAddress.isNotEmpty) data['pickupAddress'] = pickupAddress;

    if (_pickupLat != null) data['pickupLatitude'] = _pickupLat;
    if (_pickupLng != null) data['pickupLongitude'] = _pickupLng;

    if (_deliveryLat != null) data['deliveryLatitude'] = _deliveryLat;
    if (_deliveryLng != null) data['deliveryLongitude'] = _deliveryLng;

    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) data['description'] = description;

    final itemCount = int.tryParse(itemCountText);
    if (itemCount != null && itemCount > 0) data['itemCount'] = itemCount;

    final expectedChange =
        _expectedChangeController.text.trim().toEnglishNumbers;
    final changeAmount = double.tryParse(expectedChange);
    if (changeAmount != null && changeAmount > 0) {
      data['expectedChangeAmount'] = changeAmount;
    }

    final notes = _notesController.text.trim();
    if (notes.isNotEmpty) data['notes'] = notes;

    if (_scheduledDate != null) {
      data['scheduledDate'] =
          '${_scheduledDate!.year}-${_scheduledDate!.month.toString().padLeft(2, '0')}-${_scheduledDate!.day.toString().padLeft(2, '0')}';
    }

    if (_timeWindowStart != null && _scheduledDate != null) {
      final dt = _scheduledDate ?? DateTime.now();
      data['timeWindowStart'] = DateTime(
        dt.year,
        dt.month,
        dt.day,
        _timeWindowStart!.hour,
        _timeWindowStart!.minute,
      ).toUtc().toIso8601String();
    }

    if (_timeWindowEnd != null && _scheduledDate != null) {
      final dt = _scheduledDate ?? DateTime.now();
      data['timeWindowEnd'] = DateTime(
        dt.year,
        dt.month,
        dt.day,
        _timeWindowEnd!.hour,
        _timeWindowEnd!.minute,
      ).toUtc().toIso8601String();
    }

    data['isRecurring'] = _isRecurring;
    if (_isRecurring) {
      data['recurrencePattern'] = _recurrencePattern;
      if (_recurrenceStartDate != null) {
        data['startDate'] =
            '${_recurrenceStartDate!.year}-${_recurrenceStartDate!.month.toString().padLeft(2, '0')}-${_recurrenceStartDate!.day.toString().padLeft(2, '0')}';
      }
      if (_recurrenceEndDate != null) {
        data['endDate'] =
            '${_recurrenceEndDate!.year}-${_recurrenceEndDate!.month.toString().padLeft(2, '0')}-${_recurrenceEndDate!.day.toString().padLeft(2, '0')}';
      }
    }

    if (!_isEditMode) data['idempotencyKey'] = _idempotencyKey;

    return data;
  }

  // ── Submit ──

  void _submit() {
    if (!_validateStep(2)) return;

    final data = _buildData();

    if (_isEditMode) {
      context.read<OrdersBloc>().add(
            OrderUpdateRequested(
              orderId: widget.order!.id,
              data: data,
            ),
          );
    } else if (_isRecurring) {
      context.read<OrdersBloc>().add(RecurringOrderCreateRequested(data: data));
    } else {
      context.read<OrdersBloc>().add(OrderCreateRequested(data: data));
    }
  }

  // ──────────────────────────── BUILD ────────────────────────────

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

            if (isSuccess) Navigator.of(context).pop();
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
                ? _buildSteppedForm(state, isLoading, isDark)
                : Column(
                    children: [
                      // Tab bar: manual / bulk
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
                                    const Text(AppStrings.manualEntry),
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
                                    const Text(AppStrings.bulkImport),
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
                            _buildSteppedForm(state, isLoading, isDark),
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

  // ───────────────── STEPPED FORM ─────────────────

  Widget _buildSteppedForm(
    OrdersState state,
    bool isLoading,
    bool isDark,
  ) {
    return Column(
      children: [
        // Stepper indicator
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.pagePadding * 2,
            vertical: AppSizes.md,
          ),
          child: SekkaStepper(
            steps: _steps,
            currentStep: _currentStep,
          ),
        ),

        // Step content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: ListView(
              key: ValueKey(_currentStep),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
                vertical: AppSizes.sm,
              ),
              children: switch (_currentStep) {
                0 => _buildStep1CustomerInfo(isDark),
                1 => _buildStep2Addresses(isDark),
                2 => _buildStep3Details(state, isLoading, isDark),
                _ => [],
              },
            ),
          ),
        ),

        // Navigation buttons
        _buildStepButtons(isLoading, isDark),
      ],
    );
  }

  Widget _buildStepButtons(bool isLoading, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.md,
        AppSizes.pagePadding,
        AppSizes.xxl,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentStep > 0)
            Expanded(
              child: SekkaButton(
                label: AppStrings.previousStep,
                type: SekkaButtonType.secondary,
                icon: IconsaxPlusLinear.arrow_right_1,
                onPressed: _previousStep,
              ),
            ),
          if (_currentStep > 0) SizedBox(width: AppSizes.md),

          // Next or Submit
          Expanded(
            child: _currentStep < _totalSteps - 1
                ? SekkaButton(
                    label: AppStrings.nextStep,
                    icon: IconsaxPlusLinear.arrow_left_1,
                    onPressed: _nextStep,
                  )
                : SekkaButton(
                    label: _isEditMode
                        ? AppStrings.saveChanges
                        : AppStrings.confirmAdd,
                    icon: _isEditMode
                        ? IconsaxPlusLinear.edit_2
                        : IconsaxPlusLinear.add_circle,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
          ),
        ],
      ),
    );
  }

  // ───────────────── STEP 1: CUSTOMER INFO ─────────────────

  List<Widget> _buildStep1CustomerInfo(bool isDark) {
    return [
      // Order Type Selector
      if (!_isEditMode) ...[
        _buildSectionLabel(AppStrings.orderTypeLabel),
        SizedBox(height: AppSizes.sm),
        _ChipSelector<OrderType>(
          items: OrderType.values,
          selectedValue: _orderType,
          labelBuilder: (item) => switch (item) {
            OrderType.normal => AppStrings.orderTypeNormal,
            OrderType.recurring => AppStrings.orderTypeRecurring,
          },
          onChanged: (value) {
            setState(() {
              _orderType = value;
              _isRecurring = value == OrderType.recurring;
            });
          },
        ),
        SizedBox(height: AppSizes.lg),
      ],

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

      // Partner selection
      _buildSectionLabel(AppStrings.selectPartner),
      SizedBox(height: AppSizes.sm),
      _buildPartnerSelector(isDark),
      SizedBox(height: AppSizes.lg),
    ];
  }

  Widget _buildPartnerSelector(bool isDark) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    if (_isLoadingPartners) {
      return Container(
        height: AppSizes.inputHeight,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Center(
          child: SizedBox(
            width: AppSizes.iconMd,
            height: AppSizes.iconMd,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      height: AppSizes.inputHeight,
      padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedPartnerId,
          isExpanded: true,
          icon: Icon(
            IconsaxPlusLinear.arrow_down_1,
            size: AppSizes.iconMd,
            color: captionColor,
          ),
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
          hint: Text(
            AppStrings.noPartner,
            style: AppTypography.bodyLarge.copyWith(color: captionColor),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text(AppStrings.noPartner),
            ),
            ..._partners.map((p) {
              return DropdownMenuItem<String?>(
                value: p.id,
                child: Row(
                  children: [
                    // لون الشريك
                    Container(
                      width: Responsive.r(12),
                      height: Responsive.r(12),
                      decoration: BoxDecoration(
                        color: _parseColor(p.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        p.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPartnerId = value;
              _pickupPoints = [];
              _selectedPickupPoint = null;
            });
            if (value != null) {
              _loadPickupPoints(value);
            } else {
              // مسح بيانات الاستلام لو شال الشريك
              setState(() {
                _pickupAddressController.clear();
                _pickupLat = null;
                _pickupLng = null;
              });
            }
          },
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 7) buffer.write('FF');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  // ───────────────── STEP 2: ADDRESSES ─────────────────

  List<Widget> _buildStep2Addresses(bool isDark) {
    return [
      // ── Pickup Points (لو فيه شريك متاختار) ──
      if (_selectedPartnerId != null) ...[
        _buildPickupPointsSelector(isDark),
        SizedBox(height: AppSizes.lg),
      ],

      // ── Pickup ──
      _buildSectionLabel(AppStrings.pickupAddress),
      SizedBox(height: AppSizes.sm),
      _buildAddressField(
        controller: _pickupAddressController,
        hint: AppStrings.pickupAddress,
        isPickup: true,
        hasCoords: _pickupLat != null && _pickupLng != null,
        isDark: isDark,
      ),
      SizedBox(height: AppSizes.xxl),

      // ── Delivery ──
      _buildSectionLabel(AppStrings.deliveryAddress),
      SizedBox(height: AppSizes.sm),
      _buildAddressField(
        controller: _deliveryAddressController,
        hint: AppStrings.deliveryAddress,
        isPickup: false,
        hasCoords: _deliveryLat != null && _deliveryLng != null,
        isDark: isDark,
      ),
      SizedBox(height: AppSizes.lg),
    ];
  }

  Widget _buildPickupPointsSelector(bool isDark) {
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    if (_isLoadingPickupPoints) {
      return SekkaCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: AppSizes.iconMd,
              height: AppSizes.iconMd,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppSizes.md),
            Text(
              AppStrings.loadingPickupPoints,
              style: AppTypography.bodyMedium.copyWith(color: captionColor),
            ),
          ],
        ),
      );
    }

    if (_pickupPoints.isEmpty) {
      return SekkaCard(
        child: Row(
          children: [
            Icon(
              IconsaxPlusLinear.info_circle,
              size: AppSizes.iconMd,
              color: captionColor,
            ),
            SizedBox(width: AppSizes.sm),
            Text(
              AppStrings.noPickupPoints,
              style: AppTypography.bodySmall.copyWith(color: captionColor),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(AppStrings.selectPickupPoint),
        SizedBox(height: AppSizes.sm),
        SizedBox(
          height: Responsive.h(90),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: _pickupPoints.length,
            separatorBuilder: (_, __) => SizedBox(width: AppSizes.sm),
            itemBuilder: (_, index) {
              final point = _pickupPoints[index];
              final isSelected = _selectedPickupPoint?.id == point.id;

              return GestureDetector(
                onTap: () => _selectPickupPoint(point),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: Responsive.w(200),
                  padding: EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            IconsaxPlusBold.location,
                            size: AppSizes.iconSm,
                            color: isSelected
                                ? AppColors.primary
                                : captionColor,
                          ),
                          SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(
                              point.name,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              size: AppSizes.iconSm,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                      SizedBox(height: AppSizes.xs),
                      Text(
                        point.address,
                        style: AppTypography.captionSmall.copyWith(
                          color: captionColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField({
    required TextEditingController controller,
    required String hint,
    required bool isPickup,
    required bool hasCoords,
    required bool isDark,
  }) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    return GestureDetector(
      onTap: () => _openMapPicker(isPickup: isPickup),
      child: Container(
        constraints: BoxConstraints(minHeight: AppSizes.inputHeight),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          border: Border.all(
            color: hasCoords ? AppColors.success : borderColor,
            width: hasCoords ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              IconsaxPlusLinear.location,
              size: AppSizes.iconLg,
              color: hasCoords ? AppColors.success : captionColor,
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                controller.text.isNotEmpty ? controller.text : hint,
                style: controller.text.isNotEmpty
                    ? AppTypography.bodyMedium
                    : AppTypography.bodyMedium.copyWith(color: captionColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppSizes.sm),
            if (hasCoords)
              Icon(
                Icons.check_circle,
                size: AppSizes.iconMd,
                color: AppColors.success,
              )
            else
              Icon(
                IconsaxPlusLinear.map,
                size: AppSizes.iconMd,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMapPicker({required bool isPickup}) async {
    final currentLat = isPickup ? _pickupLat : _deliveryLat;
    final currentLng = isPickup ? _pickupLng : _deliveryLng;

    final result = await SekkaMapPicker.show(
      context,
      initialLatitude: currentLat,
      initialLongitude: currentLng,
      title: isPickup ? AppStrings.pickupAddress : AppStrings.deliveryAddress,
    );

    if (result == null || !mounted) return;

    final addressText = result.address ??
        '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';

    setState(() {
      if (isPickup) {
        _pickupLat = result.latitude;
        _pickupLng = result.longitude;
        _pickupAddressController.text = addressText;
      } else {
        _deliveryLat = result.latitude;
        _deliveryLng = result.longitude;
        _deliveryAddressController.text = addressText;
      }
    });
  }

  // ───────────────── STEP 3: DETAILS ─────────────────

  List<Widget> _buildStep3Details(
    OrdersState state,
    bool isLoading,
    bool isDark,
  ) {
    return [
      // Description
      SekkaInputField(
        controller: _descriptionController,
        hint: AppStrings.shipmentDescription,
        prefixIcon: IconsaxPlusLinear.note_1,
        textInputAction: TextInputAction.next,
      ),
      SizedBox(height: AppSizes.lg),

      // Amount (Required)
      SekkaInputField(
        controller: _amountController,
        hint: AppStrings.amount,
        prefixIcon: IconsaxPlusLinear.money_recive,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
      ),
      SizedBox(height: AppSizes.lg),

      // Expected Change
      SekkaInputField(
        controller: _expectedChangeController,
        hint: AppStrings.expectedChange,
        prefixIcon: IconsaxPlusLinear.money_send,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

      // Time Window
      if (_scheduledDate != null) ...[
        _buildSectionLabel(AppStrings.timeWindowLabel),
        SizedBox(height: AppSizes.sm),
        _buildTimeWindowRow(isDark),
        SizedBox(height: AppSizes.lg),
      ],

      // Recurring fields (shown only when order type is recurring)
      if (_isRecurring) ...[
        _buildSectionLabel(AppStrings.recurrencePatternLabel),
        SizedBox(height: AppSizes.sm),
        _ChipSelector<String>(
          items: const ['Daily', 'Weekly', 'Monthly'],
          selectedValue: _recurrencePattern,
          labelBuilder: _recurrencePatternArabic,
          onChanged: (value) =>
              setState(() => _recurrencePattern = value),
        ),
        SizedBox(height: AppSizes.lg),

        // Start Date
        _buildSectionLabel(AppStrings.recurrenceStartDate),
        SizedBox(height: AppSizes.sm),
        _buildRecurrenceDatePicker(
          value: _recurrenceStartDate,
          isDark: isDark,
          onPick: () => _pickRecurrenceDate(isStart: true),
          onClear: () => setState(() => _recurrenceStartDate = null),
        ),
        SizedBox(height: AppSizes.lg),

        // End Date
        _buildSectionLabel(AppStrings.recurrenceEndDate),
        SizedBox(height: AppSizes.sm),
        _buildRecurrenceDatePicker(
          value: _recurrenceEndDate,
          isDark: isDark,
          onPick: () => _pickRecurrenceDate(isStart: false),
          onClear: () => setState(() => _recurrenceEndDate = null),
        ),
        SizedBox(height: AppSizes.lg),
      ],

      // Time Slots
      if (!_isEditMode) ...[
        _buildTimeSlots(state, isDark),
        SizedBox(height: AppSizes.lg),
      ],

      // Price Calculation
      if (!_isEditMode) ...[
        _buildPriceSection(state, isDark),
        SizedBox(height: AppSizes.lg),
      ],
    ];
  }

  String _recurrencePatternArabic(String pattern) {
    return switch (pattern) {
      'Daily' => AppStrings.recurrenceDaily,
      'Weekly' => AppStrings.recurrenceWeekly,
      'Monthly' => AppStrings.recurrenceMonthly,
      _ => pattern,
    };
  }

  Future<void> _pickRecurrenceDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _recurrenceStartDate : _recurrenceEndDate) ?? now,
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
      setState(() {
        if (isStart) {
          _recurrenceStartDate = picked;
        } else {
          _recurrenceEndDate = picked;
        }
      });
    }
  }

  Widget _buildRecurrenceDatePicker({
    required DateTime? value,
    required bool isDark,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final iconColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    return GestureDetector(
      onTap: onPick,
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
                value != null
                    ? _formatDate(value)
                    : AppStrings.notScheduled,
                style: value != null
                    ? AppTypography.bodyLarge
                    : AppTypography.bodyLarge.copyWith(color: iconColor),
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: onClear,
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

  Widget _buildTimeWindowRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildTimePicker(
            label: AppStrings.timeWindowFrom,
            value: _timeWindowStart,
            isDark: isDark,
            onTap: () => _pickTime(isStart: true),
          ),
        ),
        SizedBox(width: AppSizes.md),
        Expanded(
          child: _buildTimePicker(
            label: AppStrings.timeWindowTo,
            value: _timeWindowEnd,
            isDark: isDark,
            onTap: () => _pickTime(isStart: false),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final iconColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.inputHeight,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              IconsaxPlusLinear.clock,
              size: AppSizes.iconMd,
              color: iconColor,
            ),
            SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                value != null ? _formatTime(value) : label,
                style: value != null
                    ? AppTypography.bodyMedium
                    : AppTypography.bodyMedium.copyWith(color: iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── SHARED BUILDERS ─────────────────

  Widget _buildSectionLabel(String label) {
    return Text(label, style: AppTypography.titleMedium);
  }

  Widget _buildDatePicker(bool isDark) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final iconColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

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
                    : AppTypography.bodyLarge.copyWith(color: iconColor),
              ),
            ),
            if (_scheduledDate != null)
              GestureDetector(
                onTap: () => setState(() {
                  _scheduledDate = null;
                  _timeWindowStart = null;
                  _timeWindowEnd = null;
                }),
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
    final slots = state is OrdersLoaded ? state.timeSlots : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(AppStrings.availableSlots, style: AppTypography.titleMedium),
            const Spacer(),
            GestureDetector(
              onTap: () => context
                  .read<OrdersBloc>()
                  .add(const OrderTimeSlotsLoadRequested()),
              child: Text(
                AppStrings.loadSlots,
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
            AppStrings.loadSlotsHint,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.textCaptionDark
                  : AppColors.textCaption,
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
                    '${AppStrings.slotLabel} ${index + 1}';
                return Chip(
                  label: Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.08),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection(OrdersState state, bool isDark) {
    final priceData =
        state is OrdersLoaded ? state.priceCalculation : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(AppStrings.suggestedDeliveryPrice, style: AppTypography.titleMedium),
            const Spacer(),
            GestureDetector(
              onTap: () {
                final deliveryAddr =
                    _deliveryAddressController.text.trim();
                if (deliveryAddr.isEmpty) return;
                context.read<OrdersBloc>().add(
                      OrderCalculatePriceRequested(data: {
                        'deliveryAddress': deliveryAddr,
                        'pickupAddress':
                            _pickupAddressController.text.trim(),
                        'itemCount': int.tryParse(
                                _itemCountController.text.trim()) ??
                            1,
                        'priority': _selectedPriority.value,
                      }),
                    );
              },
              child: Text(
                AppStrings.calculatePrice,
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
                  AppStrings.suggestedPrice,
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
            AppStrings.calculatePriceHint,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.textCaptionDark
                  : AppColors.textCaption,
            ),
          ),
      ],
    );
  }

  // ───────────────── BULK IMPORT ─────────────────

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
        SekkaInputField(
          controller: _bulkTextController,
          hint: AppStrings.pasteOrdersHere,
          prefixIcon: IconsaxPlusLinear.clipboard_text,
          maxLines: 8,
        ),
        SizedBox(height: AppSizes.lg),
        _buildSectionLabel(AppStrings.paymentMethodLabel),
        SizedBox(height: AppSizes.sm),
        _ChipSelector<PaymentMethod>(
          items: PaymentMethod.values,
          selectedValue: _bulkPaymentMethod,
          labelBuilder: (item) => item.arabic,
          onChanged: (value) =>
              setState(() => _bulkPaymentMethod = value),
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
                          defaultPaymentMethod:
                              _bulkPaymentMethod.value,
                        ),
                      );
                },
        ),
        SizedBox(height: AppSizes.xxl),
      ],
    );
  }
}

// ───────────────── CHIP SELECTOR ─────────────────

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
