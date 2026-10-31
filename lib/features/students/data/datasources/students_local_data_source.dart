import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../models/student_model.dart';

class StudentsLocalDataSource {
  final AppDatabase _db;
  StudentsLocalDataSource(this._db);

  Stream<List<StudentModel>> watchStudents({String query = ''}) {
    final select = _db.select(_db.students)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (query.isNotEmpty) {
      // Escape LIKE wildcards so `%` and `_` typed by the user match literally.
      final escaped = query.replaceAllMapped(
        RegExp(r'[\\%_]'),
        (m) => '\\${m[0]}',
      );
      select.where((t) => t.name.like('%$escaped%', escapeChar: '\\'));
    }
    return select.watch().map(
      (rows) => rows.map(StudentModel.fromRow).toList(),
    );
  }

  Stream<StudentModel> watchStudent(int id) =>
      (_db.select(
        _db.students,
      )..where((t) => t.id.equals(id))).watchSingleOrNull().map((row) {
        if (row == null) throw const NotFoundException();
        return StudentModel.fromRow(row);
      });

  Stream<List<StudentModel>> watchStudentsBySubject(int subjectId) {
    final links = _db.studentSubjects;
    final query =
        _db.select(_db.students).join([
            innerJoin(links, links.studentId.equalsExp(_db.students.id)),
          ])
          ..where(links.subjectId.equals(subjectId))
          ..orderBy([OrderingTerm.asc(_db.students.name)]);
    return query.watch().map(
      (rows) => rows
          .map((r) => StudentModel.fromRow(r.readTable(_db.students)))
          .toList(),
    );
  }

  Future<int> addStudent({
    required String name,
    String? phone,
    String? notes,
  }) => _db
      .into(_db.students)
      .insert(
        StudentsCompanion.insert(
          name: name,
          phone: Value(phone),
          notes: Value(notes),
        ),
      );

  Future<void> updateStudent({
    required int id,
    required String name,
    String? phone,
    String? notes,
  }) async {
    final updated =
        await (_db.update(_db.students)..where((t) => t.id.equals(id))).write(
          StudentsCompanion(
            name: Value(name),
            phone: Value(phone),
            notes: Value(notes),
          ),
        );
    if (updated == 0) throw const NotFoundException();
  }

  Future<void> deleteStudent(int id) =>
      (_db.delete(_db.students)..where((t) => t.id.equals(id))).go();
}
