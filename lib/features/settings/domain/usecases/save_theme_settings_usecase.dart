import '../../../../core/result/api_result.dart';
import '../entities/theme_settings_entity.dart';
import '../repos/settings_repository.dart';

class SaveThemeSettingsUseCase {
  final SettingsRepository _repository;
  SaveThemeSettingsUseCase(this._repository);

  Future<ApiResult<void>> call(ThemeSettingsEntity settings) =>
      _repository.saveThemeSettings(settings);
}
