import '../../../../core/result/api_result.dart';
import '../entities/session_entity.dart';
import '../entities/session_input.dart';

abstract class SessionsRepository {
  /// Sessions with `from <= date < to`, newest first.
  Stream<ApiResult<List<SessionEntity>>> watchStudentSessions({
    required int studentId,
    required DateTime from,
    required DateTime to,
    int? subjectId,
  });
  Stream<ApiResult<List<SessionEntity>>> watchRecentSubjectSessions({
    required int subjectId,
    required int limit,
  });
  Future<ApiResult<int?>> getLastUsedSubjectId(int studentId);
  Future<ApiResult<int>> addSession(SessionInput input);
  Future<ApiResult<void>> updateSession(int id, SessionInput input);
  Future<ApiResult<void>> deleteSession(int id);
}
