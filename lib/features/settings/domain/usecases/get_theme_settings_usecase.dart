import '../../../../core/result/api_result.dart';
import '../entities/theme_settings_entity.dart';
import '../repos/settings_repository.dart';

class GetThemeSettingsUseCase {
  final SettingsRepository _repository;
  GetThemeSettingsUseCase(this._repository);

  Future<ApiResult<ThemeSettingsEntity>> call() =>
      _repository.getThemeSettings();
}
