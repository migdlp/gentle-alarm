import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gentle_alarm/src/core/theme/palette.dart';

void main() {
  final pairs = <String, (Color, Color)>{
    'inkOnLight/cream': (Palette.inkOnLight, Palette.cream),
    'inkOnLight/white': (Palette.inkOnLight, Palette.white),
    'inkOnDark/night': (Palette.inkOnDark, Palette.night),
    'inkOnDark/dusk': (Palette.inkOnDark, Palette.dusk),
    'inkOnLight/accent': (Palette.inkOnLight, Palette.accent),
    'night/coral': (Palette.night, Palette.coral),
  };
  pairs.forEach((name, p) {
    test('contraste >= 4,5 en $name', () {
      expect(contrastRatio(p.$1, p.$2), greaterThanOrEqualTo(4.5));
    });
  });
  test('negro sobre blanco = 21', () {
    expect(
      contrastRatio(const Color(0xFF000000), Palette.white),
      closeTo(21, 0.01),
    );
  });
}
