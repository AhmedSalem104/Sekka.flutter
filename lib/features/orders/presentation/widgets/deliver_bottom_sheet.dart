import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_star_rating.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';

Future<void> showDeliverBottomSheet(
  BuildContext context, {
  required String orderId,
}) {
  final ordersBloc = context.read<OrdersBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusXl),
      ),
    ),
    builder: (_) => BlocProvider.value(
      value: ordersBloc,
      child: DeliverBottomSheet(orderId: orderId),
    ),
  );
}

class DeliverBottomSheet extends StatefulWidget {
  const DeliverBottomSheet({super.key, required this.orderId});

  final String orderId;

  @override
  State<DeliverBottomSheet> createState() => _DeliverBottomSheetState();
}

class _DeliverBottomSheetState extends State<DeliverBottomSheet> {
  final _notesCtrl = TextEditingController();
  int _rating = 0;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: AppSizes.md),
                    width: Responsive.w(40),
                    height: Responsive.h(4),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.lg),
                Text(
                  AppStrings.confirmDelivery,
                  style: AppTypography.headlineSmall,
                ),
                SizedBox(height: AppSizes.lg),
                Text('قيّم العميل', style: AppTypography.titleMedium),
                SizedBox(height: AppSizes.sm),
                Center(
                  child: SekkaStarRating(
                    rating: _rating,
                    onChanged: (v) => setState(() => _rating = v),
                  ),
                ),
                SizedBox(height: AppSizes.md),
                SekkaInputField(
                  controller: _notesCtrl,
                  hint: AppStrings.additionalNotes,
                  maxLines: 3,
                  prefixIcon: IconsaxPlusLinear.note_text,
                ),
                SizedBox(height: AppSizes.xl),
                SekkaButton(
                  label: AppStrings.confirmDelivery,
                  onPressed: () {
                    context.read<OrdersBloc>().add(
                          OrderDeliverRequested(
                            orderId: widget.orderId,
                            latitude: _lat,
                            longitude: _lng,
                            notes: _notesCtrl.text.isEmpty
                                ? null
                                : _notesCtrl.text,
                            rating: _rating,
                          ),
                        );
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
