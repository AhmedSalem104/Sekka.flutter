import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Unified AppBar for all Sekka screens.
///
/// Handles dark mode colors, consistent styling, and back navigation
/// automatically. Use this instead of raw `AppBar` in screens.
class SekkaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SekkaAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.onBack,
    this.bottom,
  });

  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: showBack
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: AppSizes.iconMd,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      automaticallyImplyLeading: false,
      actions: actions,
      bottom: bottom,
    );
  }
}
