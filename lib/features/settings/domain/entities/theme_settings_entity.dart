enum AppThemeMode { system, light, dark }

enum AppPalette { blue, green, purple, orange, pink }

class ThemeSettingsEntity {
  final AppThemeMode mode;
  final AppPalette palette;

  const ThemeSettingsEntity({
    this.mode = AppThemeMode.system,
    this.palette = AppPalette.blue,
  });

  ThemeSettingsEntity copyWith({AppThemeMode? mode, AppPalette? palette}) =>
      ThemeSettingsEntity(
        mode: mode ?? this.mode,
        palette: palette ?? this.palette,
      );

  @override
  bool operator ==(Object other) =>
      other is ThemeSettingsEntity &&
      other.mode == mode &&
      other.palette == palette;

  @override
  int get hashCode => Object.hash(mode, palette);
}
