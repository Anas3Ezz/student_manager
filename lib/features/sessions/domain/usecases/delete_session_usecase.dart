import '../../../../core/result/api_result.dart';
import '../repos/sessions_repository.dart';

class DeleteSessionUseCase {
  final SessionsRepository _repository;
  DeleteSessionUseCase(this._repository);

  Future<ApiResult<void>> call(int id) => _repository.deleteSession(id);
}
