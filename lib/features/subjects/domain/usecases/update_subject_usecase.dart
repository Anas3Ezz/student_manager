import '../../../../core/result/api_result.dart';
import '../../../../core/validation/validators.dart';
import '../entities/subject_entity.dart';
import '../repos/subjects_repository.dart';

class UpdateSubjectUseCase {
  final SubjectsRepository _repository;
  UpdateSubjectUseCase(this._repository);

  Future<ApiResult<void>> call(SubjectEntity subject) async {
    final invalid = Validators.name(subject.name);
    if (invalid != null) return ApiResult.failure(invalid);
    return _repository.updateSubject(
      SubjectEntity(
        id: subject.id,
        name: subject.name.trim(),
        colorValue: subject.colorValue,
      ),
    );
  }
}
