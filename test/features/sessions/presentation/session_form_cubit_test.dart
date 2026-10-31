import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/sessions/domain/entities/session_entity.dart';
import 'package:teacher_system/features/sessions/domain/entities/session_input.dart';
import 'package:teacher_system/features/sessions/domain/usecases/add_session_usecase.dart';
import 'package:teacher_system/features/sessions/domain/usecases/get_default_session_subject_usecase.dart';
import 'package:teacher_system/features/sessions/domain/usecases/get_today_usecase.dart';
import 'package:teacher_system/features/sessions/domain/usecases/update_session_usecase.dart';
import 'package:teacher_system/features/sessions/presentation/bloc/session_form_cubit.dart';
import 'package:teacher_system/features/sessions/presentation/bloc/session_form_state.dart';
import 'package:teacher_system/features/subjects/domain/entities/subject_entity.dart';
import 'package:teacher_system/features/subjects/domain/usecases/add_subject_usecase.dart';
import 'package:teacher_system/features/subjects/domain/usecases/assign_subject_usecase.dart';
import 'package:teacher_system/features/subjects/domain/usecases/get_student_subjects_usecase.dart';

import '../../../helpers/fakes.dart';

class _MockGetSubjects extends Mock implements GetStudentSubjectsUseCase {}

class _MockGetDefault extends Mock implements GetDefaultSessionSubjectUseCase {}

class _MockAdd extends Mock implements AddSessionUseCase {}

class _MockUpdate extends Mock implements UpdateSessionUseCase {}

class _MockAssignSubject extends Mock implements AssignSubjectUseCase {}

class _MockAddSubject extends Mock implements AddSubjectUseCase {}

void main() {
  late _MockGetSubjects getSubjects;
  late _MockGetDefault getDefault;
  late _MockAdd addSession;
  late _MockUpdate updateSession;
  late _MockAssignSubject assignSubject;
  late _MockAddSubject addSubject;
  final today = DateTime(2026, 10, 31);
  final getToday = GetTodayUseCase(FixedClock(today));

  const math = SubjectEntity(id: 1, name: 'Math');
  const science = SubjectEntity(id: 2, name: 'Science');

  setUpAll(
    () => registerFallbackValue(
      SessionInput(studentId: 0, subjectId: 0, date: DateTime(2000), rating: 1),
    ),
  );

  setUp(() {
    getSubjects = _MockGetSubjects();
    getDefault = _MockGetDefault();
    addSession = _MockAdd();
    updateSession = _MockUpdate();
    assignSubject = _MockAssignSubject();
    addSubject = _MockAddSubject();
    when(() => getSubjects(10))
        .thenAnswer((_) async => const ApiResult.success([math, science]));
    when(
      () => getDefault(
        studentId: any(named: 'studentId'),
        assignedSubjectIds: any(named: 'assignedSubjectIds'),
      ),
    ).thenAnswer((_) async => const ApiResult.success(2));
  });

  SessionFormCubit build() => SessionFormCubit(
    getSubjects,
    getDefault,
    getToday,
    addSession,
    updateSession,
    assignSubject,
    addSubject,
  );

  /// The student starts with no subjects; [math] is assigned afterwards.
  void stubNoSubjectsThenMath() {
    var assigned = false;
    when(
      () => getSubjects(10),
    ).thenAnswer((_) async => ApiResult.success(assigned ? [math] : const []));
    when(() => assignSubject(studentId: 10, subjectId: any(named: 'subjectId')))
        .thenAnswer((_) async {
          assigned = true;
          return const ApiResult.success(null);
        });
  }

  blocTest<SessionFormCubit, SessionFormState>(
    'load preselects the default subject and today',
    build: build,
    act: (cubit) => cubit.load(studentId: 10),
    expect: () => [
      isA<SessionFormReady>()
          .having((s) => s.subjects, 'subjects', [math, science])
          .having((s) => s.initialSubjectId, 'subject', 2)
          .having((s) => s.initialDate, 'date', today),
    ],
  );

  blocTest<SessionFormCubit, SessionFormState>(
    'editing keeps a subject that is no longer assigned',
    build: build,
    act: (cubit) => cubit.load(
      studentId: 10,
      editing: SessionEntity(
        id: 5,
        studentId: 10,
        studentName: 'Omar',
        subjectId: 3,
        subjectName: 'Art',
        date: DateTime(2026, 10, 2),
        rating: 3,
      ),
    ),
    expect: () => [
      isA<SessionFormReady>()
          .having((s) => s.subjects.map((x) => x.id), 'ids', [1, 2, 3])
          .having((s) => s.initialSubjectId, 'subject', 3)
          .having((s) => s.initialDate, 'date', DateTime(2026, 10, 2)),
    ],
  );

  blocTest<SessionFormCubit, SessionFormState>(
    'save emits saving then saved on success',
    setUp: () =>
        when(() => addSession(any()))
            .thenAnswer((_) async => const ApiResult.success(1)),
    build: build,
    act: (cubit) async {
      await cubit.load(studentId: 10);
      await cubit.save(subjectId: 1, date: today, rating: 5);
    },
    skip: 1,
    expect: () => [
      isA<SessionFormReady>().having((s) => s.isSaving, 'isSaving', true),
      isA<SessionFormSaved>(),
    ],
  );

  blocTest<SessionFormCubit, SessionFormState>(
    'save exposes the failure and stops saving on error',
    setUp: () => when(() => addSession(any())).thenAnswer(
      (_) async => const ApiResult.failure(
        ValidationFailure(ValidationReason.futureDate),
      ),
    ),
    build: build,
    act: (cubit) async {
      await cubit.load(studentId: 10);
      await cubit.save(subjectId: 1, date: today, rating: 5);
    },
    skip: 2,
    expect: () => [
      isA<SessionFormReady>()
          .having((s) => s.isSaving, 'isSaving', false)
          .having(
            (s) => s.saveFailure,
            'failure',
            const ValidationFailure(ValidationReason.futureDate),
          ),
    ],
  );

  blocTest<SessionFormCubit, SessionFormState>(
    'load emits a load error when subjects cannot be read',
    setUp: () => when(() => getSubjects(10))
        .thenAnswer((_) async => const ApiResult.failure(DatabaseFailure('x'))),
    build: build,
    act: (cubit) => cubit.load(studentId: 10),
    expect: () => [isA<SessionFormLoadError>()],
  );

  blocTest<SessionFormCubit, SessionFormState>(
    'assignSubject assigns it and reloads the form with it',
    setUp: stubNoSubjectsThenMath,
    build: build,
    act: (cubit) async {
      await cubit.load(studentId: 10);
      await cubit.assignSubject(1);
    },
    expect: () => [
      isA<SessionFormReady>().having((s) => s.subjects, 'subjects', isEmpty),
      isA<SessionFormReady>().having((s) => s.isSaving, 'isSaving', true),
      isA<SessionFormLoading>(),
      isA<SessionFormReady>().having((s) => s.subjects, 'subjects', [math]),
    ],
    verify: (_) =>
        verify(() => assignSubject(studentId: 10, subjectId: 1)).called(1),
  );

  blocTest<SessionFormCubit, SessionFormState>(
    'assignSubject exposes the failure and stays on the prompt',
    setUp: () {
      when(() => getSubjects(10))
          .thenAnswer((_) async => const ApiResult.success([]));
      when(
        () => assignSubject(studentId: 10, subjectId: 1),
      ).thenAnswer((_) async => const ApiResult.failure(DatabaseFailure('x')));
    },
    build: build,
    act: (cubit) async {
      await cubit.load(studentId: 10);
      await cubit.assignSubject(1);
    },
    skip: 2,
    expect: () => [
      isA<SessionFormReady>()
          .having((s) => s.subjects, 'subjects', isEmpty)
          .having((s) => s.isSaving, 'isSaving', false)
          .having((s) => s.saveFailure, 'failure', const DatabaseFailure('x')),
    ],
  );

  blocTest<SessionFormCubit, SessionFormState>(
    'createAndAssignSubject creates the subject then assigns it',
    setUp: () {
      stubNoSubjectsThenMath();
      when(() => addSubject(name: 'Math', colorValue: 7))
          .thenAnswer((_) async => const ApiResult.success(1));
    },
    build: build,
    act: (cubit) async {
      await cubit.load(studentId: 10);
      await cubit.createAndAssignSubject(name: 'Math', colorValue: 7);
    },
    skip: 3,
    expect: () => [
      isA<SessionFormReady>().having((s) => s.subjects, 'subjects', [math]),
    ],
    verify: (_) =>
        verify(() => assignSubject(studentId: 10, subjectId: 1)).called(1),
  );

  blocTest<SessionFormCubit, SessionFormState>(
    'createAndAssignSubject skips assigning when creation fails',
    setUp: () {
      when(() => getSubjects(10))
          .thenAnswer((_) async => const ApiResult.success([]));
      when(
        () => addSubject(name: '', colorValue: 7),
      ).thenAnswer((_) async => const ApiResult.failure(DatabaseFailure('x')));
    },
    build: build,
    act: (cubit) async {
      await cubit.load(studentId: 10);
      await cubit.createAndAssignSubject(name: '', colorValue: 7);
    },
    skip: 2,
    expect: () => [
      isA<SessionFormReady>().having(
        (s) => s.saveFailure,
        'failure',
        const DatabaseFailure('x'),
      ),
    ],
    verify: (_) => verifyNever(
      () => assignSubject(
        studentId: any(named: 'studentId'),
        subjectId: any(named: 'subjectId'),
      ),
    ),
  );

  blocTest<SessionFormCubit, SessionFormState>(
    'createAndAssignSubject shows the failure when assigning fails',
    setUp: () {
      when(() => getSubjects(10))
          .thenAnswer((_) async => const ApiResult.success([]));
      when(() => addSubject(name: 'Math', colorValue: 7))
          .thenAnswer((_) async => const ApiResult.success(1));
      when(
        () => assignSubject(studentId: 10, subjectId: 1),
      ).thenAnswer((_) async => const ApiResult.failure(DatabaseFailure('x')));
    },
    build: build,
    act: (cubit) async {
      await cubit.load(studentId: 10);
      await cubit.createAndAssignSubject(name: 'Math', colorValue: 7);
    },
    skip: 2,
    expect: () => [
      isA<SessionFormReady>()
          .having((s) => s.isSaving, 'isSaving', false)
          .having((s) => s.saveFailure, 'failure', const DatabaseFailure('x')),
    ],
  );
}
