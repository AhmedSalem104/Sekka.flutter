import '../constants/app_strings.dart';
import '../extensions/string_extensions.dart';

/// Centralized validation for all user inputs.
abstract final class Validators {
  /// Validates Egyptian phone number (01xxxxxxxxx)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.phoneRequired;
    }
    if (!value.isValidEgyptianPhone) {
      return AppStrings.phoneInvalid;
    }
    return null;
  }

  /// Validates OTP code (4 digits)
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.otpRequired;
    }
    final cleaned = value.toEnglishNumbers.trim();
    if (cleaned.length != 4 || !RegExp(r'^\d{4}$').hasMatch(cleaned)) {
      return AppStrings.otpInvalid;
    }
    return null;
  }

  /// Validates password (minimum 6 characters)
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  /// Validates password confirmation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }
    if (value != password) {
      return AppStrings.passwordMismatch;
    }
    return null;
  }

  /// Validates email (optional — only validates format if provided)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
    if (!regex.hasMatch(value.trim())) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  /// Validates required text field
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? AppStrings.thisField} ${AppStrings.isRequired}';
    }
    return null;
  }

  /// Validates name (at least 2 characters)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    if (value.trim().length < 2) {
      return AppStrings.nameTooShort;
    }
    return null;
  }

  /// Validates amount (positive number)
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.enterAmount;
    }
    final cleaned = value.toEnglishNumbers.trim();
    final number = double.tryParse(cleaned);
    if (number == null || number <= 0) {
      return AppStrings.enterValidAmount;
    }
    return null;
  }

  /// Validates address (at least 5 characters)
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.enterAddressValidation;
    }
    if (value.trim().length < 5) {
      return AppStrings.addressTooShort;
    }
    return null;
  }
}
