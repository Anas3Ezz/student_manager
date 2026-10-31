import '../../../../core/result/api_result.dart';
import '../entities/subject_entity.dart';
import '../repos/subjects_repository.dart';

class WatchStudentSubjectsUseCase {
  final SubjectsRepository _repository;
  WatchStudentSubjectsUseCase(this._repository);

  Stream<ApiResult<List<SubjectEntity>>> call(int studentId) =>
      _repository.watchStudentSubjects(studentId);
}
