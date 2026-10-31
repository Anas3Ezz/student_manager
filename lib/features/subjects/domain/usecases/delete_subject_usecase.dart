import '../../../../core/result/api_result.dart';
import '../repos/subjects_repository.dart';

class DeleteSubjectUseCase {
  final SubjectsRepository _repository;
  DeleteSubjectUseCase(this._repository);

  Future<ApiResult<void>> call(int id) => _repository.deleteSubject(id);
}
