import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_system/core/database/app_database.dart';
import 'package:teacher_system/features/sessions/data/datasources/sessions_local_data_source.dart';
import 'package:teacher_system/features/sessions/domain/entities/session_input.dart';
import 'package:teacher_system/features/students/data/datasources/students_local_data_source.dart';
import 'package:teacher_system/features/subjects/data/datasources/subjects_local_data_source.dart';
import 'package:teacher_system/features/subjects/data/repos/subjects_repository_impl.dart';
import 'package:teacher_system/features/subjects/domain/entities/subject_entity.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late SubjectsRepositoryImpl repository;
  late int studentId;

  setUp(() async {
    db = createTestDatabase();
    repository = SubjectsRepositoryImpl(SubjectsLocalDataSource(db));
    studentId = await StudentsLocalDataSource(db).addStudent(name: 'Omar');
  });

  tearDown(() => db.close());

  Future<int> addSubject(String name) async =>
      successData<int>(await repository.addSubject(name: name));

  test('assignSubject links the subject to the student', () async {
    final math = await addSubject('Math');
    await addSubject('Science');

    await repository.assignSubject(studentId: studentId, subjectId: math);

    final result = await repository.getStudentSubjects(studentId);
    expect(successData<List<SubjectEntity>>(result).map((s) => s.name), [
      'Math',
    ]);
  });

  test('assigning the same subject twice keeps a single link', () async {
    final math = await addSubject('Math');

    await repository.assignSubject(studentId: studentId, subjectId: math);
    await repository.assignSubject(studentId: studentId, subjectId: math);

    expect(await db.select(db.studentSubjects).get(), hasLength(1));
  });

  test('unassignSubject removes the link but keeps past sessions', () async {
    final math = await addSubject('Math');
    await repository.assignSubject(studentId: studentId, subjectId: math);
    await SessionsLocalDataSource(db).addSession(
      SessionInput(
        studentId: studentId,
        subjectId: math,
        date: DateTime(2026, 10, 1),
        rating: 3,
      ),
    );

    await repository.unassignSubject(studentId: studentId, subjectId: math);

    expect(
      successData<List>(await repository.getStudentSubjects(studentId)),
      isEmpty,
    );
    expect(await db.select(db.sessions).get(), hasLength(1));
  });

  test('deleteSubject cascades to its sessions', () async {
    final math = await addSubject('Math');
    await SessionsLocalDataSource(db).addSession(
      SessionInput(
        studentId: studentId,
        subjectId: math,
        date: DateTime(2026, 10, 1),
        rating: 3,
      ),
    );

    await repository.deleteSubject(math);

    expect(await db.select(db.sessions).get(), isEmpty);
  });

  test('updateSubject changes name and color', () async {
    final math = await addSubject('Math');

    await repository.updateSubject(
      SubjectEntity(id: math, name: 'Mathematics', colorValue: 0xFF000000),
    );

    final result = await repository.watchSubjects().first;
    expect(
      successData<List<SubjectEntity>>(result).single,
      SubjectEntity(id: math, name: 'Mathematics', colorValue: 0xFF000000),
    );
  });
}
