import '../../../../core/result/api_result.dart';
import '../entities/session_entity.dart';
import '../repos/sessions_repository.dart';

class WatchMonthlySessionsUseCase {
  final SessionsRepository _repository;
  WatchMonthlySessionsUseCase(this._repository);

  /// Sessions of [studentId] in the calendar month containing [month].
  Stream<ApiResult<List<SessionEntity>>> call({
    required int studentId,
    required DateTime month,
    int? subjectId,
  }) => _repository.watchStudentSessions(
    studentId: studentId,
    from: DateTime(month.year, month.month),
    to: DateTime(month.year, month.month + 1),
    subjectId: subjectId,
  );
}
