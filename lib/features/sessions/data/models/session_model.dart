import '../../../../core/database/app_database.dart';
import '../../../../core/database/db_dates.dart';
import '../../domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.subjectId,
    required super.subjectName,
    super.subjectColorValue,
    required super.date,
    required super.rating,
    super.notes,
  });

  factory SessionModel.fromRows({
    required SessionRow session,
    required StudentRow student,
    required SubjectRow subject,
  }) => SessionModel(
    id: session.id,
    studentId: student.id,
    studentName: student.name,
    subjectId: subject.id,
    subjectName: subject.name,
    subjectColorValue: subject.colorValue,
    date: DbDates.fromDb(session.date),
    rating: session.rating,
    notes: session.notes,
  );
}
