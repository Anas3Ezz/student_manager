import '../../../../core/result/api_result.dart';
import '../repos/subjects_repository.dart';

/// Removes the link only; past sessions for that subject are kept.
class UnassignSubjectUseCase {
  final SubjectsRepository _repository;
  UnassignSubjectUseCase(this._repository);

  Future<ApiResult<void>> call({
    required int studentId,
    required int subjectId,
  }) => _repository.unassignSubject(studentId: studentId, subjectId: subjectId);
}
