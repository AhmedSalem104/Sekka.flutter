import '../../../../shared/utils/safe_parse.dart';

class CallerIdModel {
  const CallerIdModel({
    required this.phoneNumber,
    this.displayName,
    required this.contactType,
    this.customerName,
    this.partnerName,
    this.lastOrderDate,
    this.averageRating,
    this.note,
    required this.isBlocked,
  });

  final String phoneNumber;
  final String? displayName;
  final int contactType;
  final String? customerName;
  final String? partnerName;
  final DateTime? lastOrderDate;
  final double? averageRating;
  final String? note;
  final bool isBlocked;

  factory CallerIdModel.fromJson(Map<String, dynamic> json) {
    return CallerIdModel(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      displayName: json['displayName'] as String?,
      contactType: safeInt(json['contactType'], 0),
      customerName: json['customerName'] as String?,
      partnerName: json['partnerName'] as String?,
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.tryParse(json['lastOrderDate'] as String)
          : null,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      note: json['note'] as String?,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        if (displayName != null) 'displayName': displayName,
        'contactType': contactType,
        if (customerName != null) 'customerName': customerName,
        if (partnerName != null) 'partnerName': partnerName,
        if (lastOrderDate != null)
          'lastOrderDate': lastOrderDate!.toIso8601String(),
        if (averageRating != null) 'averageRating': averageRating,
        if (note != null) 'note': note,
        'isBlocked': isBlocked,
      };
}
