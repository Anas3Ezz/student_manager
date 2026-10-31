import '../error/failures.dart';

abstract final class Validators {
  static const int maxNameLength = 100;
  static const int minRating = 1;
  static const int maxRating = 5;

  static ValidationFailure? name(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const ValidationFailure(ValidationReason.emptyName);
    }
    if (trimmed.length > maxNameLength) {
      return const ValidationFailure(ValidationReason.nameTooLong);
    }
    return null;
  }

  static ValidationFailure? rating(int value) =>
      value < minRating || value > maxRating
      ? const ValidationFailure(ValidationReason.invalidRating)
      : null;

  /// Fails when [date]'s day is after [today]'s day.
  static ValidationFailure? notInFuture(DateTime date, DateTime today) {
    final day = DateTime(date.year, date.month, date.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return day.isAfter(todayDay)
        ? const ValidationFailure(ValidationReason.futureDate)
        : null;
  }

  /// Returns trimmed text, or null when blank.
  static String? optionalText(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
