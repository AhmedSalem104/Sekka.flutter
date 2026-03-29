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
    final page = json['pageNumber'] as int? ?? json['page'] as int? ?? 1;
    final size = json['pageSize'] as int? ?? 10;
    final total = json['totalCount'] as int? ?? 0;
    final pages = json['totalPages'] as int? ?? 0;

    return PaginatedResponse<T>(
      items: (json['items'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      pageNumber: page,
      pageSize: size,
      totalCount: total,
      totalPages: pages,
      hasNextPage: json['hasNextPage'] as bool? ?? (page < pages),
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? (page > 1),
    );
  }
}
