import '../../../../core/result/api_result.dart';
import '../repos/students_repository.dart';

/// Deletes the student together with their sessions and subject links.
class DeleteStudentUseCase {
  final StudentsRepository _repository;
  DeleteStudentUseCase(this._repository);

  Future<ApiResult<void>> call(int id) => _repository.deleteStudent(id);
}
