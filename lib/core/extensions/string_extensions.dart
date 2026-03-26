extension StringExtensions on String {
  /// Converts Arabic/Hindi numerals (٠١٢٣٤٥٦٧٨٩) to English (0123456789)
  String get toEnglishNumbers {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var result = this;
    for (var i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }

  /// Converts English numerals to Arabic/Hindi numerals
  String get toArabicNumbers {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var result = this;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  /// Check if string is a valid Egyptian phone number
  bool get isValidEgyptianPhone {
    final cleaned = toEnglishNumbers.replaceAll(RegExp(r'[\s\-\+]'), '');
    return RegExp(r'^(01[0125]\d{8}|201[0125]\d{8}|\+201[0125]\d{8})$')
        .hasMatch(cleaned);
  }

  /// Formats phone number to standard format: 01xxxxxxxxx
  String get normalizePhone {
    final cleaned = toEnglishNumbers.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleaned.startsWith('201')) return '0${cleaned.substring(2)}';
    if (cleaned.startsWith('+201')) return '0${cleaned.substring(3)}';
    return cleaned;
  }
}
