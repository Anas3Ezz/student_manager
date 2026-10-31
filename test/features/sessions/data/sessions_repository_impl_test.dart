import 'package:flutter_test/flutter_test.dart';
import 'package:teacher_system/core/database/app_database.dart';
import 'package:teacher_system/core/error/failures.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/sessions/data/datasources/sessions_local_data_source.dart';
import 'package:teacher_system/features/sessions/data/repos/sessions_repository_impl.dart';
import 'package:teacher_system/features/sessions/domain/entities/session_entity.dart';
import 'package:teacher_system/features/sessions/domain/entities/session_input.dart';
import 'package:teacher_system/features/students/data/datasources/students_local_data_source.dart';
import 'package:teacher_system/features/subjects/data/datasources/subjects_local_data_source.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late SessionsRepositoryImpl repository;
  late int studentId;
  late int math;
  late int science;

  setUp(() async {
    db = createTestDatabase();
    repository = SessionsRepositoryImpl(SessionsLocalDataSource(db));
    studentId = await StudentsLocalDataSource(db).addStudent(name: 'Omar');
    final subjects = SubjectsLocalDataSource(db);
    math = await subjects.addSubject(name: 'Math');
    science = await subjects.addSubject(name: 'Science');
  });

  tearDown(() => db.close());

  Future<void> addSession(DateTime date, {int? subjectId, int rating = 4}) =>
      repository.addSession(
        SessionInput(
          studentId: studentId,
          subjectId: subjectId ?? math,
          date: date,
          rating: rating,
        ),
      );

  Future<List<SessionEntity>> octoberSessions({int? subjectId}) async =>
      successData<List<SessionEntity>>(
        await repository
            .watchStudentSessions(
              studentId: studentId,
              from: DateTime(2026, 10),
              to: DateTime(2026, 11),
              subjectId: subjectId,
            )
            .first,
      );

  test('watchStudentSessions returns only sessions inside the month', () async {
    await addSession(DateTime(2026, 9, 30));
    await addSession(DateTime(2026, 10, 1));
    await addSession(DateTime(2026, 10, 31));
    await addSession(DateTime(2026, 11, 1));

    final sessions = await octoberSessions();

    expect(sessions.map((s) => s.date), [
      DateTime(2026, 10, 31),
      DateTime(2026, 10, 1),
    ]);
  });

  test('watchStudentSessions filters by subject', () async {
    await addSession(DateTime(2026, 10, 2), subjectId: math);
    await addSession(DateTime(2026, 10, 3), subjectId: science);

    final sessions = await octoberSessions(subjectId: science);

    expect(sessions.single.subjectName, 'Science');
  });

  test('sessions include joined student and subject names', () async {
    await addSession(DateTime(2026, 10, 2));

    final session = (await octoberSessions()).single;

    expect(session.studentName, 'Omar');
    expect(session.subjectName, 'Math');
  });

  test(
    'getLastUsedSubjectId returns the subject of the latest session',
    () async {
      await addSession(DateTime(2026, 10, 5), subjectId: science);
      await addSession(DateTime(2026, 10, 1), subjectId: math);

      final result = await repository.getLastUsedSubjectId(studentId);

      expect(result, ApiSuccess<int?>(science));
    },
  );

  test(
    'getLastUsedSubjectId returns null when there are no sessions',
    () async {
      final result = await repository.getLastUsedSubjectId(studentId);

      expect(result, const ApiSuccess<int?>(null));
    },
  );

  test('updateSession changes rating and notes', () async {
    final id = successData<int>(
      await repository.addSession(
        SessionInput(
          studentId: studentId,
          subjectId: math,
          date: DateTime(2026, 10, 2),
          rating: 2,
        ),
      ),
    );

    await repository.updateSession(
      id,
      SessionInput(
        studentId: studentId,
        subjectId: math,
        date: DateTime(2026, 10, 2),
        rating: 5,
        notes: 'Great',
      ),
    );

    final session = (await octoberSessions()).single;
    expect(session.rating, 5);
    expect(session.notes, 'Great');
  });

  test('a rating outside 1–5 is rejected by the database', () async {
    final result = await repository.addSession(
      SessionInput(
        studentId: studentId,
        subjectId: math,
        date: DateTime(2026, 10, 2),
        rating: 9,
      ),
    );

    expect((result as ApiFailure).failure, isA<DatabaseFailure>());
  });

  test('deleteSession removes the session', () async {
    final id = successData<int>(
      await repository.addSession(
        SessionInput(
          studentId: studentId,
          subjectId: math,
          date: DateTime(2026, 10, 2),
          rating: 3,
        ),
      ),
    );

    await repository.deleteSession(id);

    expect(await octoberSessions(), isEmpty);
  });
}
