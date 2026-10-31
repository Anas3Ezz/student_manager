import '../../../../core/result/api_result.dart';
import '../../../../core/validation/validators.dart';
import '../repos/students_repository.dart';

class AddStudentUseCase {
  final StudentsRepository _repository;
  AddStudentUseCase(this._repository);

  Future<ApiResult<int>> call({
    required String name,
    String? phone,
    String? notes,
  }) async {
    final invalid = Validators.name(name);
    if (invalid != null) return ApiResult.failure(invalid);
    return _repository.addStudent(
      name: name.trim(),
      phone: Validators.optionalText(phone),
      notes: Validators.optionalText(notes),
    );
  }
}
