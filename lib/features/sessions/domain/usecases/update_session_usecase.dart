import '../../../../core/result/api_result.dart';
import '../../../../core/utils/clock.dart';
import '../entities/session_input.dart';
import '../repos/sessions_repository.dart';

class UpdateSessionUseCase {
  final SessionsRepository _repository;
  final Clock _clock;
  UpdateSessionUseCase(this._repository, this._clock);

  Future<ApiResult<void>> call(int id, SessionInput input) async {
    final invalid = input.validate(_clock.now());
    if (invalid != null) return ApiResult.failure(invalid);
    return _repository.updateSession(id, input.normalized());
  }
}
