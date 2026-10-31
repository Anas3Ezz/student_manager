import '../../../../core/error/failures.dart';
import '../../../../core/validation/validators.dart';

/// Values entered by the teacher when logging or editing a session.
class SessionInput {
  final int studentId;
  final int subjectId;
  final DateTime date;
  final int rating;
  final String? notes;

  const SessionInput({
    required this.studentId,
    required this.subjectId,
    required this.date,
    required this.rating,
    this.notes,
  });

  ValidationFailure? validate(DateTime today) =>
      Validators.rating(rating) ?? Validators.notInFuture(date, today);

  /// Date reduced to its day and blank notes turned into null.
  SessionInput normalized() => SessionInput(
    studentId: studentId,
    subjectId: subjectId,
    date: DateTime(date.year, date.month, date.day),
    rating: rating,
    notes: Validators.optionalText(notes),
  );
}
