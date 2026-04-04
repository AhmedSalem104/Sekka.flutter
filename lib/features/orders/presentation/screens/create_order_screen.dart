import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../../core/widgets/sekka_map_picker.dart';
import '../../../../core/widgets/sekka_stepper.dart';
import '../../../../shared/enums/order_enums.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../../customers/data/models/address_model.dart';
import '../../../customers/data/repositories/address_repository.dart';
import '../../../customers/data/repositories/customer_repository.dart';
import '../../../partners/data/models/partner_model.dart';
import '../../../partners/data/models/pickup_point_model.dart';
import '../../../partners/data/repositories/partner_repository.dart';
import '../../data/models/ocr_result_model.dart';
import '../../data/models/order_model.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/address_picker_sheet.dart';

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

  // ── Address & Customer lookup ──
  late final AddressRepository _addressRepo;
  late final CustomerRepository _customerRepo;
  String? _customerId;
  List<AddressModel> _customerAddresses = [];

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
    _tabController = _isEditMode ? null : TabController(length: 3, vsync: this);
    _idempotencyKey = const Uuid().v4();
    final dio = context.read<DioClient>().dio;
    _partnerRepo = PartnerRepository(dio);
    _addressRepo = context.read<AddressRepository>();
    _customerRepo = CustomerRepository(dio);

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
          if (data.length == 1) {
            // لو فيه نقطة واحدة بس، اختارها تلقائي
            _selectPickupPoint(data.first);
          } else if (data.isEmpty) {
            // لو مفيش نقاط استلام، استخدم عنوان الشريك نفسه
            final partner = _partners
                .where((p) => p.id == partnerId)
                .firstOrNull;
            if (partner?.address != null && partner!.address!.isNotEmpty) {
              _pickupAddressController.text = partner.address!;
            }
          }
        });
      case ApiFailure():
        // لو فشل جلب النقاط، استخدم عنوان الشريك
        final partner = _partners
            .where((p) => p.id == partnerId)
            .firstOrNull;
        if (partner?.address != null && partner!.address!.isNotEmpty) {
          _pickupAddressController.text = partner.address!;
        }
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

  /// Look up customer by phone → load their saved addresses.
  Future<void> _lookupCustomerByPhone(String phone) async {
    if (phone.length < 10) {
      setState(() {
        _customerId = null;
        _customerAddresses = [];
      });
      return;
    }

    final result = await _customerRepo.findByPhone(phone);
    if (!mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        _customerId = data.id;
        // Load saved addresses for this customer
        final addrResult = await _addressRepo.searchAddresses(
          customerId: data.id,
          pageSize: 20,
        );
        if (!mounted) return;
        setState(() {
          if (addrResult case ApiSuccess(:final data)) {
            _customerAddresses = data;
          }
        });
      case ApiFailure():
        setState(() {
          _customerId = null;
          _customerAddresses = [];
        });
    }
  }

  /// Open the address picker bottom sheet for delivery address.
  Future<void> _openAddressPicker() async {
    final selected = await AddressPickerSheet.show(
      context,
      addressRepository: _addressRepo,
      customerId: _customerId,
    );

    if (selected == null || !mounted) return;

    setState(() {
      _deliveryAddressController.text = selected.addressText;
      _deliveryLat = selected.latitude;
      _deliveryLng = selected.longitude;
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
        // Step 1: customer info — phone validation if entered
        final phone = _customerPhoneController.text.trim().toEnglishNumbers;
        if (phone.isNotEmpty) {
          final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
          if (cleaned.length != 11 || !cleaned.startsWith('01')) {
            SekkaMessageDialog.show(
              context,
              message: AppStrings.phoneInvalid,
              type: SekkaMessageType.error,
            );
            return false;
          }
        }
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

    // Moving from step 1 (customer) → step 2 (addresses): look up customer
    if (_currentStep == 0) {
      final phone = _customerPhoneController.text.trim().toEnglishNumbers;
      if (phone.isNotEmpty) {
        _lookupCustomerByPhone(phone);
      }
    }

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

  bool _isCheckingDuplicate = false;

  Future<void> _submit() async {
    if (!_validateStep(2)) return;

    final data = _buildData();

    if (_isEditMode) {
      context.read<OrdersBloc>().add(
            OrderUpdateRequested(
              orderId: widget.order!.id,
              data: data,
            ),
          );
      return;
    }

    // ── Check for duplicate before creating ──
    final phone = _customerPhoneController.text.trim().toEnglishNumbers;
    final address = _deliveryAddressController.text.trim();

    if (phone.isNotEmpty && address.isNotEmpty) {
      setState(() => _isCheckingDuplicate = true);

      context.read<OrdersBloc>().add(
            OrderCheckDuplicateRequested(data: {
              'customerPhone': phone,
              'deliveryAddress': address,
            }),
          );
      // The listener will handle the result
    } else {
      _doCreateOrder(data);
    }
  }

  void _doCreateOrder(Map<String, dynamic> data) {
    context.read<OrdersBloc>().add(OrderCreateRequested(data: data));
  }

  Future<bool> _showDuplicateWarning(Map<String, dynamic> dupData) async {
    final matchScore = dupData['matchScore'] as num? ?? 0;
    final matchedOrder = dupData['matchedOrder'] as Map<String, dynamic>?;

    final orderInfo = matchedOrder != null
        ? '\n\nرقم الطلب: ${matchedOrder['orderNumber'] ?? ''}'
        : '';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning, size: AppSizes.iconLg),
              SizedBox(width: AppSizes.sm),
              Text(AppStrings.duplicateWarningTitle,
                  style: AppTypography.titleMedium),
            ],
          ),
          content: Text(
            '${AppStrings.duplicateWarningMessage}'
            '${matchScore > 0 ? '\n\nنسبة التشابه: $matchScore%' : ''}'
            '$orderInfo',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppStrings.duplicateCancel,
                  style: AppTypography.bodyMedium),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                AppStrings.duplicateContinue,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  }

  // ──────────────────────────── BUILD ────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) async {
          if (state is! OrdersLoaded) return;

          // ── Auto-fill amount from calculated price ──
          if (state.priceCalculation != null) {
            final price = state.priceCalculation!['suggestedPrice'];
            if (price != null && _amountController.text.trim().isEmpty) {
              _amountController.text = '$price';
            }
          }

          // ── Handle duplicate check result ──
          if (_isCheckingDuplicate && state.duplicateCheck != null) {
            _isCheckingDuplicate = false;
            setState(() {});

            final dupData = state.duplicateCheck!;
            final isDuplicate = dupData['isDuplicate'] as bool? ?? false;

            // Clear duplicate check data
            context.read<OrdersBloc>().add(const OrdersClearMessage());

            if (isDuplicate) {
              final shouldContinue = await _showDuplicateWarning(dupData);
              if (!shouldContinue || !mounted) return;
            }

            _doCreateOrder(_buildData());
            return;
          }

          if (state.actionMessage != null) {
            final msg = state.actionMessage!;
            final isError = state.isActionError;

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      msg,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  backgroundColor:
                      isError ? AppColors.error : AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              );

            // امسح الرسالة عشان متتعرضش تاني
            context.read<OrdersBloc>().add(const OrdersClearMessage());

            if (!isError) Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading =
              state is OrdersLoaded && state.isActionInProgress;

          return Scaffold(
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.background,
            appBar: SekkaAppBar(
              title: _isEditMode ? AppStrings.editOrder : AppStrings.addOrder,
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
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            indicator: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSm),
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
                            labelPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(6),
                            ),
                            indicatorPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(1),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(2),
                              vertical: Responsive.w(3),
                            ),
                            tabs: const [
                              Tab(text: AppStrings.manualEntry),
                              Tab(text: AppStrings.bulkImport),
                              Tab(text: AppStrings.ocrEntry),
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
                            _buildOcrTab(state, isLoading, isDark),
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
                onPressed: _previousStep,
              ),
            ),
          if (_currentStep > 0) SizedBox(width: AppSizes.md),

          // Next or Submit
          Expanded(
            child: _currentStep < _totalSteps - 1
                ? SekkaButton(
                    label: AppStrings.nextStep,
                    onPressed: _nextStep,
                  )
                : SekkaButton(
                    label: _isEditMode
                        ? AppStrings.saveChanges
                        : AppStrings.confirmAdd,
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

        // Recurring fields
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
      ],
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
      Row(
        children: [
          Expanded(child: _buildSectionLabel(AppStrings.deliveryAddress)),
          // Address picker button
          TextButton.icon(
            onPressed: _openAddressPicker,
            icon: Icon(
              IconsaxPlusLinear.archive_book,
              size: Responsive.r(16),
            ),
            label: Text(
              AppStrings.savedAddresses,
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
            ),
          ),
        ],
      ),
      SizedBox(height: AppSizes.sm),
      _buildAddressField(
        controller: _deliveryAddressController,
        hint: AppStrings.deliveryAddress,
        isPickup: false,
        hasCoords: _deliveryLat != null && _deliveryLng != null,
        isDark: isDark,
      ),

      // ── Customer Saved Addresses (quick select) ──
      if (_customerAddresses.isNotEmpty) ...[
        SizedBox(height: AppSizes.md),
        SizedBox(
          height: Responsive.h(48),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: _customerAddresses.length,
            separatorBuilder: (_, __) => SizedBox(width: AppSizes.sm),
            itemBuilder: (_, index) {
              final addr = _customerAddresses[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _deliveryAddressController.text = addr.addressText;
                    _deliveryLat = addr.latitude;
                    _deliveryLng = addr.longitude;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: _deliveryAddressController.text == addr.addressText
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : isDark
                            ? AppColors.backgroundDark
                            : AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    border: Border.all(
                      color:
                          _deliveryAddressController.text == addr.addressText
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconsaxPlusLinear.location,
                        size: Responsive.r(14),
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSizes.xs),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: Responsive.w(180)),
                        child: Text(
                          addr.addressText,
                          style: AppTypography.captionSmall.copyWith(
                            color: isDark
                                ? AppColors.textHeadlineDark
                                : AppColors.textHeadline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

      // (recurring fields moved to step 1)

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: AppTypography.titleMedium.copyWith(
        color: isDark
            ? AppColors.textHeadlineDark
            : AppColors.textHeadline,
      ),
    );
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
            Text(
              AppStrings.availableSlots,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
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
                        BorderRadius.circular(AppSizes.chipRadius),
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
            Text(
              AppStrings.suggestedDeliveryPrice,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),
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
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textBodyDark
                        : AppColors.textBody,
                  ),
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

  Widget _buildVoiceEntryTab(bool isLoading, bool isDark) {
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mic icon
            Container(
              width: Responsive.r(100),
              height: Responsive.r(100),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusBold.microphone_2,
                size: Responsive.r(48),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.xxl),
            Text(
              'قول الطلب بصوتك',
              style: AppTypography.titleLarge,
            ),
            SizedBox(height: AppSizes.md),
            Text(
              'اضغط على المايك وقول بيانات الطلب\nزي: "طلب لمحمد، العنوان المعادي، المبلغ 150 جنيه"',
              style: AppTypography.bodyMedium.copyWith(color: captionColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.xxl),
            Text(
              'الميزة دي جاية قريب',
              style: AppTypography.caption.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── OCR Tab ──

  int _ocrMode = 0; // 0: صوّر فاتورة, 1: إنشاء فوري, 2: مسح مجمّع
  final _imagePicker = ImagePicker();

  // كل وضع ليه الصورة الخاصة بيه
  File? _ocrScanImage;
  File? _ocrDirectImage;
  List<File> _ocrBatchImages = [];

  Future<File?> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    return picked != null ? File(picked.path) : null;
  }

  Future<void> _pickBatchImages() async {
    final picked = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() {
        _ocrBatchImages = picked.map((x) => File(x.path)).toList();
      });
    }
  }

  void _showImageSourceSheet({required ValueChanged<File> onPicked}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SekkaButton(
              label: AppStrings.ocrTakePhoto,
              icon: IconsaxPlusLinear.camera,
              type: SekkaButtonType.secondary,
              onPressed: () async {
                Navigator.pop(context);
                final file = await _pickImage(ImageSource.camera);
                if (file != null) onPicked(file);
              },
            ),
            SizedBox(height: AppSizes.md),
            SekkaButton(
              label: AppStrings.ocrChooseGallery,
              icon: IconsaxPlusLinear.gallery,
              type: SekkaButtonType.secondary,
              onPressed: () async {
                Navigator.pop(context);
                final file = await _pickImage(ImageSource.gallery);
                if (file != null) onPicked(file);
              },
            ),
            SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  static const _ocrModeLabels = [
    AppStrings.ocrScanSingle,
    AppStrings.ocrScanDirect,
    AppStrings.ocrScanBatch,
  ];

  Widget _buildOcrTab(OrdersState state, bool isLoading, bool isDark) {
    final isScanning = state is OrdersLoaded && state.isOcrScanning;
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── العنوان ──
          Text(
            AppStrings.ocrTabTitle,
            style: AppTypography.titleLarge,
          ),
          SizedBox(height: AppSizes.md),

          // ── Dropdown اختيار الوضع ──
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.border,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _ocrMode,
                isExpanded: true,
                icon: Icon(
                  IconsaxPlusLinear.arrow_down_1,
                  color: captionColor,
                ),
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
                dropdownColor:
                    isDark ? AppColors.surfaceDark : AppColors.surface,
                items: List.generate(
                  _ocrModeLabels.length,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(_ocrModeLabels[i]),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) setState(() => _ocrMode = v);
                },
              ),
            ),
          ),
          SizedBox(height: AppSizes.xxl),

          // ── المحتوى بناءً على الاختيار ──
          switch (_ocrMode) {
            0 => _buildOcrScanContent(state, isScanning, isDark),
            1 => _buildOcrDirectContent(state, isScanning, isDark),
            2 => _buildOcrBatchContent(state, isScanning, isDark),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }

  // ── 1. صوّر فاتورة (مراجعة أولاً) ──
  Widget _buildOcrScanContent(
    OrdersState state,
    bool isScanning,
    bool isDark,
  ) {
    final ocrResult = state is OrdersLoaded ? state.ocrResult : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildOcrHeader(
          icon: IconsaxPlusBold.scan_barcode,
          title: AppStrings.ocrScanSingle,
          subtitle: AppStrings.ocrScanSingleDesc,
          isDark: isDark,
        ),
        SizedBox(height: AppSizes.xxl),

        // Image preview
        if (_ocrScanImage != null) ...[
          _buildImagePreview(_ocrScanImage!),
          SizedBox(height: AppSizes.md),
        ],

        // Pick image button
        SekkaButton(
          label: AppStrings.ocrPickImage,
          icon: IconsaxPlusLinear.camera,
          type: SekkaButtonType.secondary,
          onPressed: isScanning
              ? null
              : () => _showImageSourceSheet(
                    onPicked: (file) =>
                        setState(() => _ocrScanImage = file),
                  ),
        ),

        // Scan button
        if (_ocrScanImage != null) ...[
          SizedBox(height: AppSizes.md),
          SekkaButton(
            label: AppStrings.ocrScanSingle,
            icon: IconsaxPlusLinear.scan,
            isLoading: isScanning,
            onPressed: isScanning
                ? null
                : () {
                    context.read<OrdersBloc>().add(
                          OcrScanInvoiceRequested(
                            imageFile: _ocrScanImage!,
                          ),
                        );
                  },
          ),
        ],

        // Results
        if (ocrResult != null) ...[
          SizedBox(height: AppSizes.xxl),
          Text(
            AppStrings.ocrExtractedData,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSizes.md),
          _buildOcrResultCard(ocrResult, isDark),
          SizedBox(height: AppSizes.md),
          SekkaButton(
            label: AppStrings.ocrConfirmOrder,
            icon: IconsaxPlusLinear.tick_circle,
            onPressed: () {
              _fillFormFromOcrResult(ocrResult);
              _tabController?.animateTo(0);
              context
                  .read<OrdersBloc>()
                  .add(const OcrClearResult());
            },
          ),
        ],

        SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  // ── 2. إنشاء فوري ──
  Widget _buildOcrDirectContent(
    OrdersState state,
    bool isScanning,
    bool isDark,
  ) {
    final ocrCreatedOrder =
        state is OrdersLoaded ? state.ocrCreatedOrder : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildOcrHeader(
          icon: IconsaxPlusBold.flash_1,
          title: AppStrings.ocrScanDirect,
          subtitle: AppStrings.ocrScanDirectDesc,
          isDark: isDark,
          iconColor: AppColors.success,
        ),
        SizedBox(height: AppSizes.xxl),

        // Image preview
        if (_ocrDirectImage != null) ...[
          _buildImagePreview(_ocrDirectImage!),
          SizedBox(height: AppSizes.md),
        ],

        // Pick image button
        SekkaButton(
          label: AppStrings.ocrPickImage,
          icon: IconsaxPlusLinear.camera,
          type: SekkaButtonType.secondary,
          onPressed: isScanning
              ? null
              : () => _showImageSourceSheet(
                    onPicked: (file) =>
                        setState(() => _ocrDirectImage = file),
                  ),
        ),

        // Scan & create button
        if (_ocrDirectImage != null) ...[
          SizedBox(height: AppSizes.md),
          SekkaButton(
            label: AppStrings.ocrScanDirect,
            icon: IconsaxPlusLinear.flash_1,
            isLoading: isScanning,
            onPressed: isScanning
                ? null
                : () {
                    context.read<OrdersBloc>().add(
                          OcrScanToOrderRequested(
                            imageFile: _ocrDirectImage!,
                          ),
                        );
                  },
          ),
        ],

        // Success result
        if (ocrCreatedOrder != null) ...[
          SizedBox(height: AppSizes.xxl),
          SekkaCard(
            onTap: null,
            child: Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: Column(
                children: [
                  Icon(
                    IconsaxPlusBold.tick_circle,
                    color: AppColors.success,
                    size: Responsive.r(56),
                  ),
                  SizedBox(height: AppSizes.md),
                  Text(
                    AppStrings.ocrDirectSuccess,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSizes.sm),
                  Text(
                    '#${ocrCreatedOrder.orderNumber}',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  // ── 3. مسح مجمّع ──
  Widget _buildOcrBatchContent(
    OrdersState state,
    bool isScanning,
    bool isDark,
  ) {
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;
    final ocrBatchResult =
        state is OrdersLoaded ? state.ocrBatchResult : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        _buildOcrHeader(
          icon: IconsaxPlusBold.document_copy,
          title: AppStrings.ocrScanBatch,
          subtitle: AppStrings.ocrScanBatchDesc,
          isDark: isDark,
          iconColor: AppColors.info,
        ),
        SizedBox(height: AppSizes.xxl),

        // Batch images preview
        if (_ocrBatchImages.isNotEmpty) ...[
          SizedBox(
            height: Responsive.h(120),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _ocrBatchImages.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: AppSizes.sm),
              itemBuilder: (_, index) => ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusMd),
                child: Image.file(
                  _ocrBatchImages[index],
                  width: Responsive.w(90),
                  height: Responsive.h(120),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            '${_ocrBatchImages.length} ${AppStrings.ocrImageCount}',
            style: AppTypography.bodySmall.copyWith(
              color: captionColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.md),
        ],

        // Select images button
        SekkaButton(
          label: AppStrings.ocrSelectImages,
          icon: IconsaxPlusLinear.gallery,
          type: SekkaButtonType.secondary,
          onPressed: isScanning ? null : _pickBatchImages,
        ),

        // Scan batch button
        if (_ocrBatchImages.isNotEmpty) ...[
          SizedBox(height: AppSizes.md),
          SekkaButton(
            label:
                '${AppStrings.ocrScanBatch} (${_ocrBatchImages.length})',
            icon: IconsaxPlusLinear.scan,
            isLoading: isScanning,
            onPressed: isScanning
                ? null
                : () {
                    context.read<OrdersBloc>().add(
                          OcrScanBatchRequested(
                            imageFiles: _ocrBatchImages,
                          ),
                        );
                  },
          ),
        ],

        // Batch results
        if (ocrBatchResult != null) ...[
          SizedBox(height: AppSizes.xxl),
          Text(
            '${AppStrings.ocrBatchSuccess} (${ocrBatchResult.successCount}/${ocrBatchResult.totalScanned})',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSizes.md),
          ...ocrBatchResult.results.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.sm),
                  child: _buildOcrResultCard(
                    entry.value,
                    isDark,
                    index: entry.key + 1,
                  ),
                ),
              ),
        ],

        SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  // ── Shared OCR widgets ──

  Widget _buildOcrHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Color? iconColor,
  }) {
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;
    final color = iconColor ?? AppColors.primary;

    return Column(
      children: [
        Center(
          child: Container(
            width: Responsive.r(72),
            height: Responsive.r(72),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: Responsive.r(36),
              color: color,
            ),
          ),
        ),
        SizedBox(height: AppSizes.md),
        Text(
          title,
          style: AppTypography.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(color: captionColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImagePreview(File imageFile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Image.file(
        imageFile,
        height: Responsive.h(200),
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildOcrResultCard(
    OcrResultModel result,
    bool isDark, {
    int? index,
  }) {
    final captionColor =
        isDark ? AppColors.textCaptionDark : AppColors.textCaption;

    return SekkaCard(
      onTap: null,
      child: Padding(
        padding: EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index != null) ...[
              Text(
                '# $index',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSizes.xs),
            ],
            if (result.confidence != null) ...[
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.chart_1,
                    size: Responsive.r(16),
                    color: captionColor,
                  ),
                  SizedBox(width: AppSizes.xs),
                  Text(
                    '${AppStrings.ocrConfidence}: ${(result.confidence! * 100).toStringAsFixed(0)}%',
                    style: AppTypography.caption.copyWith(
                      color: captionColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.sm),
            ],
            if (result.customerName != null)
              _buildOcrDataRow(
                AppStrings.ocrCustomerName,
                result.customerName!,
                IconsaxPlusLinear.user,
              ),
            if (result.customerPhone != null)
              _buildOcrDataRow(
                AppStrings.phone,
                result.customerPhone!,
                IconsaxPlusLinear.call,
              ),
            if (result.address != null)
              _buildOcrDataRow(
                AppStrings.ocrAddress,
                result.address!,
                IconsaxPlusLinear.location,
              ),
            if (result.amount != null)
              _buildOcrDataRow(
                AppStrings.ocrAmount,
                '${result.amount} ${AppStrings.currency}',
                IconsaxPlusLinear.money_2,
              ),
            if (result.description != null)
              _buildOcrDataRow(
                AppStrings.shipmentDescription,
                result.description!,
                IconsaxPlusLinear.document_text,
              ),
            if (result.items.isNotEmpty) ...[
              SizedBox(height: AppSizes.sm),
              Text(
                AppStrings.ocrItems,
                style: AppTypography.caption.copyWith(
                  color: captionColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...result.items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(
                    right: AppSizes.md,
                    top: AppSizes.xs,
                  ),
                  child: Text(
                    '• ${item.name ?? '-'} × ${item.quantity ?? 1} — ${item.price ?? '-'}',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOcrDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: Responsive.r(18), color: AppColors.primary),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textCaption,
                  ),
                ),
                Text(value, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _fillFormFromOcrResult(OcrResultModel result) {
    if (result.customerName != null) {
      _customerNameController.text = result.customerName!;
    }
    if (result.customerPhone != null) {
      _customerPhoneController.text = result.customerPhone!;
    }
    if (result.address != null) {
      _deliveryAddressController.text = result.address!;
    }
    if (result.amount != null) {
      _amountController.text = result.amount!.toStringAsFixed(0);
    }
    if (result.description != null) {
      _descriptionController.text = result.description!;
    }
    setState(() {
      _currentStep = 0;
      _ocrScanImage = null;
    });
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
              borderRadius: BorderRadius.circular(AppSizes.chipRadius),
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
