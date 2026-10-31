import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_student_usecase.dart';
import '../../domain/usecases/update_student_usecase.dart';
import 'student_form_state.dart';

class StudentFormCubit extends Cubit<StudentFormState> {
  final AddStudentUseCase _addStudent;
  final UpdateStudentUseCase _updateStudent;

  StudentFormCubit(this._addStudent, this._updateStudent)
    : super(const StudentFormIdle());

  /// Creates a student when [id] is null, otherwise updates it.
  Future<void> save({
    int? id,
    required String name,
    String? phone,
    String? notes,
  }) async {
    if (state is StudentFormSaving) return;
    emit(const StudentFormSaving());
    if (id == null) {
      final result = await _addStudent(name: name, phone: phone, notes: notes);
      if (isClosed) return;
      result.when(
        success: (newId) => emit(StudentFormSaved(newStudentId: newId)),
        failure: (failure) => emit(StudentFormError(failure)),
      );
    } else {
      final result = await _updateStudent(
        id: id,
        name: name,
        phone: phone,
        notes: notes,
      );
      if (isClosed) return;
      result.when(
        success: (_) => emit(const StudentFormSaved()),
        failure: (failure) => emit(StudentFormError(failure)),
      );
    }
  }
}
