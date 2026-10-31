import '../../../../core/error/failures.dart';
import '../../domain/entities/session_entity.dart';

sealed class MonthlySessionsState {
  /// First day of the displayed month.
  final DateTime month;
  final int? subjectId;
  final bool canGoNext;

  const MonthlySessionsState({
    required this.month,
    required this.subjectId,
    required this.canGoNext,
  });
}

final class MonthlySessionsLoading extends MonthlySessionsState {
  const MonthlySessionsLoading({
    required super.month,
    required super.subjectId,
    required super.canGoNext,
  });
}

final class MonthlySessionsLoaded extends MonthlySessionsState {
  final List<SessionEntity> sessions;

  const MonthlySessionsLoaded({
    required this.sessions,
    required super.month,
    required super.subjectId,
    required super.canGoNext,
  });
}

final class MonthlySessionsError extends MonthlySessionsState {
  final Failure failure;

  const MonthlySessionsError({
    required this.failure,
    required super.month,
    required super.subjectId,
    required super.canGoNext,
  });
}
