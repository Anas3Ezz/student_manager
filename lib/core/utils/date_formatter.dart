import 'dart:ui';

import 'package:intl/intl.dart';

/// Locale-aware date strings used across the app.
abstract final class AppDateFormat {
  static String monthYear(DateTime date, Locale locale) =>
      DateFormat.yMMMM(locale.languageCode).format(date);

  static String fullDate(DateTime date, Locale locale) =>
      DateFormat.yMMMEd(locale.languageCode).format(date);

  static String dayNumber(DateTime date, Locale locale) =>
      DateFormat.d(locale.languageCode).format(date);

  static String weekdayShort(DateTime date, Locale locale) =>
      DateFormat.E(locale.languageCode).format(date);
}
