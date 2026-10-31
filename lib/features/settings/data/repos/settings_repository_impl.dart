import '../../../../core/result/api_result.dart';
import '../../../../core/result/result_guards.dart';
import '../../domain/entities/theme_settings_entity.dart';
import '../../domain/repos/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _dataSource;
  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<ThemeSettingsEntity>> getThemeSettings() =>
      guardResult(() async => _dataSource.getThemeSettings());

  @override
  Future<ApiResult<void>> saveThemeSettings(ThemeSettingsEntity settings) =>
      guardResult(() => _dataSource.saveThemeSettings(settings));
}
