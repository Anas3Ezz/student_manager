import '../../../../core/result/api_result.dart';
import '../entities/subject_entity.dart';

abstract class SubjectsRepository {
  Stream<ApiResult<List<SubjectEntity>>> watchSubjects();
  Future<ApiResult<int>> addSubject({required String name, int? colorValue});
  Future<ApiResult<void>> updateSubject(SubjectEntity subject);
  Future<ApiResult<void>> deleteSubject(int id);

  Stream<ApiResult<List<SubjectEntity>>> watchStudentSubjects(int studentId);
  Future<ApiResult<List<SubjectEntity>>> getStudentSubjects(int studentId);
  Future<ApiResult<void>> assignSubject({
    required int studentId,
    required int subjectId,
  });
  Future<ApiResult<void>> unassignSubject({
    required int studentId,
    required int subjectId,
  });
}
