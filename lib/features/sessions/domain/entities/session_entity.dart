class SessionEntity {
  final int id;
  final int studentId;
  final String studentName;
  final int subjectId;
  final String subjectName;
  final int? subjectColorValue;
  final DateTime date;
  final int rating;
  final String? notes;

  const SessionEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    this.subjectColorValue,
    required this.date,
    required this.rating,
    this.notes,
  });

  @override
  bool operator ==(Object other) =>
      other is SessionEntity &&
      other.id == id &&
      other.studentId == studentId &&
      other.studentName == studentName &&
      other.subjectId == subjectId &&
      other.subjectName == subjectName &&
      other.subjectColorValue == subjectColorValue &&
      other.date == date &&
      other.rating == rating &&
      other.notes == notes;

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    studentName,
    subjectId,
    subjectName,
    subjectColorValue,
    date,
    rating,
    notes,
  );
}
