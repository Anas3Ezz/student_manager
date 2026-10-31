import '../../../../core/result/api_result.dart';
import '../../../../core/result/result_guards.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repos/subjects_repository.dart';
import '../datasources/subjects_local_data_source.dart';

class SubjectsRepositoryImpl implements SubjectsRepository {
  final SubjectsLocalDataSource _dataSource;
  SubjectsRepositoryImpl(this._dataSource);

  @override
  Stream<ApiResult<List<SubjectEntity>>> watchSubjects() =>
      _dataSource.watchSubjects().asResult();

  @override
  Future<ApiResult<int>> addSubject({required String name, int? colorValue}) =>
      guardResult(
        () => _dataSource.addSubject(name: name, colorValue: colorValue),
      );

  @override
  Future<ApiResult<void>> updateSubject(SubjectEntity subject) => guardResult(
    () => _dataSource.updateSubject(
      id: subject.id,
      name: subject.name,
      colorValue: subject.colorValue,
    ),
  );

  @override
  Future<ApiResult<void>> deleteSubject(int id) =>
      guardResult(() => _dataSource.deleteSubject(id));

  @override
  Stream<ApiResult<List<SubjectEntity>>> watchStudentSubjects(int studentId) =>
      _dataSource.watchStudentSubjects(studentId).asResult();

  @override
  Future<ApiResult<List<SubjectEntity>>> getStudentSubjects(int studentId) =>
      guardResult(() => _dataSource.getStudentSubjects(studentId));

  @override
  Future<ApiResult<void>> assignSubject({
    required int studentId,
    required int subjectId,
  }) => guardResult(
    () => _dataSource.assignSubject(studentId: studentId, subjectId: subjectId),
  );

  @override
  Future<ApiResult<void>> unassignSubject({
    required int studentId,
    required int subjectId,
  }) => guardResult(
    () =>
        _dataSource.unassignSubject(studentId: studentId, subjectId: subjectId),
  );
}
