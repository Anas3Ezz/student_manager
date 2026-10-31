import '../../../../core/result/api_result.dart';
import '../../../../core/result/result_guards.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repos/students_repository.dart';
import '../datasources/students_local_data_source.dart';

class StudentsRepositoryImpl implements StudentsRepository {
  final StudentsLocalDataSource _dataSource;
  StudentsRepositoryImpl(this._dataSource);

  @override
  Stream<ApiResult<List<StudentEntity>>> watchStudents({String query = ''}) =>
      _dataSource.watchStudents(query: query).asResult();

  @override
  Stream<ApiResult<StudentEntity>> watchStudent(int id) =>
      _dataSource.watchStudent(id).asResult();

  @override
  Stream<ApiResult<List<StudentEntity>>> watchStudentsBySubject(
    int subjectId,
  ) => _dataSource.watchStudentsBySubject(subjectId).asResult();

  @override
  Future<ApiResult<int>> addStudent({
    required String name,
    String? phone,
    String? notes,
  }) => guardResult(
    () => _dataSource.addStudent(name: name, phone: phone, notes: notes),
  );

  @override
  Future<ApiResult<void>> updateStudent({
    required int id,
    required String name,
    String? phone,
    String? notes,
  }) => guardResult(
    () => _dataSource.updateStudent(
      id: id,
      name: name,
      phone: phone,
      notes: notes,
    ),
  );

  @override
  Future<ApiResult<void>> deleteStudent(int id) =>
      guardResult(() => _dataSource.deleteStudent(id));
}
