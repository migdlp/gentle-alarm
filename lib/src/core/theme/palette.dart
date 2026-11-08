import 'dart:math' as math;

import 'package:flutter/painting.dart';

abstract final class Palette {
  static const night = Color(0xFF0B1026);
  static const nightDeep = Color(0xFF05060F);
  static const dusk = Color(0xFF2A1B3D);
  static const ember = Color(0xFF3A0F1E);
  static const coral = Color(0xFFFF7A3D);
  static const honey = Color(0xFFFFC872);
  static const peach = Color(0xFFFFB36B);
  static const cream = Color(0xFFFFF4E0);
  static const inkOnDark = Color(0xFFF5EBDD);
  static const inkOnLight = Color(0xFF2B1A12);
  static const accent = Color(0xFFE8693A);
  static const white = Color(0xFFFFFFFF);
}

double _channel(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

/// Relación de contraste WCAG 2.1 entre dos colores opacos.
double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}
