/// Result from OCR scan-invoice endpoint.
class OcrResultModel {
  const OcrResultModel({
    this.customerName,
    this.customerPhone,
    this.address,
    this.amount,
    this.description,
    this.items = const [],
    this.confidence,
    this.rawText,
  });

  final String? customerName;
  final String? customerPhone;
  final String? address;
  final double? amount;
  final String? description;
  final List<OcrItemModel> items;
  final double? confidence;
  final String? rawText;

  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    return OcrResultModel(
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      address: json['address'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OcrItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      confidence: (json['confidence'] as num?)?.toDouble(),
      rawText: json['rawText'] as String?,
    );
  }
}

/// Single item extracted from an invoice.
class OcrItemModel {
  const OcrItemModel({
    this.name,
    this.quantity,
    this.price,
  });

  final String? name;
  final int? quantity;
  final double? price;

  factory OcrItemModel.fromJson(Map<String, dynamic> json) {
    return OcrItemModel(
      name: json['name'] as String?,
      quantity: json['quantity'] as int?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }
}

/// Result from OCR scan-batch endpoint — a list of scanned invoices.
class OcrBatchResultModel {
  const OcrBatchResultModel({
    this.results = const [],
    this.totalScanned = 0,
    this.successCount = 0,
    this.failedCount = 0,
  });

  final List<OcrResultModel> results;
  final int totalScanned;
  final int successCount;
  final int failedCount;

  factory OcrBatchResultModel.fromJson(Map<String, dynamic> json) {
    return OcrBatchResultModel(
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => OcrResultModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalScanned: json['totalScanned'] as int? ?? 0,
      successCount: json['successCount'] as int? ?? 0,
      failedCount: json['failedCount'] as int? ?? 0,
    );
  }
}
