import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/students/domain/entities/student_entity.dart';
import 'package:teacher_system/features/students/domain/usecases/delete_student_usecase.dart';
import 'package:teacher_system/features/students/domain/usecases/watch_student_usecase.dart';
import 'package:teacher_system/features/students/presentation/bloc/student_details_cubit.dart';
import 'package:teacher_system/features/students/presentation/bloc/student_details_state.dart';

class _MockWatch extends Mock implements WatchStudentUseCase {}

class _MockDelete extends Mock implements DeleteStudentUseCase {}

void main() {
  late _MockWatch watchStudent;
  late _MockDelete deleteStudent;
  final student = StudentEntity(id: 1, name: 'Omar', createdAt: DateTime(2026));

  setUp(() {
    watchStudent = _MockWatch();
    deleteStudent = _MockDelete();
    when(() => watchStudent(1))
        .thenAnswer((_) => Stream.value(ApiResult.success(student)));
  });

  blocTest<StudentDetailsCubit, StudentDetailsState>(
    'watch emits the loaded student',
    build: () => StudentDetailsCubit(watchStudent, deleteStudent),
    act: (cubit) => cubit.watch(1),
    expect: () => [
      isA<StudentDetailsLoaded>().having((s) => s.student, 'student', student),
    ],
  );

  blocTest<StudentDetailsCubit, StudentDetailsState>(
    'a failed delete returns the failure and resumes watching',
    setUp: () => when(() => deleteStudent(1)).thenAnswer(
      (_) async => const ApiResult.failure(DatabaseFailure('locked')),
    ),
    build: () => StudentDetailsCubit(watchStudent, deleteStudent),
    act: (cubit) async {
      cubit.watch(1);
      await Future<void>.delayed(Duration.zero);
      final failure = await cubit.delete();
      expect(failure, const DatabaseFailure('locked'));
      await Future<void>.delayed(Duration.zero);
    },
    // Loaded once on watch, then again after re-subscribing.
    expect: () => [isA<StudentDetailsLoaded>(), isA<StudentDetailsLoaded>()],
    verify: (_) => verify(() => watchStudent(1)).called(2),
  );
}
