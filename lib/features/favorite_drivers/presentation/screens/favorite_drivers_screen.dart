import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../core/widgets/sekka_message_dialog.dart';
import '../../data/models/favorite_driver_model.dart';
import '../bloc/favorite_drivers_bloc.dart';
import '../bloc/favorite_drivers_event.dart';
import '../bloc/favorite_drivers_state.dart';

class FavoriteDriversScreen extends StatelessWidget {
  const FavoriteDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: SekkaAppBar(
        title: AppStrings.favoriteDriversTitle,
        actions: [
          IconButton(
            icon: Icon(
              IconsaxPlusLinear.user_add,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: BlocConsumer<FavoriteDriversBloc, FavoriteDriversState>(
        listenWhen: (prev, curr) =>
            curr is FavoriteDriverActionSuccess ||
            curr is FavoriteDriversError,
        listener: (context, state) {
          if (state is FavoriteDriverActionSuccess) {
            SekkaMessageDialog.show(context, message: state.message);
          } else if (state is FavoriteDriversError) {
            SekkaMessageDialog.show(context, message: state.message);
          }
        },
        buildWhen: (prev, curr) =>
            curr is FavoriteDriversLoading ||
            curr is FavoriteDriversLoaded ||
            curr is FavoriteDriversError,
        builder: (context, state) => switch (state) {
          FavoriteDriversLoading() ||
          FavoriteDriversInitial() =>
            const SekkaShimmerList(itemCount: 5),
          FavoriteDriversLoaded(:final drivers) when drivers.isEmpty =>
            SekkaEmptyState(
              icon: IconsaxPlusLinear.people,
              title: AppStrings.favoriteDriversEmpty,
              description: AppStrings.favoriteDriversEmptyDesc,
              actionLabel: AppStrings.addFavoriteDriver,
              onAction: () => _showAddSheet(context),
            ),
          FavoriteDriversLoaded(:final drivers) =>
            _FavoritesList(drivers: drivers),
          FavoriteDriversError(:final message) => SekkaEmptyState(
              icon: IconsaxPlusLinear.warning_2,
              title: message,
              actionLabel: AppStrings.retry,
              onAction: () => context
                  .read<FavoriteDriversBloc>()
                  .add(const FavoriteDriversLoadRequested()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final bloc = context.read<FavoriteDriversBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.r(24)),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: _AddFavoriteSheet(),
        ),
      ),
    );
  }
}

// ── Favorites List ──────────────────────────────────────────────────────

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.drivers});
  final List<FavoriteDriverModel> drivers;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => context
          .read<FavoriteDriversBloc>()
          .add(const FavoriteDriversLoadRequested()),
      child: ListView.separated(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        itemCount: drivers.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSizes.sm),
        itemBuilder: (context, index) =>
            _FavoriteDriverTile(driver: drivers[index]),
      ),
    );
  }
}

// ── Single Driver Tile ──────────────────────────────────────────────────

class _FavoriteDriverTile extends StatelessWidget {
  const _FavoriteDriverTile({required this.driver});
  final FavoriteDriverModel driver;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(driver.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: AppSizes.xl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Icon(
          IconsaxPlusLinear.trash,
          color: AppColors.error,
          size: AppSizes.iconMd,
        ),
      ),
      confirmDismiss: (_) => _confirmRemove(context),
      onDismissed: (_) => context
          .read<FavoriteDriversBloc>()
          .add(FavoriteDriverRemoved(driver.id)),
      child: SekkaCard(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        padding: EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            // Avatar
            Container(
              width: Responsive.r(44),
              height: Responsive.r(44),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusBold.user,
                color: AppColors.primary,
                size: Responsive.r(20),
              ),
            ),
            SizedBox(width: AppSizes.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.textHeadlineDark
                          : AppColors.textHeadline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Responsive.h(2)),
                  Text(
                    driver.phone,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textCaption,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(10),
                vertical: Responsive.h(4),
              ),
              decoration: BoxDecoration(
                color: driver.isAppUser
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.textCaption.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                driver.isAppUser
                    ? AppStrings.onApp
                    : AppStrings.notOnApp,
                style: AppTypography.captionSmall.copyWith(
                  color: driver.isAppUser
                      ? AppColors.success
                      : AppColors.textCaption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmRemove(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Text(
            AppStrings.removeFavoriteConfirm,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textHeadlineDark
                  : AppColors.textHeadline,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                AppStrings.cancel,
                style: AppTypography.button.copyWith(
                  color: AppColors.textCaption,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                AppStrings.remove,
                style: AppTypography.button.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Favorite Sheet ──────────────────────────────────────────────────

class _AddFavoriteSheet extends StatefulWidget {
  const _AddFavoriteSheet();

  @override
  State<_AddFavoriteSheet> createState() => _AddFavoriteSheetState();
}

class _AddFavoriteSheetState extends State<_AddFavoriteSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.lg,
        AppSizes.pagePadding,
        MediaQuery.of(context).viewInsets.bottom + AppSizes.xxl,
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: Responsive.w(40),
                height: Responsive.h(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(Responsive.r(2)),
                ),
              ),
            ),
            SizedBox(height: AppSizes.lg),
            Text(
              AppStrings.addFavoriteDriver,
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textHeadlineDark
                    : AppColors.textHeadline,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.xl),

            SekkaInputField(
              controller: _nameCtrl,
              label: AppStrings.colleagueName,
              prefixIcon: IconsaxPlusLinear.user,
              errorText: _nameError,
            ),
            SizedBox(height: AppSizes.md),

            SekkaInputField(
              controller: _phoneCtrl,
              label: AppStrings.colleaguePhone,
              prefixIcon: IconsaxPlusLinear.call,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.left,
              errorText: _phoneError,
            ),
            SizedBox(height: AppSizes.xl),

            BlocListener<FavoriteDriversBloc, FavoriteDriversState>(
              listenWhen: (prev, curr) =>
                  curr is FavoriteDriverActionSuccess,
              listener: (context, state) {
                if (state is FavoriteDriverActionSuccess) {
                  Navigator.pop(context);
                }
              },
              child: SekkaButton(
                label: AppStrings.addFavoriteDriver,
                onPressed: _submit,
              ),
            ),
            SizedBox(height: AppSizes.md),
          ],
        ),
    );
  }

  void _submit() {
    String? nameErr;
    String? phoneErr;

    if (_nameCtrl.text.trim().isEmpty) {
      nameErr = AppStrings.isRequired;
    }

    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      phoneErr = AppStrings.isRequired;
    } else {
      final cleaned = phone.replaceAll(RegExp(r'\D'), '');
      if (cleaned.length < 11) phoneErr = AppStrings.phoneHintEgyptian;
    }

    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
    });

    if (nameErr != null || phoneErr != null) return;

    context.read<FavoriteDriversBloc>().add(
          FavoriteDriverAdded(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
          ),
        );
  }
}
