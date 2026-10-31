import '../../../../core/result/api_result.dart';
import '../entities/student_entity.dart';
import '../repos/students_repository.dart';

class WatchStudentUseCase {
  final StudentsRepository _repository;
  WatchStudentUseCase(this._repository);

  Stream<ApiResult<StudentEntity>> call(int id) => _repository.watchStudent(id);
}
