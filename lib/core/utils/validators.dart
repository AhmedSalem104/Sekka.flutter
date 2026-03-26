import '../extensions/string_extensions.dart';

/// Centralized validation for all user inputs.
abstract final class Validators {
  /// Validates Egyptian phone number (01xxxxxxxxx)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل رقم الموبايل';
    }
    if (!value.isValidEgyptianPhone) {
      return 'رقم موبايل غير صحيح';
    }
    return null;
  }

  /// Validates OTP code (6 digits)
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل كود التحقق';
    }
    final cleaned = value.toEnglishNumbers.trim();
    if (cleaned.length != 6 || !RegExp(r'^\d{6}$').hasMatch(cleaned)) {
      return 'الكود لازم يكون 6 أرقام';
    }
    return null;
  }

  /// Validates required text field
  static String? required(String? value, [String fieldName = 'هذا الحقل']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// Validates name (at least 2 characters)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل الاسم';
    }
    if (value.trim().length < 2) {
      return 'الاسم لازم يكون حرفين على الأقل';
    }
    return null;
  }

  /// Validates amount (positive number)
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل المبلغ';
    }
    final cleaned = value.toEnglishNumbers.trim();
    final number = double.tryParse(cleaned);
    if (number == null || number <= 0) {
      return 'أدخل مبلغ صحيح';
    }
    return null;
  }

  /// Validates address (at least 5 characters)
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل العنوان';
    }
    if (value.trim().length < 5) {
      return 'العنوان قصير جداً';
    }
    return null;
  }
}
