class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<T> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) fromJsonT,
  }) {
    return PaginatedResponse<T>(
      items: (json['items'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalCount: json['totalCount'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }
}
