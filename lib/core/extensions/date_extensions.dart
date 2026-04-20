import '../constants/app_strings.dart';

extension DateExtensions on DateTime {
  /// Returns locale-aware greeting based on time of day
  String get arabicGreeting {
    if (hour >= 5 && hour < 12) return AppStrings.greetingMorning;
    if (hour >= 12 && hour < 22) return AppStrings.greetingEvening;
    return AppStrings.greetingNight; // late night
  }

  /// Returns formatted locale-aware date: "الأحد 2 مارس" / "Sunday 2 March"
  String get arabicDate {
    final days = AppStrings.dayNames;
    final months = AppStrings.monthNames;
    return '${days[weekday - 1]} $day ${months[month - 1]}';
  }

  /// Returns formatted time: "8:30 ص" / "8:30 AM"
  String get arabicTime {
    final h = hour > 12 ? hour - 12 : hour;
    final period = hour >= 12 ? AppStrings.pmPeriod : AppStrings.amPeriod;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
