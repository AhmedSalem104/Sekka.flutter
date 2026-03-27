/// Represents the result of an API call.
///
/// Usage:
/// ```dart
/// final result = await repository.getOrders();
/// switch (result) {
///   case ApiSuccess(:final data):
///     // handle data
///   case ApiFailure(:final error):
///     // handle error
/// }
/// ```
sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error);
  final ApiError error;
}

/// Structured API error.
class ApiError {
  const ApiError({
    required this.message,
    this.statusCode,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? errors;

  /// User-friendly Arabic message based on status code.
  String get arabicMessage => switch (statusCode) {
        400 => 'البيانات غير صحيحة',
        401 => 'يرجى تسجيل الدخول مرة أخرى',
        403 => 'غير مسموح بهذا الإجراء',
        404 => 'غير موجود',
        408 => 'انتهت المهلة — جرّب تاني',
        422 => message,
        429 => 'طلبات كتير — استنى شوية',
        500 => 'حصلت مشكلة — جرّب تاني',
        502 || 503 => 'السيرفر مش متاح دلوقتي',
        _ => 'حصلت مشكلة — جرّب تاني',
      };

  @override
  String toString() => 'ApiError($statusCode: $message)';
}
