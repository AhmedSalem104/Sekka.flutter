import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';

class SekkaInputField extends StatelessWidget {
  const SekkaInputField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextAlign textAlign;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.titleMedium),
          SizedBox(height: AppSizes.sm),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          readOnly: readOnly,
          onTap: onTap,
          textAlign: textAlign,
          textDirection: TextDirection.rtl,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            // constrain error text so it doesn't overflow
            errorMaxLines: 2,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: AppSizes.iconLg)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, size: AppSizes.iconLg),
                    onPressed: onSuffixTap,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
