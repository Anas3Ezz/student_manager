import '../../../../core/result/api_result.dart';
import '../repos/subjects_repository.dart';

class AssignSubjectUseCase {
  final SubjectsRepository _repository;
  AssignSubjectUseCase(this._repository);

  Future<ApiResult<void>> call({
    required int studentId,
    required int subjectId,
  }) => _repository.assignSubject(studentId: studentId, subjectId: subjectId);
}
