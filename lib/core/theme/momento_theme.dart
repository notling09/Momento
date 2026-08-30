import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'momento_colors.dart';

/// Zwei Schriften, wie im Businessplan beschrieben:
/// "Baloo 2" ist rund und verspielt (Tagebuch-Gefuehl) und traegt die
/// Ueberschriften, "Quicksand" ist ruhig und gut lesbar fuer Fliesstext.
abstract final class MomentoFonts {
  static const display = 'Baloo';
  static const body = 'Quicksand';
}

abstract final class MomentoRadii {
  static const card = 24.0;
  static const tile = 18.0;
  static const chip = 999.0;
  static const sheet = 32.0;
}

abstract final class MomentoTheme {
  /// Duefte und Gefuehle werden mit Emoji dargestellt. Auf dem Geraet greift
  /// dafuer die Systemschrift; diese Liste stellt sicher, dass es auch dort
  /// klappt, wo es keine automatische Ersatzschrift gibt.
  static const _emojiFallback = <String>[
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Segoe UI Emoji',
  ];

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final ink = isDark ? MomentoColors.darkInk : MomentoColors.ink;
    final inkSoft = isDark ? MomentoColors.darkInkSoft : MomentoColors.inkSoft;
    final background =
        isDark ? MomentoColors.darkBackground : MomentoColors.lightBackground;
    final surface = isDark ? MomentoColors.darkSurface : MomentoColors.lightSurface;
    final surfaceMuted =
        isDark ? MomentoColors.darkSurfaceMuted : MomentoColors.lightSurfaceMuted;
    final outline = isDark ? MomentoColors.darkOutline : MomentoColors.lightOutline;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? MomentoColors.violet : MomentoColors.plumInk,
      onPrimary: isDark ? const Color(0xFF23163A) : Colors.white,
      primaryContainer: isDark ? const Color(0xFF3E2B57) : const Color(0xFFF3E4FB),
      onPrimaryContainer: isDark ? MomentoColors.darkInk : MomentoColors.plumInk,
      secondary: MomentoColors.rose,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? const Color(0xFF4A2839) : const Color(0xFFFFE1EC),
      onSecondaryContainer: isDark ? MomentoColors.darkInk : const Color(0xFF8E3358),
      tertiary: MomentoColors.peach,
      onTertiary: const Color(0xFF4A2E14),
      tertiaryContainer: isDark ? const Color(0xFF4B3520) : const Color(0xFFFFE9D6),
      onTertiaryContainer: isDark ? MomentoColors.darkInk : const Color(0xFF7A4A1C),
      error: MomentoColors.danger,
      onError: Colors.white,
      errorContainer: isDark ? const Color(0xFF54222F) : const Color(0xFFFFE1E6),
      onErrorContainer: isDark ? MomentoColors.darkInk : const Color(0xFF8C2B41),
      surface: surface,
      onSurface: ink,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceMuted,
      surfaceContainerHigh: surfaceMuted,
      surfaceContainerHighest: surfaceMuted,
      onSurfaceVariant: inkSoft,
      outline: outline,
      outlineVariant: outline,
      shadow: isDark ? Colors.black : const Color(0xFF6B4F60),
      scrim: Colors.black,
      inverseSurface: isDark ? MomentoColors.lightSurface : MomentoColors.darkSurface,
      onInverseSurface: isDark ? MomentoColors.ink : MomentoColors.darkInk,
      inversePrimary: isDark ? MomentoColors.plumInk : MomentoColors.violet,
    );

    TextStyle display(double size, {FontWeight weight = FontWeight.w700, double? height}) =>
        TextStyle(
          fontFamily: MomentoFonts.display,
          fontFamilyFallback: _emojiFallback,
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: ink,
          letterSpacing: 0.1,
        );

    TextStyle body(double size, {FontWeight weight = FontWeight.w500, Color? color, double? height}) =>
        TextStyle(
          fontFamily: MomentoFonts.body,
          fontFamilyFallback: _emojiFallback,
          fontSize: size,
          fontWeight: weight,
          height: height ?? 1.4,
          color: color ?? ink,
        );

    final textTheme = TextTheme(
      displayLarge: display(40, weight: FontWeight.w800, height: 1.1),
      displayMedium: display(32, weight: FontWeight.w800, height: 1.15),
      displaySmall: display(28, height: 1.2),
      headlineLarge: display(26, height: 1.2),
      headlineMedium: display(22, height: 1.25),
      headlineSmall: display(19, height: 1.3),
      titleLarge: display(18, weight: FontWeight.w600),
      titleMedium: body(16, weight: FontWeight.w700),
      titleSmall: body(14, weight: FontWeight.w700),
      bodyLarge: body(16),
      bodyMedium: body(14.5),
      bodySmall: body(13, color: inkSoft),
      labelLarge: body(15, weight: FontWeight.w700),
      labelMedium: body(13, weight: FontWeight.w600),
      labelSmall: body(11.5, weight: FontWeight.w600, color: inkSoft),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: MomentoFonts.body,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: ink,
        titleTextStyle: textTheme.headlineSmall,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MomentoRadii.card),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: outline),
        labelStyle: textTheme.labelMedium!,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? MomentoColors.darkSurfaceMuted : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyMedium!.copyWith(color: inkSoft),
        labelStyle: textTheme.bodyMedium!.copyWith(color: inkSoft),
        border: _inputBorder(outline),
        enabledBorder: _inputBorder(outline),
        focusedBorder: _inputBorder(MomentoColors.rose, width: 1.8),
        errorBorder: _inputBorder(MomentoColors.danger),
        focusedErrorBorder: _inputBorder(MomentoColors.danger, width: 1.8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          textStyle: textTheme.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: scheme.primary,
          side: BorderSide(color: outline, width: 1.4),
          textStyle: textTheme.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? MomentoColors.darkSurfaceMuted : MomentoColors.ink,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MomentoRadii.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MomentoRadii.tile)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(MomentoRadii.tile),
        borderSide: BorderSide(color: color, width: width),
      );
}
