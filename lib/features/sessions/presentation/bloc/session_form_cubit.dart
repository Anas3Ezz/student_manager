import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/api_result.dart';
import '../../../subjects/domain/entities/subject_entity.dart';
import '../../../subjects/domain/usecases/add_subject_usecase.dart';
import '../../../subjects/domain/usecases/assign_subject_usecase.dart';
import '../../../subjects/domain/usecases/get_student_subjects_usecase.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/session_input.dart';
import '../../domain/usecases/add_session_usecase.dart';
import '../../domain/usecases/get_default_session_subject_usecase.dart';
import '../../domain/usecases/get_today_usecase.dart';
import '../../domain/usecases/update_session_usecase.dart';
import 'session_form_state.dart';

/// Loads what the "log session" sheet needs and saves the session.
class SessionFormCubit extends Cubit<SessionFormState> {
  final GetStudentSubjectsUseCase _getStudentSubjects;
  final GetDefaultSessionSubjectUseCase _getDefaultSubject;
  final GetTodayUseCase _getToday;
  final AddSessionUseCase _addSession;
  final UpdateSessionUseCase _updateSession;
  final AssignSubjectUseCase _assignSubject;
  final AddSubjectUseCase _addSubject;

  int _studentId = 0;
  SessionEntity? _editing;

  SessionFormCubit(
    this._getStudentSubjects,
    this._getDefaultSubject,
    this._getToday,
    this._addSession,
    this._updateSession,
    this._assignSubject,
    this._addSubject,
  ) : super(const SessionFormLoading());

  Future<void> load({required int studentId, SessionEntity? editing}) async {
    _studentId = studentId;
    _editing = editing;
    final subjectsResult = await _getStudentSubjects(studentId);
    if (isClosed) return;
    await subjectsResult.when(
      success: (subjects) => _emitReady(_withEditedSubject(subjects)),
      failure: (failure) async => emit(SessionFormLoadError(failure)),
    );
  }

  Future<void> save({
    required int subjectId,
    required DateTime date,
    required int rating,
    String? notes,
  }) async {
    final current = state;
    if (current is! SessionFormReady || current.isSaving) return;
    emit(current.copyWith(isSaving: true));
    final input = SessionInput(
      studentId: _studentId,
      subjectId: subjectId,
      date: date,
      rating: rating,
      notes: notes,
    );
    final editing = _editing;
    final failure = editing == null
        ? (await _addSession(input)).failureOrNull
        : (await _updateSession(editing.id, input)).failureOrNull;
    if (isClosed) return;
    emit(
      failure == null
          ? const SessionFormSaved()
          : current.copyWith(isSaving: false, saveFailure: failure),
    );
  }

  /// Assigns an existing subject to the student, then reloads the form
  /// so it can be logged right away.
  Future<void> assignSubject(int subjectId) => _runSubjectAction(
    () => _assignSubject(studentId: _studentId, subjectId: subjectId),
  );

  /// Creates a new subject and assigns it to the student.
  Future<void> createAndAssignSubject({
    required String name,
    required int colorValue,
  }) => _runSubjectAction(() async {
    final added = await _addSubject(name: name, colorValue: colorValue);
    return switch (added) {
      ApiSuccess(:final data) => _assignSubject(
        studentId: _studentId,
        subjectId: data,
      ),
      ApiFailure(:final failure) => ApiResult.failure(failure),
    };
  });

  Future<void> _runSubjectAction(
    Future<ApiResult<void>> Function() action,
  ) async {
    final current = state;
    if (current is! SessionFormReady || current.isSaving) return;
    emit(current.copyWith(isSaving: true));
    final failure = (await action()).failureOrNull;
    if (isClosed) return;
    if (failure != null) {
      emit(current.copyWith(isSaving: false, saveFailure: failure));
      return;
    }
    emit(const SessionFormLoading());
    await load(studentId: _studentId, editing: _editing);
  }

  Future<void> _emitReady(List<SubjectEntity> subjects) async {
    final today = _getToday();
    final editing = _editing;
    if (editing != null) {
      emit(
        SessionFormReady(
          subjects: subjects,
          initialSubjectId: editing.subjectId,
          initialDate: editing.date,
          today: today,
        ),
      );
      return;
    }
    final defaultResult = await _getDefaultSubject(
      studentId: _studentId,
      assignedSubjectIds: subjects.map((s) => s.id).toList(),
    );
    if (isClosed) return;
    emit(
      SessionFormReady(
        subjects: subjects,
        // A missing default only means nothing is preselected.
        initialSubjectId: switch (defaultResult) {
          ApiSuccess(:final data) => data,
          ApiFailure() => null,
        },
        initialDate: today,
        today: today,
      ),
    );
  }

  /// Keeps an edited session's subject selectable even if it was unassigned.
  List<SubjectEntity> _withEditedSubject(List<SubjectEntity> subjects) {
    final editing = _editing;
    if (editing == null || subjects.any((s) => s.id == editing.subjectId)) {
      return subjects;
    }
    return [
      ...subjects,
      SubjectEntity(
        id: editing.subjectId,
        name: editing.subjectName,
        colorValue: editing.subjectColorValue,
      ),
    ];
  }
}
