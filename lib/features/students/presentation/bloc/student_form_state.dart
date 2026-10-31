import '../../../../core/error/failures.dart';

sealed class StudentFormState {
  const StudentFormState();
}

final class StudentFormIdle extends StudentFormState {
  const StudentFormIdle();
}

final class StudentFormSaving extends StudentFormState {
  const StudentFormSaving();
}

/// [newStudentId] is set when a new student was created.
final class StudentFormSaved extends StudentFormState {
  final int? newStudentId;
  const StudentFormSaved({this.newStudentId});
}

final class StudentFormError extends StudentFormState {
  final Failure failure;
  const StudentFormError(this.failure);
}
