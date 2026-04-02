import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/otp_input_box.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_completion_card.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_section_tile.dart';
import '../widgets/profile_stats_summary.dart';
import '../widgets/referral_code_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ProfileBloc>();
    if (bloc.state is ProfileLoaded) {
      bloc.add(const ProfileRefreshRequested());
    } else {
      bloc.add(const ProfileLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(title: AppStrings.profileTitle),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (prev, curr) => curr is ProfileError,
        listener: (context, state) {
          if (state is ProfileError) {
            SekkaMessageDialog.show(context, message: state.message);
          }
        },
        buildWhen: (prev, curr) {
          if (prev is ProfileLoaded && curr is ProfileLoaded) {
            return prev.profile != curr.profile ||
                prev.completion != curr.completion ||
                prev.stats != curr.stats;
          }
          return true;
        },
        builder: (context, state) {
          if (state is ProfileLoading) return const SekkaLoading();
          if (state is ProfileLoaded) return _buildContent(context, state, isDark);
          if (state is ProfileError) return _buildError(context, state.message);
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
                .read<ProfileBloc>()
                .add(const ProfileLoadRequested()),
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

  Widget _buildContent(
    BuildContext context,
    ProfileLoaded state,
    bool isDark,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<ProfileBloc>().add(const ProfileRefreshRequested());
      },
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
        children: [
          SizedBox(height: AppSizes.lg),

          // Header — avatar, name, phone, level, stats, edit button
          ProfileHeaderCard(
            profile: state.profile,
            stats: state.stats,
            onEditTap: () => context.push(RouteNames.editProfile),
            onAvatarTap: () => _pickProfileImage(context),
          ),
          SizedBox(height: AppSizes.lg),

          // Completion — progress bar
          ProfileCompletionCard(
            completion: state.completion,
            onStepTap: (_) => context.push(RouteNames.editProfile),
          ),
          if (!state.completion.isProfileComplete) SizedBox(height: AppSizes.lg),

          // Referral code
          ReferralCodeCard(code: state.profile.referralCode ?? ''),
          SizedBox(height: AppSizes.xxl),

          // ── Sections ──────────────────────────────
          ProfileSectionTile(
            icon: IconsaxPlusLinear.card,
            label: AppStrings.badgeSectionLabel,
            onTap: () => context.push(RouteNames.badge),
          ),
          SizedBox(height: AppSizes.sm),

          ProfileSectionTile(
            icon: IconsaxPlusLinear.notification,
            label: AppStrings.notificationsTitle,
            onTap: () => context.push(RouteNames.notifications),
          ),
          SizedBox(height: AppSizes.sm),

          ProfileSectionTile(
            icon: IconsaxPlusLinear.chart_2,
            label: AppStrings.detailedStats,
            onTap: () => context.push(RouteNames.profileStats),
          ),
          SizedBox(height: AppSizes.sm),

          ProfileSectionTile(
            icon: IconsaxPlusLinear.call_calling,
            label: AppStrings.emergencyContacts,
            onTap: () => context.push(RouteNames.emergencyContacts),
          ),
          SizedBox(height: AppSizes.sm),


          ProfileSectionTile(
            icon: IconsaxPlusLinear.money_send,
            label: AppStrings.expenses,
            onTap: () => context.push(RouteNames.profileExpenses),
          ),
          SizedBox(height: AppSizes.sm),

          ProfileSectionTile(
            icon: IconsaxPlusLinear.message,
            label: AppStrings.chatTitle,
            onTap: () => context.push(RouteNames.chat),
          ),
          SizedBox(height: AppSizes.sm),

          ProfileSectionTile(
            icon: IconsaxPlusLinear.setting_2,
            label: AppStrings.settings,
            onTap: () => context.push(RouteNames.settings),
          ),
          SizedBox(height: AppSizes.xxl),

          // Delete Account
          ProfileSectionTile(
            icon: IconsaxPlusLinear.user_remove,
            label: AppStrings.deleteAccount,
            color: AppColors.error,
            trailing: const SizedBox.shrink(),
            onTap: () => _showDeleteAccountSheet(context),
          ),
          SizedBox(height: AppSizes.sm),

          // Logout
          ProfileSectionTile(
            icon: IconsaxPlusLinear.logout,
            label: AppStrings.logout,
            color: AppColors.error,
            trailing: const SizedBox.shrink(),
            onTap: () => _showLogoutDialog(context),
          ),
          SizedBox(height: AppSizes.xxl),

          SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(IconsaxPlusLinear.camera, color: AppColors.primary),
              title: Text(AppStrings.camera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(IconsaxPlusLinear.gallery, color: AppColors.primary),
              title: Text(AppStrings.gallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picked = await _picker.pickImage(source: source, maxWidth: 800);
    if (picked == null || !mounted) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppStrings.changePhoto,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.textOnPrimary,
          activeControlsWidgetColor: AppColors.primary,
          cropStyle: CropStyle.circle,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
      ],
    );
    if (cropped == null || !mounted) return;

    context.read<ProfileBloc>().add(
          ProfileImageUploadRequested(File(cropped.path)),
        );
  }

  void _showDeleteAccountSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const _DeleteAccountSheet(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        title: Text(
          AppStrings.logout,
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.textHeadlineDark
                : AppColors.textHeadline,
          ),
        ),
        content: Text(
          AppStrings.logoutConfirm,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textCaptionDark
                    : AppColors.textCaption,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: Text(
              AppStrings.logout,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delete Account Bottom Sheet ───────────────────────────────────────

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _reasonCtrl = TextEditingController();
  final _otpKey = GlobalKey<OtpInputBoxState>();
  String _otpCode = '';
  bool _phase2 = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthDeletionOtpSent) {
          setState(() {
            _phase2 = true;
            _errorMessage = null;
          });
        } else if (state is AuthDeletionError) {
          setState(() => _errorMessage = state.message);
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.pagePadding,
            AppSizes.xxl,
            AppSizes.pagePadding,
            MediaQuery.of(context).viewInsets.bottom + AppSizes.xxxl,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _phase2
                ? _OtpPhase(
                    key: const ValueKey('otp'),
                    otpKey: _otpKey,
                    isLoading: isLoading,
                    errorMessage: _errorMessage,
                    onOtpChanged: (code) => setState(() {
                      _otpCode = code;
                      _errorMessage = null;
                    }),
                    onConfirm: () {
                      if (_otpCode.length < 4) return;
                      context.read<AuthBloc>().add(
                            AuthConfirmDeletionRequested(otpCode: _otpCode),
                          );
                    },
                    onBack: () {
                      setState(() {
                        _phase2 = false;
                        _otpCode = '';
                        _errorMessage = null;
                        _otpKey.currentState?.clear();
                      });
                    },
                    isDark: isDark,
                  )
                : _WarningPhase(
                    key: const ValueKey('warning'),
                    reasonCtrl: _reasonCtrl,
                    isLoading: isLoading,
                    errorMessage: _errorMessage,
                    onSendOtp: () {
                      setState(() => _errorMessage = null);
                      final reason = _reasonCtrl.text.trim();
                      context.read<AuthBloc>().add(
                            AuthDeleteAccountRequested(
                              reason: reason.isEmpty ? null : reason,
                            ),
                          );
                    },
                    onCancel: () => Navigator.pop(context),
                    isDark: isDark,
                  ),
          ),
        );
      },
    );
  }
}

class _WarningPhase extends StatelessWidget {
  const _WarningPhase({
    super.key,
    required this.reasonCtrl,
    required this.isLoading,
    required this.onSendOtp,
    required this.onCancel,
    required this.isDark,
    this.errorMessage,
  });

  final TextEditingController reasonCtrl;
  final bool isLoading;
  final VoidCallback onSendOtp;
  final VoidCallback onCancel;
  final bool isDark;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: Responsive.w(40),
          height: Responsive.h(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.borderDark : AppColors.border,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
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
            IconsaxPlusLinear.user_remove,
            color: AppColors.error,
            size: Responsive.r(28),
          ),
        ),
        SizedBox(height: AppSizes.lg),

        // Title
        Text(
          AppStrings.deleteAccountTitle,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.error,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.sm),

        // Description
        Text(
          AppStrings.deleteAccountDesc,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.xl),

        // Reason input
        SekkaInputField(
          controller: reasonCtrl,
          label: AppStrings.deleteReason,
          prefixIcon: IconsaxPlusLinear.message,
          maxLines: 2,
        ),

        // Inline error
        if (errorMessage != null) ...[
          SizedBox(height: AppSizes.sm),
          Text(
            errorMessage!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.sm),
        ] else
          SizedBox(height: AppSizes.xl),

        // Send OTP button
        SekkaButton(
          label: AppStrings.deleteAccountSendOtp,
          onPressed: isLoading ? null : onSendOtp,
          isLoading: isLoading,
          type: SekkaButtonType.primary,
          backgroundColor: AppColors.error,
        ),
        SizedBox(height: AppSizes.md),

        // Cancel
        SekkaButton(
          label: AppStrings.cancel,
          onPressed: isLoading ? null : onCancel,
          type: SekkaButtonType.text,
        ),
      ],
    ),
    );
  }
}

class _OtpPhase extends StatelessWidget {
  const _OtpPhase({
    super.key,
    required this.otpKey,
    required this.isLoading,
    required this.onOtpChanged,
    required this.onConfirm,
    required this.onBack,
    required this.isDark,
    this.errorMessage,
  });

  final GlobalKey<OtpInputBoxState> otpKey;
  final bool isLoading;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onConfirm;
  final VoidCallback onBack;
  final bool isDark;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: Responsive.w(40),
          height: Responsive.h(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.borderDark : AppColors.border,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
        ),
        SizedBox(height: AppSizes.xxl),

        // Lock icon
        Container(
          width: Responsive.r(64),
          height: Responsive.r(64),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            IconsaxPlusLinear.lock,
            color: AppColors.error,
            size: Responsive.r(28),
          ),
        ),
        SizedBox(height: AppSizes.lg),

        // Title
        Text(
          AppStrings.deleteAccountOtpTitle,
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.sm),

        // Subtitle
        Text(
          AppStrings.deleteAccountOtpSent,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textBodyDark : AppColors.textBody,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSizes.xxxl),

        // 4-digit OTP
        OtpInputBox(
          key: otpKey,
          length: 4,
          hasError: errorMessage != null,
          onCompleted: onOtpChanged,
        ),

        // Inline error
        if (errorMessage != null) ...[
          SizedBox(height: AppSizes.sm),
          Text(
            errorMessage!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: AppSizes.xxl),

        // Confirm button
        SekkaButton(
          label: AppStrings.deleteAccountConfirm,
          onPressed: isLoading ? null : onConfirm,
          isLoading: isLoading,
          type: SekkaButtonType.primary,
          backgroundColor: AppColors.error,
        ),
        SizedBox(height: AppSizes.md),

        // Back
        SekkaButton(
          label: AppStrings.back,
          onPressed: isLoading ? null : onBack,
          type: SekkaButtonType.text,
        ),
      ],
    ),
    );
  }
}
