import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_system/core/database/app_database.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/sessions/data/datasources/sessions_local_data_source.dart';
import 'package:teacher_system/features/sessions/domain/entities/session_input.dart';
import 'package:teacher_system/features/students/data/datasources/students_local_data_source.dart';
import 'package:teacher_system/features/students/data/repos/students_repository_impl.dart';
import 'package:teacher_system/features/subjects/data/datasources/subjects_local_data_source.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late StudentsRepositoryImpl repository;
  late SubjectsLocalDataSource subjects;
  late SessionsLocalDataSource sessions;

  setUp(() {
    db = createTestDatabase();
    repository = StudentsRepositoryImpl(StudentsLocalDataSource(db));
    subjects = SubjectsLocalDataSource(db);
    sessions = SessionsLocalDataSource(db);
  });

  tearDown(() => db.close());

  Future<int> addStudent(String name) async =>
      successData<int>(await repository.addStudent(name: name));

  test(
    'addStudent then watchStudents returns students ordered by name',
    () async {
      await addStudent('Omar');
      await addStudent('Ahmed');

      final result = await repository.watchStudents().first;

      final names = successData<List>(result).map((s) => s.name).toList();
      expect(names, ['Ahmed', 'Omar']);
    },
  );

  test('watchStudents filters by query', () async {
    await addStudent('Omar');
    await addStudent('Sara');

    final result = await repository.watchStudents(query: 'sa').first;

    final names = successData<List>(result).map((s) => s.name).toList();
    expect(names, ['Sara']);
  });

  test(
    'watchStudents treats % and _ in the query as plain characters',
    () async {
      await addStudent('Omar');
      await addStudent('Sara_Ali');

      final underscore = await repository.watchStudents(query: '_').first;
      final percent = await repository.watchStudents(query: '%').first;

      expect(successData(underscore).map((s) => s.name), ['Sara_Ali']);
      expect(successData(percent), isEmpty);
    },
  );

  test('updateStudent changes stored fields', () async {
    final id = await addStudent('Omar');

    await repository.updateStudent(id: id, name: 'Omar Ali', phone: '0100');

    final student = successData<dynamic>(
      await repository.watchStudent(id).first,
    );
    expect(student.name, 'Omar Ali');
    expect(student.phone, '0100');
  });

  test('updateStudent on a missing id returns NotFoundFailure', () async {
    final result = await repository.updateStudent(id: 999, name: 'Ghost');

    expect(result, const ApiFailure<void>(NotFoundFailure()));
  });

  test('watchStudent on a missing id emits NotFoundFailure', () async {
    final result = await repository.watchStudent(999).first;

    expect(result, isA<ApiFailure>());
    expect((result as ApiFailure).failure, const NotFoundFailure());
  });

  test('deleteStudent cascades to sessions and subject links', () async {
    final studentId = await addStudent('Omar');
    final subjectId = await subjects.addSubject(name: 'Math');
    await subjects.assignSubject(studentId: studentId, subjectId: subjectId);
    await sessions.addSession(
      SessionInput(
        studentId: studentId,
        subjectId: subjectId,
        date: DateTime(2026, 10, 1),
        rating: 4,
      ),
    );

    await repository.deleteStudent(studentId);

    expect(await db.select(db.sessions).get(), isEmpty);
    expect(await db.select(db.studentSubjects).get(), isEmpty);
  });

  test('watchStudentsBySubject returns only assigned students', () async {
    final omar = await addStudent('Omar');
    await addStudent('Sara');
    final math = await subjects.addSubject(name: 'Math');
    await subjects.assignSubject(studentId: omar, subjectId: math);

    final result = await repository.watchStudentsBySubject(math).first;

    final names = successData<List>(result).map((s) => s.name).toList();
    expect(names, ['Omar']);
  });
}
