import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../theme/app_typography.dart';

/// Utility for phone actions — call, WhatsApp, copy.
/// Reusable across partners, emergency contacts, orders, customers.
abstract final class PhoneLauncher {
  /// Opens the phone dialer with the given number.
  static Future<void> call(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Opens the device's messaging app chooser (SMS / WhatsApp / etc).
  static Future<void> messagingApps(String phoneNumber) async {
    var normalized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized.startsWith('0')) {
      normalized = '+2$normalized';
    } else if (!normalized.startsWith('+')) {
      normalized = '+$normalized';
    }
    final uri = Uri(scheme: 'sms', path: normalized);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Opens WhatsApp chat with the given number.
  static Future<void> whatsApp(String phoneNumber, {String? message}) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    // Ensure number has country code for wa.me
    String phone = cleaned;
    if (phone.startsWith('01')) {
      phone = '20${phone.substring(1)}'; // 01x -> 201x
    } else if (phone.startsWith('+')) {
      phone = phone.substring(1); // remove +
    }

    final url = message != null
        ? 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}'
        : 'https://wa.me/$phone';
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Copies phone number to clipboard and shows feedback.
  static void copy(BuildContext context, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.phoneCopied,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows a bottom sheet with call, WhatsApp, and copy options.
  static void showOptions(
    BuildContext context,
    String phoneNumber, {
    String? contactName,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (contactName != null) ...[
                Text(
                  contactName,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    phoneNumber,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.lg),
              ],
              _OptionTile(
                icon: IconsaxPlusLinear.call,
                label: AppStrings.callNow,
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(ctx);
                  call(phoneNumber);
                },
              ),
              _OptionTile(
                icon: IconsaxPlusLinear.message,
                label: AppStrings.sendWhatsApp,
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(ctx);
                  whatsApp(phoneNumber);
                },
              ),
              _OptionTile(
                icon: IconsaxPlusLinear.copy,
                label: AppStrings.copyNumber,
                color: isDark ? AppColors.textBodyDark : AppColors.textBody,
                onTap: () {
                  Navigator.pop(ctx);
                  copy(context, phoneNumber);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: AppSizes.iconLg),
      title: Text(label, style: AppTypography.bodyMedium),
      onTap: onTap,
    );
  }
}
