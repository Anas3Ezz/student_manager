import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/students/domain/repos/students_repository.dart';
import 'package:teacher_system/features/students/domain/usecases/add_student_usecase.dart';

class _MockStudentsRepository extends Mock implements StudentsRepository {}

void main() {
  late _MockStudentsRepository repository;
  late AddStudentUseCase useCase;

  setUp(() {
    repository = _MockStudentsRepository();
    useCase = AddStudentUseCase(repository);
    when(
      () => repository.addStudent(
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        notes: any(named: 'notes'),
      ),
    ).thenAnswer((_) async => const ApiResult.success(1));
  });

  test('rejects a blank name', () async {
    final result = await useCase(name: '   ');

    expect(
      result,
      const ApiFailure<int>(ValidationFailure(ValidationReason.emptyName)),
    );
  });

  test('rejects a name longer than 100 characters', () async {
    final result = await useCase(name: 'a' * 101);

    expect(
      result,
      const ApiFailure<int>(ValidationFailure(ValidationReason.nameTooLong)),
    );
  });

  test('trims the name and turns blank optional fields into null', () async {
    await useCase(name: '  Omar  ', phone: ' ', notes: '');

    verify(() => repository.addStudent(name: 'Omar', phone: null, notes: null))
        .called(1);
  });
}
