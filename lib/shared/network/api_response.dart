/// Paged data wrapper: { items, totalCount, pageNumber, pageSize, totalPages }
class PagedData<T> {
  const PagedData({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory PagedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    return PagedData<T>(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['pageNumber'] as int? ?? json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }
}

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
