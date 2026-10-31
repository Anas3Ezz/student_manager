import '../../../../core/database/app_database.dart';
import '../../domain/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.name,
    super.phone,
    super.notes,
    required super.createdAt,
  });

  factory StudentModel.fromRow(StudentRow row) => StudentModel(
    id: row.id,
    name: row.name,
    phone: row.phone,
    notes: row.notes,
    createdAt: row.createdAt,
  );
}
