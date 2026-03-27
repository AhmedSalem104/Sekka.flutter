class ApiResponse<T> {
  const ApiResponse({
    required this.isSuccess,
    this.data,
    this.message,
    this.errors,
  });

  final bool isSuccess;
  final T? data;
  final String? message;
  final dynamic errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJsonT,
  }) {
    return ApiResponse<T>(
      isSuccess: json['isSuccess'] as bool? ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      errors: json['errors'],
    );
  }
}
