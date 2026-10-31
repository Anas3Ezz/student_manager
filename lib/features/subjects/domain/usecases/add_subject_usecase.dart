import '../../../../core/result/api_result.dart';
import '../../../../core/validation/validators.dart';
import '../repos/subjects_repository.dart';

class AddSubjectUseCase {
  final SubjectsRepository _repository;
  AddSubjectUseCase(this._repository);

  Future<ApiResult<int>> call({required String name, int? colorValue}) async {
    final invalid = Validators.name(name);
    if (invalid != null) return ApiResult.failure(invalid);
    return _repository.addSubject(name: name.trim(), colorValue: colorValue);
  }
}
