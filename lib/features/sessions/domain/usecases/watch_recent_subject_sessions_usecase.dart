import '../../../../core/result/api_result.dart';
import '../entities/session_entity.dart';
import '../repos/sessions_repository.dart';

class WatchRecentSubjectSessionsUseCase {
  static const int defaultLimit = 20;

  final SessionsRepository _repository;
  WatchRecentSubjectSessionsUseCase(this._repository);

  Stream<ApiResult<List<SessionEntity>>> call(int subjectId) => _repository
      .watchRecentSubjectSessions(subjectId: subjectId, limit: defaultLimit);
}
