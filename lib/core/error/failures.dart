/// Typed failures returned across layers inside [ApiResult].
sealed class Failure {
  const Failure();
}

/// Unexpected storage error. [details] is for debugging only — never shown to the user.
final class DatabaseFailure extends Failure {
  final String details;
  const DatabaseFailure(this.details);

  @override
  bool operator ==(Object other) =>
      other is DatabaseFailure && other.details == details;

  @override
  int get hashCode => details.hashCode;
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure();

  @override
  bool operator ==(Object other) => other is NotFoundFailure;

  @override
  int get hashCode => (NotFoundFailure).hashCode;
}

enum ValidationReason { emptyName, nameTooLong, invalidRating, futureDate }

final class ValidationFailure extends Failure {
  final ValidationReason reason;
  const ValidationFailure(this.reason);

  @override
  bool operator ==(Object other) =>
      other is ValidationFailure && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;
}
