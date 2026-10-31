import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/theme_settings_entity.dart';
import '../models/theme_settings_model.dart';

class SettingsLocalDataSource {
  static const _modeKey = 'theme_mode';
  static const _paletteKey = 'theme_palette';

  final SharedPreferences _prefs;
  SettingsLocalDataSource(this._prefs);

  ThemeSettingsModel getThemeSettings() => ThemeSettingsModel.fromStorage(
    mode: _prefs.getString(_modeKey),
    palette: _prefs.getString(_paletteKey),
  );

  Future<void> saveThemeSettings(ThemeSettingsEntity settings) async {
    await _prefs.setString(_modeKey, settings.mode.name);
    await _prefs.setString(_paletteKey, settings.palette.name);
  }
}
