import '../../domain/entities/theme_settings_entity.dart';

class ThemeSettingsModel extends ThemeSettingsEntity {
  const ThemeSettingsModel({super.mode, super.palette});

  /// Parses stored enum names, falling back to defaults for unknown values.
  factory ThemeSettingsModel.fromStorage({String? mode, String? palette}) =>
      ThemeSettingsModel(
        mode: AppThemeMode.values.asNameMap()[mode] ?? AppThemeMode.system,
        palette: AppPalette.values.asNameMap()[palette] ?? AppPalette.blue,
      );
}
