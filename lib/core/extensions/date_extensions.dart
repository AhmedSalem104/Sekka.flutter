extension DateExtensions on DateTime {
  /// Returns Arabic greeting based on time of day
  String get arabicGreeting {
    if (hour >= 5 && hour < 12) return 'صباح الخير';
    if (hour >= 12 && hour < 18) return 'مساء الخير';
    if (hour >= 18 && hour < 22) return 'مساء الخير';
    return 'أهلا بيك'; // late night
  }

  /// Returns formatted Arabic date: "الأحد 2 مارس"
  String get arabicDate {
    const days = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد',
    ];
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${days[weekday - 1]} $day ${months[month - 1]}';
  }

  /// Returns formatted time: "8:30 ص"
  String get arabicTime {
    final h = hour > 12 ? hour - 12 : hour;
    final period = hour >= 12 ? 'م' : 'ص';
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
