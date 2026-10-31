import '../../../../core/bloc/watch_list_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/usecases/assign_subject_usecase.dart';
import '../../domain/usecases/unassign_subject_usecase.dart';
import '../../domain/usecases/watch_student_subjects_usecase.dart';

/// Subjects assigned to one student, plus assign/unassign actions.
class StudentSubjectsCubit extends WatchListCubit<SubjectEntity> {
  final WatchStudentSubjectsUseCase _watchStudentSubjects;
  final AssignSubjectUseCase _assignSubject;
  final UnassignSubjectUseCase _unassignSubject;

  int? _studentId;

  StudentSubjectsCubit(
    this._watchStudentSubjects,
    this._assignSubject,
    this._unassignSubject,
  );

  void watch(int studentId) {
    _studentId = studentId;
    listenTo(_watchStudentSubjects(studentId));
  }

  Future<Failure?> assign(int subjectId) async {
    final studentId = _studentId;
    if (studentId == null) return const NotFoundFailure();
    return (await _assignSubject(
      studentId: studentId,
      subjectId: subjectId,
    )).failureOrNull;
  }

  Future<Failure?> unassign(int subjectId) async {
    final studentId = _studentId;
    if (studentId == null) return const NotFoundFailure();
    return (await _unassignSubject(
      studentId: studentId,
      subjectId: subjectId,
    )).failureOrNull;
  }
}
