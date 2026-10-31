import 'failures.dart';

/// Translation key for a user-facing failure message.
extension FailureMessage on Failure {
  String get messageKey => switch (this) {
    DatabaseFailure() => 'errors.database',
    NotFoundFailure() => 'errors.not_found',
    ValidationFailure(reason: ValidationReason.emptyName) =>
      'errors.empty_name',
    ValidationFailure(reason: ValidationReason.nameTooLong) =>
      'errors.name_too_long',
    ValidationFailure(reason: ValidationReason.invalidRating) =>
      'errors.invalid_rating',
    ValidationFailure(reason: ValidationReason.futureDate) =>
      'errors.future_date',
  };
}
