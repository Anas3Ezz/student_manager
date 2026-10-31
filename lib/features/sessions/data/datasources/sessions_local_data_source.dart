import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/db_dates.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/session_input.dart';
import '../models/session_model.dart';

class SessionsLocalDataSource {
  final AppDatabase _db;
  SessionsLocalDataSource(this._db);

  Stream<List<SessionModel>> watchStudentSessions({
    required int studentId,
    required DateTime from,
    required DateTime to,
    int? subjectId,
  }) {
    final s = _db.sessions;
    var filter =
        s.studentId.equals(studentId) &
        s.date.isBiggerOrEqualValue(DbDates.toDb(from)) &
        s.date.isSmallerThanValue(DbDates.toDb(to));
    if (subjectId != null) filter = filter & s.subjectId.equals(subjectId);
    return (_joinedQuery()..where(filter)).watch().map(_toModels);
  }

  Stream<List<SessionModel>> watchRecentSubjectSessions({
    required int subjectId,
    required int limit,
  }) =>
      (_joinedQuery()
            ..where(_db.sessions.subjectId.equals(subjectId))
            ..limit(limit))
          .watch()
          .map(_toModels);

  Future<int?> getLastUsedSubjectId(int studentId) async {
    final query = _db.select(_db.sessions)
      ..where((t) => t.studentId.equals(studentId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.date),
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(1);
    return (await query.getSingleOrNull())?.subjectId;
  }

  Future<int> addSession(SessionInput input) => _db
      .into(_db.sessions)
      .insert(
        SessionsCompanion.insert(
          studentId: input.studentId,
          subjectId: input.subjectId,
          date: DbDates.toDb(input.date),
          rating: input.rating,
          notes: Value(input.notes),
        ),
      );

  Future<void> updateSession(int id, SessionInput input) async {
    final updated =
        await (_db.update(_db.sessions)..where((t) => t.id.equals(id))).write(
          SessionsCompanion(
            subjectId: Value(input.subjectId),
            date: Value(DbDates.toDb(input.date)),
            rating: Value(input.rating),
            notes: Value(input.notes),
          ),
        );
    if (updated == 0) throw const NotFoundException();
  }

  Future<void> deleteSession(int id) =>
      (_db.delete(_db.sessions)..where((t) => t.id.equals(id))).go();

  /// Sessions joined with their student and subject, newest first.
  JoinedSelectStatement _joinedQuery() {
    final s = _db.sessions;
    return _db.select(s).join([
      innerJoin(_db.students, _db.students.id.equalsExp(s.studentId)),
      innerJoin(_db.subjects, _db.subjects.id.equalsExp(s.subjectId)),
    ])..orderBy([
      OrderingTerm.desc(s.date),
      OrderingTerm.desc(s.createdAt),
      OrderingTerm.desc(s.id),
    ]);
  }

  List<SessionModel> _toModels(List<TypedResult> rows) => rows
      .map(
        (r) => SessionModel.fromRows(
          session: r.readTable(_db.sessions),
          student: r.readTable(_db.students),
          subject: r.readTable(_db.subjects),
        ),
      )
      .toList();
}
