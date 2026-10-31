import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/theme_settings_entity.dart';
import '../../domain/usecases/get_theme_settings_usecase.dart';
import '../../domain/usecases/save_theme_settings_usecase.dart';

/// App-wide theme state. Falls back to defaults if settings can't be read.
class ThemeCubit extends Cubit<ThemeSettingsEntity> {
  final GetThemeSettingsUseCase _getThemeSettings;
  final SaveThemeSettingsUseCase _saveThemeSettings;

  ThemeCubit(this._getThemeSettings, this._saveThemeSettings)
    : super(const ThemeSettingsEntity());

  Future<void> load() async {
    final result = await _getThemeSettings();
    result.when(success: emit, failure: (_) {});
  }

  Future<void> setMode(AppThemeMode mode) =>
      _update(state.copyWith(mode: mode));

  Future<void> setPalette(AppPalette palette) =>
      _update(state.copyWith(palette: palette));

  /// Applies the change immediately; persisting is best-effort.
  Future<void> _update(ThemeSettingsEntity settings) async {
    if (settings == state) return;
    emit(settings);
    await _saveThemeSettings(settings);
  }
}
