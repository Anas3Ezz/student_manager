import '../../../../core/result/api_result.dart';
import '../entities/subject_entity.dart';
import '../repos/subjects_repository.dart';

class WatchSubjectsUseCase {
  final SubjectsRepository _repository;
  WatchSubjectsUseCase(this._repository);

  Stream<ApiResult<List<SubjectEntity>>> call() => _repository.watchSubjects();
}
