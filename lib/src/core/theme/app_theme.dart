import 'package:flutter/material.dart';
import 'package:gentle_alarm/src/core/theme/palette.dart';

const _radius = 20.0;

ThemeData _build(ColorScheme scheme) {
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_radius),
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.brightness == Brightness.light
        ? Palette.cream
        : Palette.night,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        shape: shape,
      ),
    ),
    cardTheme: CardThemeData(shape: shape),
  );
}

ThemeData buildLightTheme() => _build(
  const ColorScheme(
    brightness: Brightness.light,
    primary: Palette.accent,
    onPrimary: Palette.inkOnLight,
    secondary: Palette.honey,
    onSecondary: Palette.inkOnLight,
    error: Color(0xFFB3261E),
    onError: Palette.white,
    surface: Palette.white,
    onSurface: Palette.inkOnLight,
  ),
);

ThemeData buildDarkTheme() => _build(
  const ColorScheme(
    brightness: Brightness.dark,
    primary: Palette.coral,
    onPrimary: Palette.night,
    secondary: Palette.honey,
    onSecondary: Palette.inkOnLight,
    error: Color(0xFFB3261E),
    onError: Palette.white,
    surface: Palette.dusk,
    onSurface: Palette.inkOnDark,
  ),
);
