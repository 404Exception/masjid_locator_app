import 'package:flutter/material.dart';

class TimeUtils {
  /// Parse a "HH:mm" string into a [TimeOfDay]
  static TimeOfDay parseTime(String time) {
    final parts = time.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Format a [TimeOfDay] into "h:mm AM/PM"
  static String formatTimeForDisplay(TimeOfDay time) {
    final hour = time.hourOfPeriod; // 1–12
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Convenience: parse from string and return formatted display
  static String formatFromString(String time) {
    return formatTimeForDisplay(parseTime(time));
  }
}
