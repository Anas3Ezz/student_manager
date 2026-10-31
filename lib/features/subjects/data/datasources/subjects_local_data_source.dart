import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../models/subject_model.dart';

class SubjectsLocalDataSource {
  final AppDatabase _db;
  SubjectsLocalDataSource(this._db);

  Stream<List<SubjectModel>> watchSubjects() {
    final query = _db.select(_db.subjects)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch().map(_toModels);
  }

  Future<int> addSubject({required String name, int? colorValue}) => _db
      .into(_db.subjects)
      .insert(
        SubjectsCompanion.insert(name: name, colorValue: Value(colorValue)),
      );

  Future<void> updateSubject({
    required int id,
    required String name,
    int? colorValue,
  }) async {
    final updated =
        await (_db.update(_db.subjects)..where((t) => t.id.equals(id))).write(
          SubjectsCompanion(name: Value(name), colorValue: Value(colorValue)),
        );
    if (updated == 0) throw const NotFoundException();
  }

  /// Also deletes the subject's sessions and student links (cascade).
  Future<void> deleteSubject(int id) =>
      (_db.delete(_db.subjects)..where((t) => t.id.equals(id))).go();

  Stream<List<SubjectModel>> watchStudentSubjects(int studentId) =>
      _studentSubjectsQuery(studentId).watch().map(_joinedToModels);

  Future<List<SubjectModel>> getStudentSubjects(int studentId) async =>
      _joinedToModels(await _studentSubjectsQuery(studentId).get());

  Future<void> assignSubject({
    required int studentId,
    required int subjectId,
  }) => _db
      .into(_db.studentSubjects)
      .insert(
        StudentSubjectsCompanion.insert(
          studentId: studentId,
          subjectId: subjectId,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> unassignSubject({
    required int studentId,
    required int subjectId,
  }) =>
      (_db.delete(_db.studentSubjects)..where(
            (t) =>
                t.studentId.equals(studentId) & t.subjectId.equals(subjectId),
          ))
          .go();

  JoinedSelectStatement _studentSubjectsQuery(int studentId) {
    final links = _db.studentSubjects;
    return _db.select(_db.subjects).join([
        innerJoin(links, links.subjectId.equalsExp(_db.subjects.id)),
      ])
      ..where(links.studentId.equals(studentId))
      ..orderBy([OrderingTerm.asc(_db.subjects.name)]);
  }

  List<SubjectModel> _toModels(List<SubjectRow> rows) =>
      rows.map(SubjectModel.fromRow).toList();

  List<SubjectModel> _joinedToModels(List<TypedResult> rows) =>
      rows.map((r) => SubjectModel.fromRow(r.readTable(_db.subjects))).toList();
}
