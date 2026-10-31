import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/subjects/domain/repos/subjects_repository.dart';
import 'package:teacher_system/features/subjects/domain/usecases/add_subject_usecase.dart';

class _MockSubjectsRepository extends Mock implements SubjectsRepository {}

void main() {
  late _MockSubjectsRepository repository;
  late AddSubjectUseCase useCase;

  setUp(() {
    repository = _MockSubjectsRepository();
    useCase = AddSubjectUseCase(repository);
    when(
      () => repository.addSubject(
        name: any(named: 'name'),
        colorValue: any(named: 'colorValue'),
      ),
    ).thenAnswer((_) async => const ApiResult.success(1));
  });

  test('rejects a blank name', () async {
    final result = await useCase(name: '');

    expect(
      result,
      const ApiFailure<int>(ValidationFailure(ValidationReason.emptyName)),
    );
    verifyNever(
      () => repository.addSubject(
        name: any(named: 'name'),
        colorValue: any(named: 'colorValue'),
      ),
    );
  });

  test('saves a trimmed name', () async {
    await useCase(name: ' Math ', colorValue: 1);

    verify(() => repository.addSubject(name: 'Math', colorValue: 1)).called(1);
  });
}
