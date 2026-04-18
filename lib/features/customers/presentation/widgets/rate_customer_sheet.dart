import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_star_rating.dart';
import '../../data/models/create_rating_model.dart';

class RateCustomerSheet extends StatefulWidget {
  const RateCustomerSheet({
    super.key,
    required this.onSubmit,
    this.initialRating = 0,
    this.initialFeedback,
  });

  final ValueChanged<CreateRatingModel> onSubmit;
  final int initialRating;
  final String? initialFeedback;

  @override
  State<RateCustomerSheet> createState() => _RateCustomerSheetState();
}

class _RateCustomerSheetState extends State<RateCustomerSheet> {
  late int _rating = widget.initialRating;
  late final _feedbackController =
      TextEditingController(text: widget.initialFeedback ?? '');

  // Positive tags
  bool _quickResponse = false;
  bool _clearAddress = false;
  bool _respectfulBehavior = false;
  bool _easyPayment = false;

  // Negative tags
  bool _wrongAddress = false;
  bool _noAnswer = false;
  bool _delayedPickup = false;
  bool _paymentIssue = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(24)),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(20),
          vertical: Responsive.h(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: Responsive.w(40),
              height: Responsive.h(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(Responsive.r(100)),
              ),
            ),

            SizedBox(height: Responsive.h(20)),

            // Title
            Text(
              AppStrings.rateCustomer,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
            ),

            SizedBox(height: Responsive.h(24)),

            // Star rating
            Center(
              child: SekkaStarRating(
                rating: _rating,
                onChanged: (v) => setState(() => _rating = v),
              ),
            ),

            SizedBox(height: Responsive.h(24)),

            // Quick tags
            Wrap(
              spacing: Responsive.w(8),
              runSpacing: Responsive.h(8),
              children: [
                // Positive tags (green outline)
                _buildTag(
                  label: AppStrings.quickResponse,
                  isSelected: _quickResponse,
                  isPositive: true,
                  onTap: () => setState(() {
                    _quickResponse = !_quickResponse;
                  }),
                ),
                _buildTag(
                  label: AppStrings.clearAddress,
                  isSelected: _clearAddress,
                  isPositive: true,
                  onTap: () => setState(() {
                    _clearAddress = !_clearAddress;
                  }),
                ),
                _buildTag(
                  label: AppStrings.respectfulBehavior,
                  isSelected: _respectfulBehavior,
                  isPositive: true,
                  onTap: () => setState(() {
                    _respectfulBehavior = !_respectfulBehavior;
                  }),
                ),
                _buildTag(
                  label: AppStrings.easyPayment,
                  isSelected: _easyPayment,
                  isPositive: true,
                  onTap: () => setState(() {
                    _easyPayment = !_easyPayment;
                  }),
                ),
                // Negative tags (red outline)
                _buildTag(
                  label: AppStrings.wrongAddress,
                  isSelected: _wrongAddress,
                  isPositive: false,
                  onTap: () => setState(() {
                    _wrongAddress = !_wrongAddress;
                  }),
                ),
                _buildTag(
                  label: AppStrings.noAnswer,
                  isSelected: _noAnswer,
                  isPositive: false,
                  onTap: () => setState(() {
                    _noAnswer = !_noAnswer;
                  }),
                ),
                _buildTag(
                  label: AppStrings.delayedPickup,
                  isSelected: _delayedPickup,
                  isPositive: false,
                  onTap: () => setState(() {
                    _delayedPickup = !_delayedPickup;
                  }),
                ),
                _buildTag(
                  label: AppStrings.paymentIssue,
                  isSelected: _paymentIssue,
                  isPositive: false,
                  onTap: () => setState(() {
                    _paymentIssue = !_paymentIssue;
                  }),
                ),
              ],
            ),

            SizedBox(height: Responsive.h(20)),

            // Feedback text field
            SekkaInputField(
              controller: _feedbackController,
              hint: 'اكتب ملاحظاتك هنا...',
              maxLines: 3,
            ),

            SizedBox(height: Responsive.h(24)),

            // Submit button
            SekkaButton(
              label: AppStrings.confirm,
              onPressed: _rating > 0
                  ? () {
                      final model = CreateRatingModel(
                        ratingValue: _rating,
                        quickResponse: _quickResponse,
                        clearAddress: _clearAddress,
                        respectfulBehavior: _respectfulBehavior,
                        easyPayment: _easyPayment,
                        wrongAddress: _wrongAddress,
                        noAnswer: _noAnswer,
                        delayedPickup: _delayedPickup,
                        paymentIssue: _paymentIssue,
                        feedbackText: _feedbackController.text.isNotEmpty
                            ? _feedbackController.text
                            : null,
                      );
                      widget.onSubmit(model);
                    }
                  : null,
            ),

            SizedBox(height: Responsive.h(16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({
    required String label,
    required bool isSelected,
    required bool isPositive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isPositive ? AppColors.success : AppColors.error;
    final borderColor = isSelected
        ? activeColor
        : isDark
            ? AppColors.borderDark
            : AppColors.border;
    final backgroundColor = isSelected
        ? activeColor.withValues(alpha: 0.1)
        : Colors.transparent;
    final textColor = isSelected
        ? activeColor
        : isDark
            ? AppColors.textCaptionDark
            : AppColors.textCaption;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(14),
          vertical: Responsive.h(8),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
