import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

class SekkaBackButton extends StatelessWidget {
  const SekkaBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: AppSizes.iconMd,
      ),
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}
