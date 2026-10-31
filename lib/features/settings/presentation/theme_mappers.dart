import 'package:flutter/material.dart';

import '../domain/entities/theme_settings_entity.dart';

extension AppThemeModeX on AppThemeMode {
  ThemeMode get themeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

extension AppPaletteX on AppPalette {
  Color get seedColor => switch (this) {
    AppPalette.blue => const Color(0xFF2F6BFF),
    AppPalette.green => const Color(0xFF1F8A65),
    AppPalette.purple => const Color(0xFF7356E8),
    AppPalette.orange => const Color(0xFFE8772E),
    AppPalette.pink => const Color(0xFFE0457B),
  };
}
