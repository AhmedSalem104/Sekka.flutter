import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/network/api_constants.dart';
import '../../../../core/widgets/sekka_avatar.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  int? _selectedVehicleType;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _nameController = TextEditingController(text: state.profile.name);
      _emailController = TextEditingController(text: state.profile.email ?? '');
      _selectedVehicleType = state.profile.vehicleType;
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.editProfile, style: AppTypography.headlineSmall),
        leading: const SekkaBackButton(),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && !state.isUpdating) {
            context.showSnackBar(AppStrings.profileUpdated);
          }
          if (state is ProfileError) {
            SekkaMessageDialog.show(context, message: state.message);
          }
        },
        builder: (context, state) {
          final isUpdating =
              state is ProfileLoaded && state.isUpdating;
          final profile =
              state is ProfileLoaded ? state.profile : null;

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
            children: [
              SizedBox(height: AppSizes.xxl),

              // Avatar upload
              Center(
                child: SekkaAvatar(
                  imageUrl: profile?.profileImageUrl,
                  size: 100,
                  showCameraOverlay: true,
                  onTap: () => _showImagePicker(context, isProfile: true),
                ),
              ),
              SizedBox(height: AppSizes.sm),
              Center(
                child: TextButton(
                  onPressed: profile?.profileImageUrl != null
                      ? () => context
                          .read<ProfileBloc>()
                          .add(const ProfileImageDeleteRequested())
                      : null,
                  child: Text(
                    profile?.profileImageUrl != null
                        ? AppStrings.removePhoto
                        : AppStrings.uploadPhoto,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.xxl),

              // Name
              SekkaInputField(
                controller: _nameController,
                label: AppStrings.driverName,
                prefixIcon: IconsaxPlusLinear.user,
              ),
              SizedBox(height: AppSizes.lg),

              // Email
              SekkaInputField(
                controller: _emailController,
                label: AppStrings.emailOptional,
                prefixIcon: IconsaxPlusLinear.sms,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: AppSizes.lg),

              // Vehicle type
              Text(
                AppStrings.vehicleType,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textHeadlineDark
                      : AppColors.textHeadline,
                ),
              ),
              SizedBox(height: AppSizes.sm),
              _VehicleTypeSelector(
                selected: _selectedVehicleType ?? 0,
                isDark: isDark,
                onChanged: (val) => setState(() => _selectedVehicleType = val),
              ),
              SizedBox(height: AppSizes.xxl),

              // License image
              _LicenseUploadTile(
                licenseUrl: profile?.licenseImageUrl,
                isDark: isDark,
                onUpload: () => _showImagePicker(context, isProfile: false),
              ),
              SizedBox(height: AppSizes.xxxl),

              // Save button
              SekkaButton(
                label: AppStrings.save,
                isLoading: isUpdating,
                onPressed: isUpdating ? null : _onSave,
              ),
              SizedBox(height: AppSizes.xxxl),
            ],
          );
        },
      ),
    );
  }

  void _onSave() {
    final updates = <String, dynamic>{};
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isNotEmpty) updates['name'] = name;
    if (email.isNotEmpty) updates['email'] = email;
    if (_selectedVehicleType != null) {
      updates['vehicleType'] = _selectedVehicleType;
    }

    if (updates.isNotEmpty) {
      context.read<ProfileBloc>().add(ProfileUpdateRequested(updates));
    }
  }

  Future<void> _showImagePicker(
    BuildContext context, {
    required bool isProfile,
  }) async {
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
              title: const Text('الكاميرا'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(IconsaxPlusLinear.gallery, color: AppColors.primary),
              title: const Text('المعرض'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picked = await _picker.pickImage(source: source, maxWidth: 800);
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    if (isProfile) {
      context.read<ProfileBloc>().add(ProfileImageUploadRequested(file));
    } else {
      context.read<ProfileBloc>().add(LicenseImageUploadRequested(file));
    }
  }
}

class _VehicleTypeSelector extends StatelessWidget {
  const _VehicleTypeSelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  final int selected;
  final bool isDark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final types = AppStrings.vehicleTypesArabic.entries.toList();

    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: List.generate(types.length, (i) {
        final isActive = selected == i;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.md,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : isDark
                      ? AppColors.surfaceDark
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isActive
                    ? AppColors.primary
                    : isDark
                        ? AppColors.borderDark
                        : AppColors.border,
              ),
            ),
            child: Text(
              types[i].value,
              style: AppTypography.bodySmall.copyWith(
                color: isActive
                    ? AppColors.textOnPrimary
                    : isDark
                        ? AppColors.textBodyDark
                        : AppColors.textBody,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LicenseUploadTile extends StatelessWidget {
  const _LicenseUploadTile({
    required this.licenseUrl,
    required this.isDark,
    required this.onUpload,
  });

  final String? licenseUrl;
  final bool isDark;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUpload,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.xl),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            style: licenseUrl == null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            if (licenseUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Image.network(
                  licenseUrl!.startsWith('http')
                      ? licenseUrl!
                      : '${ApiConstants.baseUrl.replaceAll('/api/v1', '')}$licenseUrl',
                  height: Responsive.h(150),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                ),
              ),
              SizedBox(height: AppSizes.sm),
              Text(
                AppStrings.changePhoto,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ] else
              _buildPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      children: [
        Icon(
          IconsaxPlusLinear.document_upload,
          size: Responsive.r(40),
          color: AppColors.primary,
        ),
        SizedBox(height: AppSizes.sm),
        Text(
          AppStrings.uploadLicense,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
