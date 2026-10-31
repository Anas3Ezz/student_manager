import '../../../../core/result/api_result.dart';
import '../entities/student_entity.dart';
import '../repos/students_repository.dart';

class WatchStudentsUseCase {
  final StudentsRepository _repository;
  WatchStudentsUseCase(this._repository);

  Stream<ApiResult<List<StudentEntity>>> call({String query = ''}) =>
      _repository.watchStudents(query: query.trim());
}
