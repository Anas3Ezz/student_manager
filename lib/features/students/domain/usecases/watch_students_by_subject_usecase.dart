import '../../../../core/result/api_result.dart';
import '../entities/student_entity.dart';
import '../repos/students_repository.dart';

class WatchStudentsBySubjectUseCase {
  final StudentsRepository _repository;
  WatchStudentsBySubjectUseCase(this._repository);

  Stream<ApiResult<List<StudentEntity>>> call(int subjectId) =>
      _repository.watchStudentsBySubject(subjectId);
}
