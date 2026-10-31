import '../../../../core/result/api_result.dart';
import '../entities/student_entity.dart';

abstract class StudentsRepository {
  /// Students ordered by name, filtered by [query] when not blank.
  Stream<ApiResult<List<StudentEntity>>> watchStudents({String query = ''});
  Stream<ApiResult<StudentEntity>> watchStudent(int id);
  Stream<ApiResult<List<StudentEntity>>> watchStudentsBySubject(int subjectId);
  Future<ApiResult<int>> addStudent({
    required String name,
    String? phone,
    String? notes,
  });
  Future<ApiResult<void>> updateStudent({
    required int id,
    required String name,
    String? phone,
    String? notes,
  });
  Future<ApiResult<void>> deleteStudent(int id);
}
