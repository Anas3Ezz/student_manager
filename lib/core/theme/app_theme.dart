import 'package:flutter/material.dart';

/// App-wide design system: soft tinted background, white cards with hairline
/// borders, generous radii and one bundled font for Arabic and Latin.
abstract final class AppTheme {
  static const String fontFamily = 'IBMPlexSansArabic';
  static const double radiusSmall = 12;
  static const double radius = 16;
  static const double radiusLarge = 24;

  static ThemeData build({
    required Color seed,
    required Brightness brightness,
  }) {
    // Soft tonal surfaces, but a primary that stays true to the seed color
    // (tonalSpot alone turns pink into a muted plum).
    final vivid = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ).copyWith(primary: vivid.primary, onPrimary: vivid.onPrimary);
    final isDark = brightness == Brightness.dark;
    final background = isDark ? scheme.surface : scheme.surfaceContainerLow;
    final cardColor = isDark
        ? scheme.surfaceContainer
        : scheme.surfaceContainerLowest;
    final hairline = BorderSide(
      color: scheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.6),
    );
    final textTheme = _textTheme(
      ThemeData(brightness: brightness).textTheme,
      scheme,
    );

    RoundedRectangleBorder rounded(
      double r, {
      BorderSide side = BorderSide.none,
    }) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(r),
      side: side,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          // iOS keeps its native Cupertino transition by default.
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        margin: EdgeInsets.zero,
        shape: rounded(radiusLarge - 4, side: hairline),
      ),
      listTileTheme: ListTileThemeData(
        shape: rounded(radius),
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: hairline,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: hairline,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          shape: rounded(radius),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: rounded(radius), side: hairline),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: rounded(radiusSmall),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: rounded(radius + 2),
        extendedTextStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: rounded(radiusSmall),
        side: hairline,
        backgroundColor: cardColor,
        selectedColor: scheme.primaryContainer,
        labelStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: rounded(radiusSmall),
          side: hairline,
          backgroundColor: cardColor,
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: rounded(radius),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: rounded(radiusLarge + 4),
        titleTextStyle: textTheme.titleLarge,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: rounded(radius, side: hairline),
        elevation: 3,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded(radius),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(cardColor),
        side: WidgetStatePropertyAll(hairline),
        shape: WidgetStatePropertyAll(rounded(radius)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16),
        ),
        hintStyle: WidgetStatePropertyAll(
          textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: hairline.color, space: 1),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    TextStyle? tune(TextStyle? style, FontWeight weight, [double? spacing]) =>
        style?.copyWith(
          fontFamily: fontFamily,
          fontWeight: weight,
          letterSpacing: spacing,
          color: scheme.onSurface,
        );
    return base.copyWith(
      displaySmall: tune(base.displaySmall, FontWeight.w700, -0.5),
      headlineLarge: tune(base.headlineLarge, FontWeight.w700, -0.5),
      headlineMedium: tune(base.headlineMedium, FontWeight.w700, -0.4),
      headlineSmall: tune(base.headlineSmall, FontWeight.w700, -0.3),
      titleLarge: tune(base.titleLarge, FontWeight.w700, -0.2),
      titleMedium: tune(base.titleMedium, FontWeight.w600, 0),
      titleSmall: tune(base.titleSmall, FontWeight.w600, 0),
      bodyLarge: tune(base.bodyLarge, FontWeight.w400, 0),
      bodyMedium: tune(base.bodyMedium, FontWeight.w400, 0),
      bodySmall: tune(base.bodySmall, FontWeight.w400, 0),
      labelLarge: tune(base.labelLarge, FontWeight.w600, 0),
      labelMedium: tune(base.labelMedium, FontWeight.w500, 0),
      labelSmall: tune(base.labelSmall, FontWeight.w500, 0.2),
    );
  }
}
