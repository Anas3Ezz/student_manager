import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/sessions/domain/repos/sessions_repository.dart';
import 'package:teacher_system/features/sessions/domain/usecases/get_default_session_subject_usecase.dart';

class _MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late _MockSessionsRepository repository;
  late GetDefaultSessionSubjectUseCase useCase;

  setUp(() {
    repository = _MockSessionsRepository();
    useCase = GetDefaultSessionSubjectUseCase(repository);
  });

  void lastUsed(ApiResult<int?> result) =>
      when(() => repository.getLastUsedSubjectId(1))
          .thenAnswer((_) async => result);

  test('returns null when the student has no subjects', () async {
    final result = await useCase(studentId: 1, assignedSubjectIds: []);

    expect(result, const ApiSuccess<int?>(null));
  });

  test('returns the only subject without querying history', () async {
    final result = await useCase(studentId: 1, assignedSubjectIds: [5]);

    expect(result, const ApiSuccess<int?>(5));
    verifyNever(() => repository.getLastUsedSubjectId(any()));
  });

  test('returns the last used subject when it is still assigned', () async {
    lastUsed(const ApiResult.success(6));

    final result = await useCase(studentId: 1, assignedSubjectIds: [5, 6]);

    expect(result, const ApiSuccess<int?>(6));
  });

  test(
    'returns null when the last used subject is no longer assigned',
    () async {
      lastUsed(const ApiResult.success(9));

      final result = await useCase(studentId: 1, assignedSubjectIds: [5, 6]);

      expect(result, const ApiSuccess<int?>(null));
    },
  );

  test('passes repository failures through', () async {
    lastUsed(const ApiResult.failure(DatabaseFailure('boom')));

    final result = await useCase(studentId: 1, assignedSubjectIds: [5, 6]);

    expect(result, const ApiFailure<int?>(DatabaseFailure('boom')));
  });
}
