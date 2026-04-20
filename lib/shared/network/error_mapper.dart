import '../../core/constants/app_strings.dart';

/// Maps raw API/server error messages to user-friendly Arabic messages.
/// Technical details stay in logs, users see friendly text only.
abstract final class ErrorMapper {
  /// Converts any error message to a user-friendly Arabic message.
  static String toUserMessage(String rawMessage) {
    final lower = rawMessage.toLowerCase();

    // Password errors
    if (lower.contains('password') ||
        lower.contains('كلمة المرور') ||
        lower.contains('كلمة السر')) {
      if (lower.contains('lowercase') ||
          lower.contains('uppercase') ||
          lower.contains('digit') ||
          lower.contains('must have')) {
        return AppStrings.passwordComplexity;
      }
      if (lower.contains('غير متطابقة') || lower.contains('mismatch')) {
        return AppStrings.passwordMismatch;
      }
      if (lower.contains('غير صحيحة') || lower.contains('incorrect')) {
        return AppStrings.wrongCredentials;
      }
    }

    // Phone errors
    if (lower.contains('غير صالح') || lower.contains('invalid phone')) {
      return AppStrings.phoneInvalid;
    }
    if (lower.contains('مسجل بالفعل') || lower.contains('already registered')) {
      return AppStrings.phoneAlreadyRegistered;
    }

    // OTP errors
    if (lower.contains('كود التحقق غير صحيح') ||
        lower.contains('كود التأكيد غير صحيح') ||
        lower.contains('invalid otp') ||
        lower.contains('invalid confirmation') ||
        lower.contains('invalid code')) {
      return AppStrings.wrongOtpCode;
    }
    if (lower.contains('منتهي الصلاحية') || lower.contains('expired')) {
      return AppStrings.otpExpired;
    }
    if (lower.contains('تم تجاوز') || lower.contains('too many')) {
      return AppStrings.tooManyAttempts;
    }

    // Account errors
    if (lower.contains('موقوف') || lower.contains('suspended')) {
      return AppStrings.accountSuspended;
    }
    if (lower.contains('غير موجود') || lower.contains('not found')) {
      return AppStrings.accountNotFound;
    }

    // Token errors
    if (lower.contains('توكن') || lower.contains('token')) {
      return AppStrings.sessionExpired;
    }

    // Session errors
    if (lower.contains('الجلسة غير موجودة')) {
      return AppStrings.sessionNotFound;
    }

    // SMS errors
    if (lower.contains('فشل إرسال') || lower.contains('sms')) {
      return AppStrings.smsSendFailed;
    }

    // If message contains English characters, it's likely technical
    if (RegExp(r'[a-zA-Z]{3,}').hasMatch(rawMessage)) {
      return AppStrings.unknownError;
    }

    // If it's already Arabic and short enough, show it as-is
    if (rawMessage.length <= 80) {
      return rawMessage;
    }

    return AppStrings.unknownError;
  }
}
