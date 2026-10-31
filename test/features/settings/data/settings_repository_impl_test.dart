import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_system/core/result/api_result.dart';
import 'package:teacher_system/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:teacher_system/features/settings/data/repos/settings_repository_impl.dart';
import 'package:teacher_system/features/settings/domain/entities/theme_settings_entity.dart';

void main() {
  Future<SettingsRepositoryImpl> createRepository(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepositoryImpl(SettingsLocalDataSource(prefs));
  }

  test('returns defaults when nothing is stored', () async {
    final repository = await createRepository({});

    final result = await repository.getThemeSettings();

    expect(result, const ApiSuccess(ThemeSettingsEntity()));
  });

  test('falls back to defaults for unknown stored values', () async {
    final repository = await createRepository({
      'theme_mode': 'neon',
      'theme_palette': 'rainbow',
    });

    final result = await repository.getThemeSettings();

    expect(result, const ApiSuccess(ThemeSettingsEntity()));
  });

  test('saved settings are read back', () async {
    final repository = await createRepository({});
    const settings = ThemeSettingsEntity(
      mode: AppThemeMode.dark,
      palette: AppPalette.green,
    );

    await repository.saveThemeSettings(settings);

    expect(await repository.getThemeSettings(), const ApiSuccess(settings));
  });

  test('the pink palette is stored and read back', () async {
    final repository = await createRepository({});
    const settings = ThemeSettingsEntity(palette: AppPalette.pink);

    await repository.saveThemeSettings(settings);

    expect(await repository.getThemeSettings(), const ApiSuccess(settings));
  });
}
