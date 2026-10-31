import '../../../../core/result/api_result.dart';
import '../../../../core/result/result_guards.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/session_input.dart';
import '../../domain/repos/sessions_repository.dart';
import '../datasources/sessions_local_data_source.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsLocalDataSource _dataSource;
  SessionsRepositoryImpl(this._dataSource);

  @override
  Stream<ApiResult<List<SessionEntity>>> watchStudentSessions({
    required int studentId,
    required DateTime from,
    required DateTime to,
    int? subjectId,
  }) => _dataSource
      .watchStudentSessions(
        studentId: studentId,
        from: from,
        to: to,
        subjectId: subjectId,
      )
      .asResult();

  @override
  Stream<ApiResult<List<SessionEntity>>> watchRecentSubjectSessions({
    required int subjectId,
    required int limit,
  }) => _dataSource
      .watchRecentSubjectSessions(subjectId: subjectId, limit: limit)
      .asResult();

  @override
  Future<ApiResult<int?>> getLastUsedSubjectId(int studentId) =>
      guardResult(() => _dataSource.getLastUsedSubjectId(studentId));

  @override
  Future<ApiResult<int>> addSession(SessionInput input) =>
      guardResult(() => _dataSource.addSession(input));

  @override
  Future<ApiResult<void>> updateSession(int id, SessionInput input) =>
      guardResult(() => _dataSource.updateSession(id, input));

  @override
  Future<ApiResult<void>> deleteSession(int id) =>
      guardResult(() => _dataSource.deleteSession(id));
}
