import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/students/domain/usecases/add_student_usecase.dart';
import 'package:teacher_system/features/students/domain/usecases/update_student_usecase.dart';
import 'package:teacher_system/features/students/presentation/bloc/student_form_cubit.dart';
import 'package:teacher_system/features/students/presentation/bloc/student_form_state.dart';

class _MockAdd extends Mock implements AddStudentUseCase {}

class _MockUpdate extends Mock implements UpdateStudentUseCase {}

void main() {
  late _MockAdd addStudent;
  late _MockUpdate updateStudent;

  setUp(() {
    addStudent = _MockAdd();
    updateStudent = _MockUpdate();
  });

  void stubAdd(Future<ApiResult<int>> Function() answer) => when(
    () => addStudent(
      name: any(named: 'name'),
      phone: any(named: 'phone'),
      notes: any(named: 'notes'),
    ),
  ).thenAnswer((_) => answer());

  blocTest<StudentFormCubit, StudentFormState>(
    'save without id creates a student and reports its id',
    setUp: () => stubAdd(() async => const ApiResult.success(42)),
    build: () => StudentFormCubit(addStudent, updateStudent),
    act: (cubit) => cubit.save(name: 'Omar'),
    expect: () => [
      isA<StudentFormSaving>(),
      isA<StudentFormSaved>().having((s) => s.newStudentId, 'id', 42),
    ],
  );

  blocTest<StudentFormCubit, StudentFormState>(
    'save emits an error state on validation failure',
    setUp: () => stubAdd(
      () async => const ApiResult.failure(
        ValidationFailure(ValidationReason.emptyName),
      ),
    ),
    build: () => StudentFormCubit(addStudent, updateStudent),
    act: (cubit) => cubit.save(name: ''),
    expect: () => [isA<StudentFormSaving>(), isA<StudentFormError>()],
  );

  test('closing the cubit while saving does not throw', () async {
    final pending = Completer<ApiResult<int>>();
    stubAdd(() => pending.future);
    final cubit = StudentFormCubit(addStudent, updateStudent);

    final saving = cubit.save(name: 'Omar');
    await cubit.close();
    pending.complete(const ApiResult.success(1));

    await expectLater(saving, completes);
  });
}
