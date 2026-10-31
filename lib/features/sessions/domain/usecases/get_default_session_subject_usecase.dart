import '../../../../core/result/api_result.dart';
import '../repos/sessions_repository.dart';

/// Picks the subject to preselect when logging a session:
/// the only subject, else the last one used (if still assigned), else none.
class GetDefaultSessionSubjectUseCase {
  final SessionsRepository _repository;
  GetDefaultSessionSubjectUseCase(this._repository);

  Future<ApiResult<int?>> call({
    required int studentId,
    required List<int> assignedSubjectIds,
  }) async {
    if (assignedSubjectIds.isEmpty) return const ApiResult.success(null);
    if (assignedSubjectIds.length == 1) {
      return ApiResult.success(assignedSubjectIds.single);
    }
    final result = await _repository.getLastUsedSubjectId(studentId);
    return result.when(
      success: (lastId) => ApiResult.success(
        assignedSubjectIds.contains(lastId) ? lastId : null,
      ),
      failure: ApiResult.failure,
    );
  }
}
