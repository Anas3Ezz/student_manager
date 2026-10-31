import '../../../../core/result/api_result.dart';
import '../entities/subject_entity.dart';
import '../repos/subjects_repository.dart';

class GetStudentSubjectsUseCase {
  final SubjectsRepository _repository;
  GetStudentSubjectsUseCase(this._repository);

  Future<ApiResult<List<SubjectEntity>>> call(int studentId) =>
      _repository.getStudentSubjects(studentId);
}
