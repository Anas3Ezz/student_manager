import 'exceptions.dart';
import 'failures.dart';

/// Maps exceptions caught at the data boundary to typed [Failure]s.
abstract final class FailureMapper {
  static Failure map(Object error) => switch (error) {
    Failure failure => failure,
    NotFoundException() => const NotFoundFailure(),
    _ => DatabaseFailure(error.toString()),
  };
}
