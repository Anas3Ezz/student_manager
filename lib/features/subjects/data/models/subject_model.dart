import '../../../../core/database/app_database.dart';
import '../../domain/entities/subject_entity.dart';

class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.name,
    super.colorValue,
  });

  factory SubjectModel.fromRow(SubjectRow row) =>
      SubjectModel(id: row.id, name: row.name, colorValue: row.colorValue);
}
