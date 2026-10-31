/// Session dates are calendar days, not instants. They are stored as UTC
/// midnight so a device timezone change can never shift them to another day.
abstract final class DbDates {
  static DateTime toDb(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  static DateTime fromDb(DateTime stored) {
    final utc = stored.toUtc();
    return DateTime(utc.year, utc.month, utc.day);
  }
}
