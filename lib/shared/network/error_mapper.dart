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
        return 'كلمة السر لازم تكون فيها حروف كبيرة وصغيرة وأرقام';
      }
      if (lower.contains('غير متطابقة') || lower.contains('mismatch')) {
        return AppStrings.passwordMismatch;
      }
      if (lower.contains('غير صحيحة') || lower.contains('incorrect')) {
        return 'رقم الموبايل أو كلمة السر غلط';
      }
    }

    // Phone errors
    if (lower.contains('غير صالح') || lower.contains('invalid phone')) {
      return AppStrings.phoneInvalid;
    }
    if (lower.contains('مسجل بالفعل') || lower.contains('already registered')) {
      return 'الرقم ده مسجّل قبل كدا، جرّب تسجّل دخول';
    }

    // OTP errors
    if (lower.contains('كود التحقق غير صحيح') ||
        lower.contains('كود التأكيد غير صحيح') ||
        lower.contains('invalid otp') ||
        lower.contains('invalid confirmation') ||
        lower.contains('invalid code')) {
      return 'الكود غلط، تأكد منه وجرّب تاني';
    }
    if (lower.contains('منتهي الصلاحية') || lower.contains('expired')) {
      return 'الكود خلص وقته، ابعت كود جديد';
    }
    if (lower.contains('تم تجاوز') || lower.contains('too many')) {
      return 'جرّبت كتير، استنى شوية وحاول تاني';
    }

    // Account errors
    if (lower.contains('موقوف') || lower.contains('suspended')) {
      return 'الحساب متوقف، تواصل مع الدعم';
    }
    if (lower.contains('غير موجود') || lower.contains('not found')) {
      return 'مفيش حساب بالرقم ده';
    }

    // Token errors
    if (lower.contains('توكن') || lower.contains('token')) {
      return AppStrings.sessionExpired;
    }

    // Session errors
    if (lower.contains('الجلسة غير موجودة')) {
      return 'الجلسة دي مش موجودة';
    }

    // SMS errors
    if (lower.contains('فشل إرسال') || lower.contains('sms')) {
      return 'مقدرناش نبعت الرسالة، جرّب تاني';
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
