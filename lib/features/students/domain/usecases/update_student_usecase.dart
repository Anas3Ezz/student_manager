import '../../../../core/result/api_result.dart';
import '../../../../core/validation/validators.dart';
import '../repos/students_repository.dart';

class UpdateStudentUseCase {
  final StudentsRepository _repository;
  UpdateStudentUseCase(this._repository);

  Future<ApiResult<void>> call({
    required int id,
    required String name,
    String? phone,
    String? notes,
  }) async {
    final invalid = Validators.name(name);
    if (invalid != null) return ApiResult.failure(invalid);
    return _repository.updateStudent(
      id: id,
      name: name.trim(),
      phone: Validators.optionalText(phone),
      notes: Validators.optionalText(notes),
    );
  }
}
