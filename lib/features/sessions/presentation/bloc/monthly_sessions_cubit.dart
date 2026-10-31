import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/usecases/delete_session_usecase.dart';
import '../../domain/usecases/get_today_usecase.dart';
import '../../domain/usecases/watch_monthly_sessions_usecase.dart';
import 'monthly_sessions_state.dart';

/// A student's sessions for one calendar month, optionally filtered by subject.
class MonthlySessionsCubit extends Cubit<MonthlySessionsState> {
  final GetTodayUseCase _getToday;
  final WatchMonthlySessionsUseCase _watchMonthlySessions;
  final DeleteSessionUseCase _deleteSession;

  StreamSubscription<ApiResult<List<SessionEntity>>>? _subscription;
  int? _studentId;

  MonthlySessionsCubit(
    this._getToday,
    this._watchMonthlySessions,
    this._deleteSession,
  ) : super(
        MonthlySessionsLoading(
          month: DateTime(0),
          subjectId: null,
          canGoNext: false,
        ),
      );

  /// Opens on the current month.
  void start(int studentId) {
    _studentId = studentId;
    final today = _getToday();
    _load(DateTime(today.year, today.month), null);
  }

  void previousMonth() =>
      _load(DateTime(state.month.year, state.month.month - 1), state.subjectId);

  void nextMonth() {
    if (!state.canGoNext) return;
    _load(DateTime(state.month.year, state.month.month + 1), state.subjectId);
  }

  void filterBySubject(int? subjectId) {
    if (subjectId == state.subjectId) return;
    _load(state.month, subjectId);
  }

  /// Clears the subject filter once it can no longer be changed from the UI:
  /// the subject was unassigned, or fewer than two subjects remain.
  void onAssignedSubjectsChanged(List<int> assignedSubjectIds) {
    final selected = state.subjectId;
    if (selected == null) return;
    if (assignedSubjectIds.length < 2 ||
        !assignedSubjectIds.contains(selected)) {
      filterBySubject(null);
    }
  }

  Future<Failure?> deleteSession(int id) async =>
      (await _deleteSession(id)).failureOrNull;

  void _load(DateTime month, int? subjectId) {
    final studentId = _studentId;
    if (studentId == null) return;
    final today = _getToday();
    final canGoNext = month.isBefore(DateTime(today.year, today.month));
    emit(
      MonthlySessionsLoading(
        month: month,
        subjectId: subjectId,
        canGoNext: canGoNext,
      ),
    );
    _subscription?.cancel();
    _subscription =
        _watchMonthlySessions(
          studentId: studentId,
          month: month,
          subjectId: subjectId,
        ).listen(
          (result) => result.when(
            success: (sessions) => emit(
              MonthlySessionsLoaded(
                sessions: sessions,
                month: month,
                subjectId: subjectId,
                canGoNext: canGoNext,
              ),
            ),
            failure: (failure) => emit(
              MonthlySessionsError(
                failure: failure,
                month: month,
                subjectId: subjectId,
                canGoNext: canGoNext,
              ),
            ),
          ),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
