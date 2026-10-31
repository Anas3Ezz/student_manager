import '../../../../core/result/api_result.dart';
import '../entities/theme_settings_entity.dart';

abstract class SettingsRepository {
  Future<ApiResult<ThemeSettingsEntity>> getThemeSettings();
  Future<ApiResult<void>> saveThemeSettings(ThemeSettingsEntity settings);
}
