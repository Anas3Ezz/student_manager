import '../../../../core/bloc/watch_list_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/usecases/delete_session_usecase.dart';
import '../../domain/usecases/watch_recent_subject_sessions_usecase.dart';

class SubjectSessionsCubit extends WatchListCubit<SessionEntity> {
  final WatchRecentSubjectSessionsUseCase _watchRecentSubjectSessions;
  final DeleteSessionUseCase _deleteSession;

  SubjectSessionsCubit(this._watchRecentSubjectSessions, this._deleteSession);

  void watch(int subjectId) => listenTo(_watchRecentSubjectSessions(subjectId));

  Future<Failure?> deleteSession(int id) async =>
      (await _deleteSession(id)).failureOrNull;
}
