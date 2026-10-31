import '../error/failures.dart';

sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(Failure failure) = ApiFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => switch (this) {
    ApiSuccess(:final data) => success(data),
    ApiFailure(failure: final error) => failure(error),
  };
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);

  @override
  bool operator ==(Object other) =>
      other is ApiSuccess<T> && other.data == data;

  @override
  int get hashCode => data.hashCode;
}

final class ApiFailure<T> extends ApiResult<T> {
  final Failure failure;
  const ApiFailure(this.failure);

  @override
  bool operator ==(Object other) =>
      other is ApiFailure<T> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}

extension ApiResultX<T> on ApiResult<T> {
  /// The failure, or null on success. Handy for fire-and-forget actions.
  Failure? get failureOrNull => switch (this) {
    ApiSuccess() => null,
    ApiFailure(:final failure) => failure,
  };
}
