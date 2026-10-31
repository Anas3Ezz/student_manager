import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_system/core/database/app_database.dart';
import 'package:teacher_system/core/result/api_result.dart';

AppDatabase createTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// Unwraps a successful result, failing the test otherwise.
T successData<T>(ApiResult<T> result) => switch (result) {
  ApiSuccess(:final data) => data,
  ApiFailure(:final failure) => throw TestFailure(
    'Expected success but got $failure',
  ),
};
