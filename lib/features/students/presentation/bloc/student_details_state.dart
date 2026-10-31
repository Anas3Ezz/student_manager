import '../../../../core/error/failures.dart';
import '../../domain/entities/student_entity.dart';

sealed class StudentDetailsState {
  const StudentDetailsState();
}

final class StudentDetailsLoading extends StudentDetailsState {
  const StudentDetailsLoading();
}

final class StudentDetailsLoaded extends StudentDetailsState {
  final StudentEntity student;
  const StudentDetailsLoaded(this.student);
}

final class StudentDetailsError extends StudentDetailsState {
  final Failure failure;
  const StudentDetailsError(this.failure);
}
