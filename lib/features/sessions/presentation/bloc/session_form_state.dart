import '../../../../core/error/failures.dart';
import '../../../subjects/domain/entities/subject_entity.dart';

sealed class SessionFormState {
  const SessionFormState();
}

final class SessionFormLoading extends SessionFormState {
  const SessionFormLoading();
}

final class SessionFormLoadError extends SessionFormState {
  final Failure failure;
  const SessionFormLoadError(this.failure);
}

final class SessionFormReady extends SessionFormState {
  final List<SubjectEntity> subjects;
  final int? initialSubjectId;
  final DateTime initialDate;
  final DateTime today;
  final bool isSaving;
  final Failure? saveFailure;

  const SessionFormReady({
    required this.subjects,
    required this.initialSubjectId,
    required this.initialDate,
    required this.today,
    this.isSaving = false,
    this.saveFailure,
  });

  SessionFormReady copyWith({required bool isSaving, Failure? saveFailure}) =>
      SessionFormReady(
        subjects: subjects,
        initialSubjectId: initialSubjectId,
        initialDate: initialDate,
        today: today,
        isSaving: isSaving,
        saveFailure: saveFailure,
      );
}

final class SessionFormSaved extends SessionFormState {
  const SessionFormSaved();
}
