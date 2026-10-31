import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import '../../domain/usecases/watch_student_usecase.dart';
import 'student_details_state.dart';

class StudentDetailsCubit extends Cubit<StudentDetailsState> {
  final WatchStudentUseCase _watchStudent;
  final DeleteStudentUseCase _deleteStudent;

  StreamSubscription<ApiResult<StudentEntity>>? _subscription;
  int? _studentId;

  StudentDetailsCubit(this._watchStudent, this._deleteStudent)
    : super(const StudentDetailsLoading());

  void watch(int studentId) {
    _studentId = studentId;
    _subscribe();
  }

  void _subscribe() {
    final studentId = _studentId;
    if (studentId == null) return;
    _subscription?.cancel();
    _subscription = _watchStudent(studentId).listen(
      (result) => result.when(
        success: (student) => emit(StudentDetailsLoaded(student)),
        failure: (failure) => emit(StudentDetailsError(failure)),
      ),
    );
  }

  /// Stops watching first so the deleted record doesn't surface as an error.
  Future<Failure?> delete() async {
    final studentId = _studentId;
    if (studentId == null) return const NotFoundFailure();
    await _subscription?.cancel();
    final failure = (await _deleteStudent(studentId)).failureOrNull;
    if (failure != null && !isClosed) _subscribe();
    return failure;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
