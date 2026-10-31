import 'dart:async';

import 'package:flutter/foundation.dart';

import '../error/failure_mapper.dart';
import 'api_result.dart';

/// Runs [action] at the data boundary, mapping any thrown error to a failure.
Future<ApiResult<T>> guardResult<T>(Future<T> Function() action) async {
  try {
    return ApiResult.success(await action());
  } catch (error, stackTrace) {
    _logError(error, stackTrace);
    return ApiResult.failure(FailureMapper.map(error));
  }
}

extension ResultStream<T> on Stream<T> {
  /// Wraps each event in [ApiResult], turning stream errors into failures.
  Stream<ApiResult<T>> asResult() => transform(
    StreamTransformer<T, ApiResult<T>>.fromHandlers(
      handleData: (data, sink) => sink.add(ApiResult.success(data)),
      handleError: (error, stackTrace, sink) {
        _logError(error, stackTrace);
        sink.add(ApiResult.failure(FailureMapper.map(error)));
      },
    ),
  );
}

/// Debug builds only; release builds never log data errors.
void _logError(Object error, StackTrace stackTrace) {
  if (kDebugMode) debugPrint('Data error: $error\n$stackTrace');
}
