import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_expandable_section.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_toggle_tile.dart';
import '../bloc/privacy_bloc.dart';
import '../bloc/privacy_event.dart';
import '../bloc/privacy_state.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrivacyBloc>().add(const PrivacyLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.privacySettings),
      body: BlocConsumer<PrivacyBloc, PrivacyState>(
        listenWhen: (prev, curr) =>
            curr is PrivacyLoaded &&
            (curr.errorMessage != null || curr.successMessage != null),
        listener: (context, state) {
          if (state is PrivacyLoaded) {
            if (state.errorMessage != null) {
              context.showSnackBar(state.errorMessage!, isError: true);
            }
            if (state.successMessage != null) {
              context.showSnackBar(state.successMessage!);
            }
            context.read<PrivacyBloc>().add(const PrivacyErrorCleared());
          }
        },
        buildWhen: (prev, curr) {
          if (prev is PrivacyLoaded && curr is PrivacyLoaded) {
            return prev.consents != curr.consents ||
                prev.isSaving != curr.isSaving ||
                prev.deleteStatus != curr.deleteStatus;
          }
          return true;
        },
        builder: (context, state) {
          if (state is PrivacyLoading) return const SekkaLoading();
          if (state is PrivacyLoaded) return _buildContent(context, state);
          if (state is PrivacyError) return _buildError(context, state.message);
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            ),
          ),
          SizedBox(height: AppSizes.lg),
          TextButton(
            onPressed: () => context
                .read<PrivacyBloc>()
                .add(const PrivacyLoadRequested()),
            child: Text(
              AppStrings.retry,
              style: AppTypography.titleMedium
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PrivacyLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      children: [
        SizedBox(height: AppSizes.lg),

        // Saving indicator
        if (state.isSaving)
          Padding(
            padding: EdgeInsets.only(bottom: AppSizes.sm),
            child: const LinearProgressIndicator(color: AppColors.primary),
          ),

        // ── Consents ───────────────────────────────
        SekkaExpandableSection(
          title: AppStrings.consentsSectionTitle,
          leadingIcon: IconsaxPlusLinear.shield_tick,
          initiallyExpanded: true,
          children: [
            SekkaToggleTile(
              label: AppStrings.consentLocationTracking,
              subtitle: AppStrings.consentLocationTrackingDesc,
              value: state.consentGranted('LocationTracking'),
              onChanged: (val) => context
                  .read<PrivacyBloc>()
                  .add(PrivacyConsentToggled('LocationTracking', val)),
            ),
            SekkaToggleTile(
              label: AppStrings.consentMarketing,
              subtitle: AppStrings.consentMarketingDesc,
              value: state.consentGranted('marketing'),
              onChanged: (val) => context
                  .read<PrivacyBloc>()
                  .add(PrivacyConsentToggled('marketing', val)),
            ),
          ],
        ),

        SizedBox(height: AppSizes.lg),

        // ── My Data ────────────────────────────────
        SekkaExpandableSection(
          title: AppStrings.myDataSectionTitle,
          leadingIcon: IconsaxPlusLinear.document_download,
          initiallyExpanded: true,
          children: [
            // Export data
            _DataActionCard(
              icon: IconsaxPlusLinear.export_1,
              title: AppStrings.exportMyData,
              description: AppStrings.exportMyDataDesc,
              buttonLabel: AppStrings.requestExport,
              isDark: isDark,
              onPressed: () => context
                  .read<PrivacyBloc>()
                  .add(const PrivacyExportRequested()),
            ),

            SizedBox(height: AppSizes.md),

            // Delete data
            _DataActionCard(
              icon: IconsaxPlusLinear.trash,
              title: AppStrings.deleteMyData,
              description: AppStrings.deleteMyDataDesc,
              buttonLabel: AppStrings.requestDeletion,
              isDark: isDark,
              isDanger: true,
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),

        // Delete status
        if (state.deleteStatus != null) ...[
          SizedBox(height: AppSizes.lg),
          _DeleteStatusCard(
            status: state.deleteStatus!,
            isDark: isDark,
          ),
        ],

        SizedBox(height: AppSizes.xxxl),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final reasonCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.pagePadding,
            AppSizes.xxl,
            AppSizes.pagePadding,
            MediaQuery.of(ctx).viewInsets.bottom + AppSizes.xxxl,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: Responsive.w(40),
                  height: Responsive.h(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ),
                SizedBox(height: AppSizes.xxl),

                // Danger icon
                Container(
                  width: Responsive.r(64),
                  height: Responsive.r(64),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconsaxPlusLinear.trash,
                    color: AppColors.error,
                    size: Responsive.r(28),
                  ),
                ),
                SizedBox(height: AppSizes.lg),

                Text(
                  AppStrings.deleteDataConfirmTitle,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.sm),

                Text(
                  AppStrings.deleteDataConfirmDesc,
                  style: AppTypography.bodyMedium.copyWith(
                    color:
                        isDark ? AppColors.textBodyDark : AppColors.textBody,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.xl),

                SekkaInputField(
                  controller: reasonCtrl,
                  label: AppStrings.deleteDataReason,
                  prefixIcon: IconsaxPlusLinear.message,
                  maxLines: 2,
                ),
                SizedBox(height: AppSizes.xl),

                SekkaButton(
                  label: AppStrings.confirmDeleteData,
                  onPressed: () {
                    Navigator.pop(ctx);
                    final reason = reasonCtrl.text.trim();
                    context.read<PrivacyBloc>().add(
                          PrivacyDeleteRequested(
                            reason: reason.isEmpty ? null : reason,
                          ),
                        );
                  },
                  type: SekkaButtonType.primary,
                  backgroundColor: AppColors.error,
                ),
                SizedBox(height: AppSizes.md),

                SekkaButton(
                  label: AppStrings.cancel,
                  onPressed: () => Navigator.pop(ctx),
                  type: SekkaButtonType.text,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Private helper widgets ─────────────────────────────────────────

class _DataActionCard extends StatelessWidget {
  const _DataActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.isDark,
    required this.onPressed,
    this.isDanger = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final bool isDark;
  final VoidCallback onPressed;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDanger ? AppColors.error : AppColors.primary;

    return SekkaCard(
      padding: EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: Responsive.r(40),
                height: Responsive.r(40),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: Responsive.r(20),
                ),
              ),
              SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textCaptionDark : AppColors.textCaption,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSizes.md),
          SekkaButton(
            label: buttonLabel,
            onPressed: onPressed,
            type: isDanger ? SekkaButtonType.secondary : SekkaButtonType.primary,
            backgroundColor: isDanger ? null : null,
          ),
        ],
      ),
    );
  }
}

class _DeleteStatusCard extends StatelessWidget {
  const _DeleteStatusCard({
    required this.status,
    required this.isDark,
  });

  final dynamic status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SekkaCard(
      padding: EdgeInsets.all(AppSizes.lg),
      borderColor: AppColors.warning,
      child: Row(
        children: [
          Container(
            width: Responsive.r(40),
            height: Responsive.r(40),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              IconsaxPlusLinear.clock,
              color: AppColors.warning,
              size: Responsive.r(20),
            ),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.deleteStatusTitle,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.deleteStatusPending,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
