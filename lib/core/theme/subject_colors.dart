import 'package:flutter/material.dart';

/// Accent colors used to tag subjects and tint avatars.
abstract final class SubjectColors {
  static const List<Color> options = [
    Color(0xFF3B6EF5),
    Color(0xFF16A34A),
    Color(0xFFE5484D),
    Color(0xFFF07B14),
    Color(0xFF8B5CF6),
    Color(0xFF0EA5A4),
    Color(0xFFDB2777),
    Color(0xFFB7791F),
  ];

  static Color resolve(int? value, ColorScheme scheme) =>
      value == null ? scheme.primary : Color(value);

  /// A stable color for any text, e.g. a student's name.
  static Color forKey(String key) {
    var hash = 0;
    for (final unit in key.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return options[hash % options.length];
  }

  /// A readable text/icon tone of [color] for use on its own light tint:
  /// darker in light mode, lighter in dark mode (WCAG AA for small text).
  /// Keep the raw color for dots and backgrounds.
  static Color foreground(Color color, Brightness brightness) =>
      brightness == Brightness.light
      ? Color.lerp(color, Colors.black, 0.4)!
      : Color.lerp(color, Colors.white, 0.5)!;
}
